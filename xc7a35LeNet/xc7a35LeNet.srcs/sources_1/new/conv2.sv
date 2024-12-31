`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Connections in the 2nd convolutional layer are not as trivial
    In the prior layer, S2, the first max pooling layer, there are 6x14x14 feature maps
    In this convolutional layer, there are 16 feature maps. The feature maps of S2 are
    tied to each map of this convolutional layer, C3, are as follows:
    Map 0:  0, 1, 2
    Map 1:  1, 2, 3
    Map 2:  2, 3, 4
    Map 3:  3, 4, 5
    Map 4:  0, 4, 5
    Map 5:  0, 1, 5
    Map 6:  0, 1, 2, 3
    Map 7:  1, 2, 3, 4
    Map 8:  2, 3, 4, 5
    Map 9:  0, 3, 4, 5
    Map 10: 0, 1, 4, 5
    Map 11: 0, 1, 2, 5
    Map 12: 0, 1, 3, 4
    Map 13: 1, 2, 4, 5
    Map 14: 0, 2, 3, 5
    Map 15: 0, 1, 2, 3, 4, 5
    
    There are 6*(3*5*5 + 1) + 9*(4*5*5 + 1) + 6*5*5 + 1 = 1516 trainable parameters
    
    Total * operations = 6*10*10*5*5*3 + 9*10*10*5*5*4 + 10*10*5*5*6 = 10*10*(1516-16) = 150000
    
    The Artix-7 35 device has 90 DSP48s.
    We will have all 90 DSPs available as with the current architecture, all 90 DSPs will be free for conv2.
    150000/90 = 1666.67 = 1667 clock cycles worth of full DSP48 utilization.
    
    DSP distribution:
    First process the 3*5*5 maps (6 maps, 90/6 = 15 DSP48s per map)
    second process the 4*5*5 maps (9 maps, 90/9 = 10 DSP48s per map),
    third process the 6*5*5 map (1 map, 90 DSPs used for this map)
    
    Adder tree structures:
    3*5*5 maps
        15
        8 + 15
        12 + 15
        14 + 15
        15 + 15
        15
        8
        4
        2
        1
    
    4*5*5 maps
        10
        5 + 10
        8 + 10
        9 + 10
        10 + 10
        10 + 10
        10 + 10
        10 + 10
        10 + 10
        10 + 10
        10
        5
        3
        2
        1
        
    6*5*5 map (3 adder tree structures here, because 90 (DSPs) is not a factor of the # of * ops per feature (150)
    Tree structure 1
        90
        45 + 60
        53
        27
        14
        7
        4
        2
        1
        
    Tree structure 2
        30
        15 + 90
        53 + 30
        42
        21
        11
        6
        3
        2
        1
        
    Tree structure 3
        60
        30 + 90
        60
        30
        15
        8
        4
        2
        1
        
    We might need to be smarter, lots of unique adder tree structures across the 2 conv layers alone
    
    FSMs:
    
*/

//////////////////////////////////////////////////////////////////////////////////

module conv2(
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic               i_feature_valid,
    input  logic         [7:0] i_feature,
    output logic               o_feature_valid,
    output logic signed [15:0] o_features
);

    localparam WEIGHTS_FILE3MAP = "conv2_weights3map.mem";
    localparam WEIGHTS_FILE4MAP = "conv2_weights4map.mem";
    localparam WEIGHTS_FILE6MAP = "conv2_weights6map.mem";
    localparam BIASES_FILE      = "conv2_biases.mem";
    localparam INPUT_WIDTH      = 14;
    localparam INPUT_HEIGHT     = 14;
    localparam FILTER_SIZE      = 5;

    localparam WINDOW_AREA   = FILTER_SIZE * FILTER_SIZE;
    localparam OUTPUT_HEIGHT = INPUT_HEIGHT - FILTER_SIZE + 1;
    localparam OUTPUT_WIDTH  = INPUT_WIDTH - FILTER_SIZE + 1;
    localparam ROW_START     = FILTER_SIZE/2;
    localparam ROW_END       = INPUT_HEIGHT - FILTER_SIZE/2 - 1;
    localparam COL_START     = FILTER_SIZE/2;
    localparam COL_END       = INPUT_WIDTH - FILTER_SIZE/2 - 1;
    
    // Initialize trainable parameters
    // 3 S2 map connections weights
    (* rom_style = "block" *) logic signed [15:0]
    weights3map [5:0][2:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    initial $readmemb(WEIGHTS_FILE3MAP, weights3map);
    // 4 S2 map connections weights
    (* rom_style = "block" *) logic signed [15:0]
    weights4map [8:0][3:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    initial $readmemb(WEIGHTS_FILE4MAP, weights4map);
    // 6 S2 map connections weights
    (* rom_style = "block" *) logic signed [15:0]
    weights6map [5:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    initial $readmemb(WEIGHTS_FILE6MAP, weights6map);
    // Biases (1 bias per C3 feature map)
    (* rom_style = "block" *) logic signed [15:0]
    biases [NUM_FILTERS-1:0];
    initial $readmemb(BIASES_FILE, biases);
    
    
    logic               macc_en;
    
    logic         [7:0] line_buffer[FILTER_SIZE:0][COL_END-1:0];
    
    // Indexed features to be used for * operation
    logic         [7:0] feature_operands[FILTER_SIZE-1:0][2:0];
    logic signed  [7:0] weight_operands[NUM_FILTERS-1:0][FILTER_SIZE-1:0][2:0];
    
    // Line buffer location
    logic [$clog2(ROW_END)-1:0] lb_row_ctr;
    logic [$clog2(COL_END)-1:0] lb_col_ctr;
    
    // Feature conv location
    logic [$clog2(ROW_END)-1:0] feat_row_ctr;
    logic [$clog2(COL_END)-1:0] feat_col_ctr;
    
    // Line buffer full flag
    logic               lb_full;
    
    // Move to next row of output features
    logic               next_row;
    
    
    // Adder tree valid signals implemented as SRL16
    logic         [6:0] adder_tree_valid_sr[2:0];
    // Adder tree stage depths
    // TODO: Add in bias at some stage for each of the adder stree structures
    // 3-Map adder structure
    logic signed [23:0] adder3map_stage1[5:0][14:0];
    logic signed [23:0] adder3map_stage2[5:0][22:0];
    logic signed [23:0] adder3map_stage3[5:0][26:0];
    logic signed [23:0] adder3map_stage4[5:0][28:0];
    logic signed [23:0] adder3map_stage5[5:0][29:0];
    logic signed [23:0] adder3map_stage6[5:0][14:0];
    logic signed [23:0] adder3map_stage7[5:0][7:0];
    logic signed [23:0] adder3map_stage8[5:0][3:0];
    logic signed [23:0] adder3map_stage9[5:0][1:0];
    logic signed [23:0] adder3map_result[5:0];
    // 4-Map adder tree structure
    logic signed [23:0] adder4map_stage1[8:0][9:0];
    logic signed [23:0] adder4map_stage2[8:0][14:0];
    logic signed [23:0] adder4map_stage3[8:0][17:0];
    logic signed [23:0] adder4map_stage4[8:0][18:0];
    logic signed [23:0] adder4map_stage5[8:0][29:0];
    logic signed [23:0] adder4map_stage6[8:0][19:0];
    logic signed [23:0] adder4map_stage7[8:0][19:0];
    logic signed [23:0] adder4map_stage8[8:0][19:0];
    logic signed [23:0] adder4map_stage9[8:0][19:0];
    logic signed [23:0] adder4map_stage10[8:0][19:0];
    logic signed [23:0] adder4map_stage11[8:0][19:0];
    logic signed [23:0] adder4map_stage12[8:0][9:0];
    logic signed [23:0] adder4map_stage13[8:0][4:0];
    logic signed [23:0] adder4map_stage14[8:0][2:0];
    logic signed [23:0] adder4map_stage15[8:0][1:0];
    logic signed [23:0] adder4map_result[8:0];
    // 6-Map adder tree structures
    logic signed [23:0] adder6map_struct1_stage1[89:0];
    logic signed [23:0] adder6map_struct1_stage2[104:0];
    logic signed [23:0] adder6map_struct1_stage3[52:0];
    logic signed [23:0] adder6map_struct1_stage4[26:0];
    logic signed [23:0] adder6map_struct1_stage5[13:0];
    logic signed [23:0] adder6map_struct1_stage6[6:0];
    logic signed [23:0] adder6map_struct1_stage7[3:0];
    logic signed [23:0] adder6map_struct1_stage8[1:0];
    logic signed [23:0] adder6map_struct1_result;
    logic signed [23:0] adder6map_struct2_stage1[29:0];
    logic signed [23:0] adder6map_struct2_stage2[104:0];
    logic signed [23:0] adder6map_struct2_stage3[82:0];
    logic signed [23:0] adder6map_struct2_stage4[41:0];
    logic signed [23:0] adder6map_struct2_stage5[20:0];
    logic signed [23:0] adder6map_struct2_stage6[10:0];
    logic signed [23:0] adder6map_struct2_stage7[5:0];
    logic signed [23:0] adder6map_struct2_stage8[2:0];
    logic signed [23:0] adder6map_struct2_stage9[1:0];
    logic signed [23:0] adder6map_struct2_result;
    logic signed [23:0] adder6map_struct3_stage1[59:0];
    logic signed [23:0] adder6map_struct3_stage2[119:0];
    logic signed [23:0] adder6map_struct3_stage3[59:0];
    logic signed [23:0] adder6map_struct3_stage4[29:0];
    logic signed [23:0] adder6map_struct3_stage5[14:0];
    logic signed [23:0] adder6map_struct3_stage6[7:0];
    logic signed [23:0] adder6map_struct3_stage7[3:0];
    logic signed [23:0] adder6map_struct3_stage8[1:0];
    logic signed [23:0] adder6map_struct3_result;
    
    // MACC accumulate, 4 deep to hold at least 9 accumates during the 4-map convolutions
    logic signed [23:0] macc_acc[3:0];
    // Register outputs of DSPs
    // TODO: Flatten
    logic signed [23:0] mult_out[NUM_FILTERS-1:0][FILTER_SIZE*3-1:0];
    
    typedef enum logic [1:0] {
        THREE_MAP, FOUR_MAP, SIX_MAP
    } state_xmap_t;
    state_xmap_t state_xmap, next_state_xmap;
    
    // 5 state MACC sequence for 3-Map connections
    typedef enum logic [2:0] {
        ONE_3m, TWO_3m, THREE_3m, FOUR_3m, FIVE_3m
    } state3m_t;
    state3m_t state3m, next_state3m;
    
    // 10 state MACC sequence for 4-Map connections
    typedef enum logic [3:0] {
        ONE_4m, TWO_4m, THREE_4m, FOUR_4m, FIVE_4m, SIX_4m, SEVEN_4m, EIGHT_4m, NINE_4m, TEN_4m
    } state4m_t;
    state4m_t state4m, next_state4m;
    
    // 5 state MACC sequence for 6-Map connections
    typedef enum logic [2:0] {
        ONE_6m, TWO_6m, THREE_6m, FOUR_6m, FIVE_6m
    } state6m_t;
    state6m_t state6m, next_state6m;
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst) begin
            state_xmap <= THREE_MAP;
            state3m    <= ONE_3m;
            state4m    <= ONE_4m;
            state6m    <= ONE_6m;
        end else begin
            state_xmap <= next_state_xmap;
            state3m    <= next_state3m;
            state4m    <= next_state4m;
            state6m    <= next_state6m;
        end
    end
    
    always_comb begin
        // Default, override when MACC enabled
        next_state_xmap = THREE_MAP;
        next_state3m    = ONE_3m;
        next_state4m    = ONE_4m;
        next_state6m    = ONE_6m;
        if (macc_en) begin
            next_state_xmap = next_state_xmap;
            case(state_xmap)
                THREE_MAP: begin
                    case(state3m)
                        ONE_3m: begin
                            next_state3m = TWO_3m;
                        end
                        TWO_3m: begin
                            next_state3m = THREE_3m;
                        end
                        THREE_3m: begin
                            next_state3m = FOUR_3m;
                        end
                        FOUR_3m: begin
                            next_state3m = FIVE_3m;
                        end
                        FIVE_3m: begin
                            next_state3m = ONE_3m;
                            if (feat_row_ctr == ROW_END && feat_col_ctr == COL_END)
                                next_state_xmap = FOUR_MAP;
                        end
                    endcase
                end
                FOUR_MAP: begin
                    case(state4m)
                        ONE_3m: begin
                            next_state4m = TWO_4m;
                        end
                        TWO_3m: begin
                            next_state4m = THREE_4m;
                        end
                        THREE_3m: begin
                            next_state4m = FOUR_4m;
                        end
                        FOUR_3m: begin
                            next_state4m = FIVE_4m;
                        end
                        FIVE_3m: begin
                            next_state4m = SIX_4m;
                        end
                        SIX_4m: begin
                            next_state4m = SEVEN_4m;
                        end
                        SEVEN_4m: begin
                            next_state4m = EIGHT_4m;
                        end
                        EIGHT_4m: begin
                            next_state4m = NINE_4m;
                        end
                        NINE_4m: begin
                            next_state4m = TEN_4m;
                        end
                        TEN_4m: begin
                            next_state4m = ONE_4m;
                            if (feat_row_ctr == ROW_END && feat_col_ctr == COL_END)
                                next_state_xmap = SIX_MAP;
                        end
                    endcase
                end
                SIX_MAP: begin
                    case(state6m)
                        ONE_6m: begin
                            next_state6m = TWO_6m;
                        end
                        TWO_6m: begin
                            next_state6m = THREE_6m;
                        end
                        THREE_6m: begin
                            next_state6m = FOUR_6m;
                        end
                        FOUR_6m: begin
                            next_state6m = FIVE_6m;
                        end
                        FIVE_6m: begin
                            next_state6m = ONE_6m;
                            // Do we need to go back to 3-maps? or just disable macc enable?
                            if (feat_row_ctr == ROW_END && feat_col_ctr == COL_END)
                                next_state_xmap = THREE_MAP;
                        end
                    endcase
                end
               default: next_state_xmap = next_state_xmap;
            endcase
        end
    end
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst) begin
            feat_row_ctr <= ROW_START;
            feat_col_ctr <= COL_START;
        end else begin
            feat_col_ctr <= feat_col_ctr + 1;
            if (feat_col_ctr == COL_END) begin
                feat_col_ctr <= 0;
                feat_row_ctr <= feat_row_ctr == COL_END ? 0: feat_row_ctr + 1;
            end
        end
    end

endmodule