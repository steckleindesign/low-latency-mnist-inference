`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    TODO: Determine how to fit in the +bias operation
            -See if we can do it in DSP48 without hurting max clock frequency
            -See the max clock frequency penalty when implemented in fabric
          
          90 DSPS, 50 BRAMS (36Kb each)
          6 filters for conv1, 5x5 filter (25 * ops), 28x28 conv ops (784)
          = 6*(5*5)*(28*28) = 117600 * ops / 90 DSPs = 1306.6 = 1307 cycs theoretically
          
          Going to skip the last 2 columns (which are all 0's) so we can efficiently complete
          each row's * operations without a remainder of DSPs
          Will take us 46 clock cycles per row this way => (6*28*5*5 - 6*5*2) / 90 = 46
          Note that there are still improvements to be made, still many static 0's on
          the edges that we waste MACC (DSP) operations on
          
          // Accumulation architecture (adder tree) - research additional adder structures
          // 5*5=25 accumulations per output feature, but only 15 * operations for
          // a given output feature execute in a single clock cycle.
          // 15 DSP outputs will take clog2(15)=4 clock cycles to add together.
          // For each feature out, there will be a latency of 7 clock cycles (computed on paper notes)
          // Study how to get outputs of DSP48s to carry chain resources efficiently
          
*/
//////////////////////////////////////////////////////////////////////////////////

module conv1 #(
    parameter string WEIGHTS_FILE = "weights.mem",
    parameter string BIASES_FILE  = "biases.mem",
    parameter        INPUT_WIDTH  = 32,
    parameter        INPUT_HEIGHT = 32,
    parameter        FILTER_SIZE  = 5,
    parameter        NUM_FILTERS  = 6
) (
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic               i_feature_valid,
    // For now we are just preloading pixels from RAM,
    // So i_feature will be reading from a full RAM of pixels,
    // No CDC needed, a new feature is available each clock cycle
    input  logic         [7:0] i_feature,
    output logic               o_feature_valid,
    output logic signed [15:0] o_feature,
    // Letting pixel RAM know we can't take in any data
    output logic               o_buffer_full
);

    // we don't want to waste cycles on multiplying with 0s (whether 0 pixel/feature or outer rings)
    // ^ is it worth it to compare and skip features in single clock cycle to avoid *0 ?
    // The muxing implemented in fabric will probably take too much space, so will need to use DSP48 mux

    // Computed local params from module parameters
    localparam WINDOW_AREA   = FILTER_SIZE * FILTER_SIZE;
    localparam OUTPUT_HEIGHT = INPUT_HEIGHT - FILTER_SIZE + 1;
    localparam OUTPUT_WIDTH  = INPUT_WIDTH - FILTER_SIZE + 1;
    localparam ROW_START     = FILTER_SIZE/2;
    localparam ROW_END       = INPUT_HEIGHT - FILTER_SIZE/2 - 1;
    localparam COL_START     = FILTER_SIZE/2;
    localparam COL_END       = INPUT_WIDTH - FILTER_SIZE/2 - 1;
    
    // Initialize trainable parameters
    // Weights
    (* rom_style = "block" *) logic signed [15:0]
    weights [NUM_FILTERS-1:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    (* rom_style = "block" *) logic signed [15:0]
    biases [NUM_FILTERS-1:0];
    initial $readmemb(BIASES_FILE, biases);

    // For height=5 filter, we only need to store 4 rows of pixel data
    // For now we will starting MACC operations once line buffer is full
    // Also we will use a line buffer with FILTER_SIZE rows, 5 rows in our case
    // Again, we are not using the last 2 columns in this iteration (all 0's so its viable)
    logic         [7:0] line_buffer[FILTER_SIZE-1:0][COL_END:0];
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
    // Is it ok to go FSM-less and just use this MACC enable?
    logic               macc_en;
    // Keep track of row count direction, we zig zag rows (Do we actually gain any efficiency this way?)
    logic               row_cnt_direction;
    // Adder tree valid signals implemented as SRL16
    logic         [6:0] adder_tree_valid_sr[2:0];
    // Adder tree stage depths
    // TODO: Determine proper bitwidths for adder stages 
    logic signed [23:0] adder1_stage1[NUM_FILTERS-1:0][14:0]; // 15 dsp outs
    logic signed [23:0] adder1_stage2[NUM_FILTERS-1:0][17:0]; // 8 adder outs from stage 1 + 10 dsp outs
    logic signed [23:0] adder1_stage3[NUM_FILTERS-1:0][8:0];  // 9 adder outs from stage 2
    logic signed [23:0] adder1_stage4[NUM_FILTERS-1:0][4:0];  // 5 adder outs from stage 3
    logic signed [23:0] adder1_stage5[NUM_FILTERS-1:0][2:0];  // 3 adder outs from stage 4
    logic signed [23:0] adder1_stage6[NUM_FILTERS-1:0][1:0];  // 2 adder outs from stage 5
    logic signed [23:0] adder2_stage1[NUM_FILTERS-1:0][4:0];  // 5 dsp outs
    logic signed [23:0] adder2_stage2[NUM_FILTERS-1:0][17:0]; // 3 adder outs from stage 1 + 15 dsp outs
    logic signed [23:0] adder2_stage3[NUM_FILTERS-1:0][13:0]; // 9 adder outs from stage 2 + 5 dsp outs
    logic signed [23:0] adder2_stage4[NUM_FILTERS-1:0][6:0];  // 7 adder outs from stage 3
    logic signed [23:0] adder2_stage5[NUM_FILTERS-1:0][3:0];  // 4 adder outs from stage 4
    logic signed [23:0] adder2_stage6[NUM_FILTERS-1:0][1:0];  // 2 adder outs from stage 5
    logic signed [23:0] adder3_stage1[NUM_FILTERS-1:0][9:0];  // 10 dsp outs
    logic signed [23:0] adder3_stage2[NUM_FILTERS-1:0][19:0]; // 5 adder outs from stage 1 + 15 dsp outs
    logic signed [23:0] adder3_stage3[NUM_FILTERS-1:0][9:0];  // 10 adder outs from stage 2
    logic signed [23:0] adder3_stage4[NUM_FILTERS-1:0][4:0];  // 5 adder outs from stage 3
    logic signed [23:0] adder3_stage5[NUM_FILTERS-1:0][2:0];  // 3 adder outs from stage 4
    logic signed [23:0] adder3_stage6[NUM_FILTERS-1:0][1:0];  // 2 adder outs from stage 5
    
    // Is 16-wide ok?
    logic signed [15:0] macc_accum[NUM_FILTERS-1:0];
    // Register outputs of DSPs
    // TODO: Flatten
    logic signed [23:0] mult_out[NUM_FILTERS-1:0][FILTER_SIZE-1:0][2:0];
    // 5 state MACC sequence throughout conv1 layer execution
    typedef enum logic [2:0] {
        ONE, TWO, THREE, FOUR, FIVE
    } state_t;
    state_t state, next_state;
    
    always_ff @(posedge i_clk) begin
        if (i_rst)
            state <= ONE;
        else
            state <= next_state;
    end
    
    always_comb begin
        if (macc_en) begin
            case(state)
                ONE:
                    next_state = TWO;
                    // 15 -> adder tree 1
                TWO:
                    next_state = THREE;
                    // 10 -> adder tree 1,
                    // 5  -> adder tree 2
                THREE:
                    next_state = FOUR;
                    // 15 -> adder tree 2
                FOUR:
                    next_state = (feat_col_ctr == COL_END) ? ONE : FIVE;
                    // 5  -> adder tree 2
                    // 10 -> adder tree 3
                FIVE:
                    next_state = ONE;
                    // 15 -> adder tree 3
            endcase
                next_state = ONE;
    end
    
//    always_ff @(posedge i_clk) begin
//        if (macc_en) begin
//            case(state)
//                ONE:
//                    // 15 -> adder tree 1
//                TWO:
//                    // 10 -> adder tree 1,
//                    // 5  -> adder tree 2
//                THREE:
//                    // 15 -> adder tree 2
//                FOUR:
//                    // 5  -> adder tree 2
//                    // 10 -> adder tree 3
//                FIVE:
//                    // 15 -> adder tree 3
//            endcase
//        end
//        adder_tree_valid_sr <= { adder_tree_valid_sr[0][5:0], state == ONE  };
//        adder_tree_valid_sr <= { adder_tree_valid_sr[1][5:0], state == TWO  };
//        adder_tree_valid_sr <= { adder_tree_valid_sr[2][5:0], state == FOUR };
//    end
    
    // Register DSP outputs
    // Flatten mult out outputs, or fix indexing at least so its easier to use with adder tree
    always_ff @(posedge i_clk)
        for (int i = 0; i < NUM_FILTERS; i++)
            for (int j = 0; j < 5; j++)
                for (int k = 0; k < 3; k++)
                    mult_out[i][j][k] <= weight_operands[i][j][k] * feature_operands[j][k];
    
    // Only on MACC enable, not on first feature valid signal
    // This is because the very first clock cycle after valid data should only enable the DSP operation,
    // not the adder tree logic
    // (TODO: try to really understand clock enables vs. gating vs. if the macc_en is just treated as a logic variable)
    // TODO: adder tree valid signals
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            for (int i = 0; i < NUM_FILTERS; i++)
                // Adder tree structure 1
                adder1_stage1[i][14:10] <= mult_out[14:10];
                adder1_stage1[i][9:5]   <= mult_out[9:5];
                adder1_stage1[i][4:0]   <= mult_out[4:0];
                
                adder1_stage2[i][17]    <= adder1_stage1[15];
                for (int j = 0; j < 7; j++)
                    adder1_stage2[i][10+j] <= adder1_stage1[j*2] + adder1_stage1[j*2+1];
                adder1_stage2[9:5]      <= mult_out[9:5];
                adder1_stage2[4:0]      <= mult_out[4:0];
                
                for (int j = 0; j < 9; j++)
                    adder1_stage3[j] <= adder1_stage2[j*2] + adder1_stage2[j*2+1];
                
                // Can stage 4 5th reg just directly be connected to stage 6 1st reg?
                adder1_stage4[4]        <= adder1_stage3[8];
                for (int j = 0; j < 4; j++)
                    adder1_stage4[j] <= adder1_stage3[j*2] + adder1_stage3[j*2+1];
                    
                adder1_stage5[2]        <= adder1_stage4[4];
                for (int j = 0; j < 2; j++)
                    adder1_stage5[j] <= adder1_stage4[j*2] + adder1_stage4[j*2+1];
                    
                adder1_stage6[1] <= adder1_stage5[2];
                adder1_stage6[0] <= adder1_stage5[0] + adder1_stage5[1];
                
                // Adder tree structure 2
                adder2_stage1           <= mult_out[14:10];
                
                adder2_stage2[17]       <= adder2_stage1[4];
                for (int j = 0; j < 2; j++)
                    adder2_stage2[j] <= adder2_stage1[j*2] + adder2_stage1[j*2+1];
                adder2_stage2[i][14:10] <= mult_out[14:10];
                adder2_stage2[i][9:5]   <= mult_out[9:5];
                adder2_stage2[i][4:0]   <= mult_out[4:0];
                
                for (int j = 0; j < 9; j++)
                    adder2_stage3[j+5] <= adder2_stage2[j*2] + adder2_stage2[j*2+1];
                adder2_stage3[4:0]      <= mult_out[4:0];
                
                for (int j = 0; j < 7; j++)
                    adder2_stage4[j+5] <= adder2_stage3[j*2] + adder2_stage3[j*2+1];
                    
                adder2_stage5[3]        <= adder2_stage4[6];
                for (int j = 0; j < 3; j++)
                    adder2_stage5[j] <= adder2_stage4[j*2] + adder2_stage4[j*2+1];
                    
                for (int j = 0; j < 2; j++)
                    adder2_stage6[j+5] <= adder2_stage5[j*2] + adder2_stage5[j*2+1];
                    
                // Adder tree structure 3
                adder3_stage1[9:5]      <= mult_out[14:10];
                adder3_stage1[4:0]      <= mult_out[9:5];
                
                for (int j = 0; j < 5; j++)
                    adder3_stage2[j+15] <= adder3_stage1[j*2] + adder3_stage1[j*2+1];
                adder3_stage2[14:10]    <= mult_out[14:10];
                adder3_stage2[9:5]      <= mult_out[9:5];
                adder3_stage2[4:0]      <= mult_out[4:0];
                
                for (int j = 0; j < 10; j++)
                    adder3_stage3[j] <= adder3_stage2[j*2] + adder3_stage2[j*2+1];
                
                for (int j = 0; j < 5; j++)
                    adder3_stage4[j] <= adder3_stage3[j*2] + adder3_stage3[j*2+1];
                
                // Same principle as with adder tree structure 1, can we bring this signal down to stage 6 directly?
                adder3_stage5[2] <= adder3_stage4[4];
                for (int j = 0; j < 2; j++)
                    adder3_stage5[j] <= adder3_stage4[j*2] + adder3_stage4[j*2+1];
                    
                adder3_stage6[1] <= adder3_stage5[2];
                adder3_stage6[0] <= adder3_stage5[0] + adder3_stage5[1];
            end
        end
    end
    
    always_comb begin
        case(state)
            ONE: begin
                feature_operands[0] = line_buffer[feat_col_ctr-2];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][0] = weights[i][0];
                feature_operands[1] = line_buffer[feat_col_ctr-1];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][1] = weights[i][1];
                feature_operands[2] = line_buffer[feat_col_ctr  ];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][2] = weights[i][2];
            end
            TWO: begin
                feature_operands[0] = line_buffer[feat_col_ctr+1];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][0] = weights[i][3];
                feature_operands[1] = line_buffer[feat_col_ctr+2];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][1] = weights[i][4];
                feature_operands[2] = line_buffer[feat_col_ctr-1];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][2] = weights[i][0];
            end
            THREE: begin
                feature_operands[0] = line_buffer[feat_col_ctr-1];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][0] = weights[i][1];
                feature_operands[1] = line_buffer[feat_col_ctr  ];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][1] = weights[i][2];
                feature_operands[2] = line_buffer[feat_col_ctr+1];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][2] = weights[i][3];
            end
            FOUR: begin
                feature_operands[0] = line_buffer[feat_col_ctr+2];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][0] = weights[i][4];
                feature_operands[1] = line_buffer[feat_col_ctr-1];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][1] = weights[i][0];
                feature_operands[2] = line_buffer[feat_col_ctr  ];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][2] = weights[i][1];
            end
            FIVE: begin
                feature_operands[0] = line_buffer[feat_col_ctr  ];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][0] = weights[i][2];
                feature_operands[1] = line_buffer[feat_col_ctr+1];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][1] = weights[i][3];
                feature_operands[2] = line_buffer[feat_col_ctr+2];
                for (int i = 0; i < NUM_FILTERS; i++)
                    weight_operands[i][2] = weights[i][4];
            end
        endcase
    end
    
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            case(state)
                ONE: begin
                    
                end
                TWO: begin
                    feat_col_ctr <= feat_col_ctr + 1;
                    
                end
                THREE: begin
                    
                end
                FOUR: begin
                    if (feat_col_ctr == COL_END) begin
                        feat_row_ctr <= feat_row_ctr + 1;
                        feat_col_ctr <= 0;
                    end else
                        feat_col_ctr <= feat_col_ctr + 1;
                end
                FIVE: begin
                    feat_col_ctr <= feat_col_ctr + 1;
                    
                end
            endcase
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (i_rst)
            macc_en <= 0;
        else begin
            if (macc_en) begin
                lb_full <= lb_row_ctr == 3'd4 && lb_col_ctr == COL_END;
                if (feat_col_ctr == COL_END) begin
                    if (lb_row_ctr == ROW_END) begin
                        lb_col_ctr <= COL_START;
                        for (int i = 0; i < FILTER_SIZE-2; i++)
                            line_buffer[i] <= line_buffer[i+1];
                    end
                end else if (~lb_full) begin
                    line_buffer[lb_row_ctr][lb_col_ctr] <= i_feature;
                    if (lb_col_ctr == COL_END) begin
                        if (lb_row_ctr == 3'd4)
                            lb_full <= 1;
                        else begin
                            lb_col_ctr <= COL_START;
                            lb_row_ctr <= lb_row_ctr + 1;
                        end
                    end
                end
            end else begin
                if (i_feature_valid) begin
                    lb_row_ctr          <= ROW_START;
                    lb_col_ctr          <= COL_START;
                    feat_row_ctr        <= ROW_START;
                    feat_col_ctr        <= COL_START;
                    // Do we actually need to reset the line buffer to 0?
                    line_buffer         <= '{default: 0};
                    adder_tree_valid_sr <= '{default: 0};
                    macc_en             <= 1;
                    for (int i = 0; i < NUM_FILTERS; i++)
                        macc_accum[i] <= biases[i];
                        
                    // Use logic, instead of setting output directly
                    o_feature_valid <= 0;
                end
            end
        end
    end
    
    // How many features do we want to output in parallel?
    // assign o_feature
    // assign o_feature_valid
    
    assign o_buffer_full = lb_full;

endmodule