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
    localparam INPUT_CHANNELS   = 6;
    localparam INPUT_WIDTH      = 14;
    localparam INPUT_HEIGHT     = 14;
    localparam FILTER_SIZE      = 5;
    
    localparam WINDOW_AREA   = FILTER_SIZE * FILTER_SIZE;
    localparam OUTPUT_HEIGHT = INPUT_HEIGHT - FILTER_SIZE + 1;
    localparam OUTPUT_WIDTH  = INPUT_WIDTH - FILTER_SIZE + 1;
    
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
    
    // Indexed features to be used for * operation
    logic        [7:0] feature_operands[FILTER_SIZE-1:0][2:0];
    logic signed [7:0] weight_operands[NUM_FILTERS-1:0][FILTER_SIZE-1:0][2:0];
    
    // We're just going to use BRAM here to store features
    // Can and probably should do the same thing for conv1, and throughout design in general
    logic [INPUT_HEIGHT-1:0] ram_row_ctr;
    logic [INPUT_WIDTH-1:0]  ram_col_ctr;
    // Can use 6xRAM196 => 6*3=18 LUTs, or an 18-Kb Block RAM
    logic signed [15:0] feature_ram[INPUT_CHANNELS-1:0][INPUT_HEIGHT-1:0][INPUT_WIDTH-1:0];
    // Feature RAM full flag
    logic ram_full;
    
    // Feature conv location
    logic [INPUT_HEIGHT-1:0] feat_row_ctr;
    logic [INPUT_WIDTH-1:0] feat_col_ctr;
    
    // Move to next row of output features
    logic next_row;
    // Enable MACC after 5 rows have been filled
    logic macc_en;
    
    // Adder tree valid signals implemented as SRL16
    logic [6:0] adder_tree_valid_sr[2:0];
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
    logic signed [23:0] adder4map_stage5[8:0][19:0];
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
    logic signed [23:0] mult_out[89:0];
    logic signed [23:0] mult_out_6part[5:0][14:0];
    logic signed [23:0] mult_out_9part[8:0][9:0];
    
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
    
    always_comb
    begin
        // A few different DSP out wires so its easier to work with when performing operations in the adder tree
        for (int i = 0; i < 6; i++)
            mult_out_6part[i] = mult_out[i*15+14:i*15];
        for (int i = 0; i < 9; i++)
            mult_out_9part[i] = mult_out[i*10+9:i*10];
        
        // Time multiplexing DSP48 operations, mapping operands based on states
        case(state_xmap)
            THREE_MAP: begin
                case(state3m)
                    ONE_3m: begin
                        
                    end
                    TWO_3m: begin
                        
                    end
                    THREE_3m: begin
                        
                    end
                    FOUR_3m: begin
                        
                    end
                    FIVE_3m: begin
                        
                    end
                endcase
            end
            FOUR_MAP: begin
                case(state4m)
                    ONE_3m: begin
                        
                    end
                    TWO_3m: begin
                        
                    end
                    THREE_3m: begin
                        
                    end
                    FOUR_3m: begin
                        
                    end
                    FIVE_3m: begin
                        
                    end
                    SIX_4m: begin
                        
                    end
                    SEVEN_4m: begin
                        
                    end
                    EIGHT_4m: begin
                        
                    end
                    NINE_4m: begin
                        
                    end
                    TEN_4m: begin
                        
                    end
                endcase
            end
            SIX_MAP: begin
                case(state6m)
                    ONE_6m: begin
                        
                    end
                    TWO_6m: begin
                        
                    end
                    THREE_6m: begin
                        
                    end
                    FOUR_6m: begin
                        
                    end
                    FIVE_6m: begin
                        
                    end
                endcase
            end
        endcase
    end
    
    // Use some wires for the multouts array structure based on different adder tree structures
    always_ff @(posedge i_clk)
    begin
        if (macc_en) begin
            for (int i = 0; i < 6; i++) begin
                adder3map_stage1[i][14:0] <= mult_out[i][14:0];
                
                adder3map_stage2[i][22] <= adder3map_stage1[i][15] + biases[i];
                for (int j = 0; j < 7; j++)
                    adder3map_stage2[i][j+15] <= adder3map_stage1[i][j*2] + adder3map_stage1[i][j*2+1];
                adder3map_stage2[i][14:0] <= mult_out[i][14:0];
                
                adder3map_stage3[i][26] <= adder3map_stage2[i][22];
                for (int j = 0; j < 11; j++)
                    adder3map_stage3[i][j+15] <= adder3map_stage2[i][j*2] + adder3map_stage2[i][j*2+1];
                adder3map_stage3[i][14:0] <= mult_out[i][14:0];
                
                adder3map_stage4[i][28] <= adder3map_stage3[i][26];
                for (int j = 0; j < 13; j++)
                    adder3map_stage4[i][j+15] <= adder3map_stage3[i][j*2] + adder3map_stage3[i][j*2+1];
                adder3map_stage4[i][14:0] <= mult_out[i][14:0];
                
                adder3map_stage5[i][29] <= adder3map_stage4[i][28];
                for (int j = 0; j < 14; j++)
                    adder3map_stage5[i][j+15] <= adder3map_stage4[i][j*2] + adder3map_stage4[i][j*2+1];
                adder3map_stage5[i][14:0] <= mult_out[i][14:0];
                
                for (int j = 0; j < 15; j++)
                    adder3map_stage6[i][j] <= adder3map_stage5[i][j*2] + adder3map_stage5[i][j*2+1];
                
                adder3map_stage7[i][7] <= adder3map_stage6[i][14];
                for (int j = 0; j < 7; j++)
                    adder3map_stage7[i][j] <= adder3map_stage6[i][j*2] + adder3map_stage6[i][j*2+1];
                
                for (int j = 0; j < 4; j++)
                    adder3map_stage8[i][j] <= adder3map_stage7[i][j*2] + adder3map_stage7[i][j*2+1];
                
                for (int j = 0; j < 2; j++)
                    adder3map_stage9[i][j] <= adder3map_stage8[i][j*2] + adder3map_stage8[i][j*2+1];
                
                adder3map_result[i] = adder3map_stage9[i][1] + adder3map_stage9[i][0];
            end
            
            for (int i = 0; i < 9; i++) begin
                adder4map_stage1[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 5; j++)
                    adder4map_stage2[i][j+10] <= adder4map_stage1[i][j*2] + adder4map_stage1[i][j*2+1];
                adder4map_stage2[i][9:0] <= mult_out[i][9:0];
                
                adder4map_stage3[i][17] <= adder4map_stage2[i][14] + biases[i+6];
                for (int j = 0; j < 7; j++)
                    adder4map_stage3[i][j+10] <= adder4map_stage2[i][j*2] + adder4map_stage2[i][j*2+1];
                adder4map_stage3[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 9; j++)
                    adder4map_stage4[i][j+10] <= adder4map_stage3[i][j*2] + adder4map_stage3[i][j*2+1];
                adder4map_stage4[i][9:0] <= mult_out[i][9:0];
                
                adder4map_stage5[i][19] <= adder4map_stage4[i][18];
                for (int j = 0; j < 9; j++)
                    adder4map_stage5[i][j+10] <= adder4map_stage4[i][j*2] + adder4map_stage4[i][j*2+1];
                adder4map_stage5[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 10; j++)
                    adder4map_stage6[i][j+10] <= adder4map_stage5[i][j*2] + adder4map_stage5[i][j*2+1];
                adder4map_stage6[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 10; j++)
                    adder4map_stage7[i][j+10] <= adder4map_stage6[i][j*2] + adder4map_stage6[i][j*2+1];
                adder4map_stage7[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 10; j++)
                    adder4map_stage8[i][j+10] <= adder4map_stage7[i][j*2] + adder4map_stage7[i][j*2+1];
                adder4map_stage8[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 10; j++)
                    adder4map_stage9[i][j+10] <= adder4map_stage8[i][j*2] + adder4map_stage8[i][j*2+1];
                adder4map_stage9[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 10; j++)
                    adder4map_stage10[i][j+10] <= adder4map_stage9[i][j*2] + adder4map_stage9[i][j*2+1];
                adder4map_stage10[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 10; j++)
                    adder4map_stage11[i][j+10] <= adder4map_stage10[i][j*2] + adder4map_stage10[i][j*2+1];
                adder4map_stage11[i][9:0] <= mult_out[i][9:0];
                
                for (int j = 0; j < 10; j++)
                    adder4map_stage12[i][j] <= adder4map_stage11[i][j*2] + adder4map_stage11[i][j*2+1];
                
                for (int j = 0; j < 5; j++)
                    adder4map_stage13[i][j] <= adder4map_stage12[i][j*2] + adder4map_stage12[i][j*2+1];
                
                adder4map_stage14[i][2] <= adder4map_stage13[i][4];
                for (int j = 0; j < 2; j++)
                    adder4map_stage14[i][j] <= adder4map_stage13[i][j*2] + adder4map_stage13[i][j*2+1];
                
                adder4map_stage15[i][2] <= adder4map_stage14[i][2];
                adder4map_stage15[i][1] <= adder4map_stage14[i][1] + adder4map_stage14[i][0];
                    
                adder4map_result[i] <= adder4map_stage15[i][1] + adder4map_stage15[i][0];
            end
            
            adder6map_struct1_stage1[89:0] <= mult_out;
            
            for (int i = 0; i < 45; i++)
                adder6map_struct1_stage2[i+60] <= adder6map_struct1_stage1[i*2] + adder6map_struct1_stage1[i*2+1];
            adder6map_struct1_stage2[59:0] <= mult_out[59:0];
            
            adder6map_struct1_stage3[52] <= adder6map_struct1_stage2[104] + biases[15];
            for (int i = 0; i < 52; i++)
                adder6map_struct1_stage3[i] <= adder6map_struct1_stage2[i*2] + adder6map_struct1_stage2[i*2+1];
            
            adder6map_struct1_stage4[26] <= adder6map_struct1_stage3[52];
            for (int i = 0; i < 26; i++)
                adder6map_struct1_stage4[i] <= adder6map_struct1_stage3[i*2] + adder6map_struct1_stage3[i*2+1];
            
            adder6map_struct1_stage5[13] <= adder6map_struct1_stage4[26];
            for (int i = 0; i < 13; i++)
                adder6map_struct1_stage5[i] <= adder6map_struct1_stage4[i*2] + adder6map_struct1_stage4[i*2+1];
            
            for (int i = 0; i < 7; i++)
                adder6map_struct1_stage6[i] <= adder6map_struct1_stage5[i*2] + adder6map_struct1_stage5[i*2+1];
            
            adder6map_struct1_stage7[3] <= adder6map_struct1_stage6[6];
            for (int i = 0; i < 3; i++)
                adder6map_struct1_stage7[i] <= adder6map_struct1_stage6[i*2] + adder6map_struct1_stage6[i*2+1];
            
            for (int i = 0; i < 2; i++)
                adder6map_struct1_stage8[i] <= adder6map_struct1_stage7[i*2] + adder6map_struct1_stage7[i*2+1];
                
            adder6map_struct1_result <= adder6map_struct1_stage8[1] + adder6map_struct1_stage8[0];
            
            adder6map_struct2_stage1[29:0] <= mult_out[89:60];
            
            for (int i = 0; i < 15; i++)
                adder6map_struct2_stage2[i+90] <= adder6map_struct2_stage1[i*2] + adder6map_struct2_stage1[i*2+1];
            adder6map_struct2_stage2 <= mult_out;
            
            adder6map_struct2_stage3[82] <= adder6map_struct2_stage2[104] + biases[15];
            for (int i = 0; i < 52; i++)
                adder6map_struct2_stage3[i+30] <= adder6map_struct2_stage2[i*2] + adder6map_struct2_stage2[i*2+1];
            adder6map_struct2_stage3 <= mult_out[29:0];
            
            adder6map_struct2_stage4[41] <= adder6map_struct2_stage3[82];
            for (int i = 0; i < 41; i++)
                adder6map_struct2_stage4[i] <= adder6map_struct2_stage3[i*2] + adder6map_struct2_stage3[i*2+1];
            
            for (int i = 0; i < 21; i++)
                adder6map_struct2_stage5[i] <= adder6map_struct2_stage4[i*2] + adder6map_struct2_stage4[i*2+1];
            
            adder6map_struct2_stage6[10] <= adder6map_struct2_stage5[20];
            for (int i = 0; i < 10; i++)
                adder6map_struct2_stage6[i] <= adder6map_struct2_stage5[i*2] + adder6map_struct2_stage5[i*2+1];
            
            adder6map_struct2_stage7[5] <= adder6map_struct2_stage6[10];
            for (int i = 0; i < 5; i++)
                adder6map_struct2_stage7[i] <= adder6map_struct2_stage6[i*2] + adder6map_struct2_stage6[i*2+1];
            
            for (int i = 0; i < 3; i++)
                adder6map_struct2_stage8[i] <= adder6map_struct2_stage7[i*2] + adder6map_struct2_stage7[i*2+1];
            
            adder6map_struct2_stage9[1] <= adder6map_struct2_stage8[2];
            adder6map_struct2_stage9[0] <= adder6map_struct2_stage8[1] + adder6map_struct2_stage8[0];
            
            adder6map_struct2_result <= adder6map_struct2_stage9[1] + adder6map_struct2_stage9[0];
            
            adder6map_struct3_stage1[59:0] <= mult_out[89:30];
            
            for (int i = 0; i < 30; i++)
                adder6map_struct3_stage2[i+90] <= adder6map_struct3_stage1[i*2] + adder6map_struct3_stage1[i*2+1];
            adder6map_struct3_stage2[89:0] <= mult_out;
            
            for (int i = 0; i < 60; i++)
                adder6map_struct3_stage3[i] <= adder6map_struct3_stage2[i*2] + adder6map_struct3_stage2[i*2+1];
            
            for (int i = 0; i < 30; i++)
                adder6map_struct3_stage4[i] <= adder6map_struct3_stage3[i*2] + adder6map_struct3_stage3[i*2+1];
            
            for (int i = 0; i < 15; i++)
                adder6map_struct3_stage5[i] <= adder6map_struct3_stage4[i*2] + adder6map_struct3_stage4[i*2+1];
            
            adder6map_struct3_stage6[7] <= adder6map_struct3_stage5[14] + biases[15];
            for (int i = 0; i < 7; i++)
                adder6map_struct3_stage6[i] <= adder6map_struct3_stage5[i*2] + adder6map_struct3_stage5[i*2+1];
            
            for (int i = 0; i < 4; i++)
                adder6map_struct3_stage7[i] <= adder6map_struct3_stage6[i*2] + adder6map_struct3_stage6[i*2+1];
            
            for (int i = 0; i < 2; i++)
                adder6map_struct3_stage8[i] <= adder6map_struct3_stage7[i*2] + adder6map_struct3_stage7[i*2+1];
            
            adder6map_struct3_result <= adder6map_struct3_stage8[1] + adder6map_struct3_stage8[0];
        end
    end
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst) begin
            ram_row_ctr <= 'b0;
            ram_col_ctr <= 'b0;
            ram_full    <= 0;
            macc_en     <= 0;
        end else begin
            if (i_feature_valid) begin
                for (int i = 0; i < INPUT_CHANNELS; i++) begin
                    feature_ram[i][ram_row_ctr][ram_col_ctr] <= i_features[i];
                ram_col_ctr <= ram_col_ctr + 1;
                if (ram_col_ctr == INPUT_WIDTH-1)
                    ram_row_ctr <= ram_row_ctr + 1;
                if (ram_row_ctr[2] & ram_row_ctr[0])
                    macc_en <= 1;
                // What logic is going to use the RAM full flag?
                if (ram_row_ctr == INPUT_HEIGHT-1 && ram_col_ctr == INPUT_WIDTH-1)
                    ram_full <= 1;
            end
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