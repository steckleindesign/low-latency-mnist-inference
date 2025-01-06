`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*

    Architecture:
        Overview:
            Utilize 90 DSPs for convolution
            Complete 3 convolutions in 5 clock cycles
            We will skip the last convolution (output feature) for each row
            There will be 27 convolutions (output features) in each row
            This will take (27/3)*5 = 45 clock cycles per row
            We will sequentially execute convolution operation on all 28 rows
            For each row, convolve left to right, from output feature 0-26
            It will take 45*28 = 1260 clock cycles for the conv1 operation
        Start
            Wait until line buffer is full to enable convolution operation
        End of row (After each row convolution operation if finished):
            Increment feature row count
            Shift line buffer down
            reset the line buffer full flag
            
          
          90 DSPs, 50 BRAMS (36Kb each)
          6 filters for conv1, 5x5 filter (25 * ops), 28x28 conv ops (784)
          = 6*(5*5)*(28*28) = 117600 * ops / 90 DSPs = 1306.6 = 1307 cycs theoretically
          
          Going to skip the last 2 columns (which are all 0's) so we can efficiently complete
          each row's * operations without a remainder of DSPs
          Will take us 46 clock cycles per row this way => (6*28*5*5 - 6*5*2) / 90 = 46
          
          We don't want to MACC operations on multiplying with 0s (whether 0 pixel/feature or outer rings)
          is it worth it to compare and skip features in single clock cycle to avoid *0 ?
          The muxing implemented in fabric will probably take too much space, so will need to use DSP48 mux
          
          Accumulation architecture is currently adder tree - research additional adder structures
          - Wallace Tree
          - Look into barrel shifters and booth multipliers
          
          Study how to get outputs of DSP48s to carry chain resources efficiently
          
          State:        0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14
          
          adder 1-1:    15, 18,  9,  5,  3,  2,  1
          adder 2-1:        5,  18, 14,  7,  4,  2,  1
          adder 3-1:                10, 20, 10,  5,  3,  2,  1
          
          adder 1-2:                        15, 18,  9,  5,  3,  2,  1
          adder 2-2:                            5,  18, 14,  7,  4,  2,  1
          adder 3-2:                                    10, 20, 10,  5,  3,  2,  1
*/
//////////////////////////////////////////////////////////////////////////////////

module conv1 #( parameter NUM_FILTERS = 6 ) (
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic               i_feature_valid,
    // For now we are just preloading pixels from RAM,
    // So i_feature will be reading from a full RAM of pixels,
    // No CDC needed, a new feature is available each clock cycle
    input  logic         [7:0] i_feature,
    output logic               o_feature_valid,
    output logic signed [15:0] o_features[NUM_FILTERS-1:0],
    // Letting pixel RAM know we can't take in any data
    output logic               o_buffer_full
);

    localparam string WEIGHTS_FILE = "weights.mem";
    localparam string BIASES_FILE  = "biases.mem";
    localparam        INPUT_WIDTH  = 32;
    localparam        INPUT_HEIGHT = 32;
    localparam        FILTER_SIZE  = 5;

    // Computed local params from module parameters
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
    // For first synthesis effort, using FILTER_SIZE+1 rows, no need for input feature
    // to be used in the logic, and for now we are not worried about memory
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
    logic signed [23:0] adder1_result[NUM_FILTERS-1:0];       // adder tree 1 result
    logic signed [23:0] adder2_stage1[NUM_FILTERS-1:0][4:0];  // 5 dsp outs
    logic signed [23:0] adder2_stage2[NUM_FILTERS-1:0][17:0]; // 3 adder outs from stage 1 + 15 dsp outs
    logic signed [23:0] adder2_stage3[NUM_FILTERS-1:0][13:0]; // 9 adder outs from stage 2 + 5 dsp outs
    logic signed [23:0] adder2_stage4[NUM_FILTERS-1:0][6:0];  // 7 adder outs from stage 3
    logic signed [23:0] adder2_stage5[NUM_FILTERS-1:0][3:0];  // 4 adder outs from stage 4
    logic signed [23:0] adder2_stage6[NUM_FILTERS-1:0][1:0];  // 2 adder outs from stage 5
    logic signed [23:0] adder2_result[NUM_FILTERS-1:0];       // adder tree 2 result
    logic signed [23:0] adder3_stage1[NUM_FILTERS-1:0][9:0];  // 10 dsp outs
    logic signed [23:0] adder3_stage2[NUM_FILTERS-1:0][19:0]; // 5 adder outs from stage 1 + 15 dsp outs
    logic signed [23:0] adder3_stage3[NUM_FILTERS-1:0][9:0];  // 10 adder outs from stage 2
    logic signed [23:0] adder3_stage4[NUM_FILTERS-1:0][4:0];  // 5 adder outs from stage 3
    logic signed [23:0] adder3_stage5[NUM_FILTERS-1:0][2:0];  // 3 adder outs from stage 4
    logic signed [23:0] adder3_stage6[NUM_FILTERS-1:0][1:0];  // 2 adder outs from stage 5
    logic signed [23:0] adder3_result[NUM_FILTERS-1:0];       // adder tree 3 result
    // Wire to features output port
    logic signed [23:0] macc_acc[NUM_FILTERS-1:0];
    // Register outputs of DSPs
    // TODO: Flatten
    logic signed [23:0] mult_out[NUM_FILTERS-1:0][FILTER_SIZE*3-1:0];
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
        // Default, override when MACC enabled
        next_state = ONE;
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
                    next_state = FIVE; // (feat_col_ctr == COL_END) ? ONE : FIVE;
                    // 5  -> adder tree 2
                    // 10 -> adder tree 3
                FIVE:
                    next_state = ONE;
                    // 15 -> adder tree 3
               // should not be reached
               default: next_state = next_state;
            endcase
        end
    end
    
    // Register DSP outputs
    // Flatten mult out outputs, or fix indexing at least so its easier to use with adder tree
    always_ff @(posedge i_clk)
        for (int i = 0; i < NUM_FILTERS; i++)
            for (int j = 0; j < 5; j++)
                for (int k = 0; k < 3; k++)
                    mult_out[i][k*5+j] <= weight_operands[i][j][k] * feature_operands[j][k];

    // Only on MACC enable, not on first feature valid signal
    // This is because the very first clock cycle after valid data should only enable the DSP operation,
    // not the adder tree logic
    // re-visit the above claim, do we really need to gate the DSP48 logic, or just ensure a proper valid out signal
    // (TODO: try to really understand clock enables vs. gating vs. if the macc_en is just treated as a logic variable)
    // TODO: add bias to front of tree
    // Discover: Do we need to gate adder arithmetic? Or will having the valid out signal gate the adder logic
    //           and synthesize time multiplexing of carry chain logic?
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            for (int i = 0; i < NUM_FILTERS; i++) begin
                // Adder tree structure 1
                adder1_stage1[i][14:10] <= mult_out[i][14:10];
                adder1_stage1[i][9:5]   <= mult_out[i][9:5];
                adder1_stage1[i][4:0]   <= mult_out[i][4:0];
                
                adder1_stage2[i][17]    <= adder1_stage1[i][15];
                for (int j = 0; j < 7; j++)
                    adder1_stage2[i][10+j] <= adder1_stage1[i][j*2] + adder1_stage1[i][j*2+1];
                adder1_stage2[i][9:5]   <= mult_out[i][9:5];
                adder1_stage2[i][4:0]   <= mult_out[i][4:0];
                
                for (int j = 0; j < 9; j++)
                    adder1_stage3[i][j] <= adder1_stage2[i][j*2] + adder1_stage2[i][j*2+1];
                
                // Can stage 4 5th reg just directly be connected to stage 6 1st reg?
                adder1_stage4[i][4]     <= adder1_stage3[i][8];
                for (int j = 0; j < 4; j++)
                    adder1_stage4[i][j] <= adder1_stage3[i][j*2] + adder1_stage3[i][j*2+1];
                    
                adder1_stage5[i][2]     <= adder1_stage4[i][4];
                for (int j = 0; j < 2; j++)
                    adder1_stage5[i][j] <= adder1_stage4[i][j*2] + adder1_stage4[i][j*2+1];
                    
                adder1_stage6[i][1]     <= adder1_stage5[i][2];
                adder1_stage6[i][0]     <= adder1_stage5[i][0] + adder1_stage5[i][1];
                
                adder1_result[i]        <= adder1_stage6[i][1] + adder1_stage6[i][0];
                
                // Adder tree structure 2
                adder2_stage1[i]        <= mult_out[i][14:10];
                
                adder2_stage2[i][17]    <= adder2_stage1[i][4];
                for (int j = 0; j < 2; j++)
                    adder2_stage2[i][j] <= adder2_stage1[i][j*2] + adder2_stage1[i][j*2+1];
                adder2_stage2[i][14:10] <= mult_out[i][14:10];
                adder2_stage2[i][9:5]   <= mult_out[i][9:5];
                adder2_stage2[i][4:0]   <= mult_out[i][4:0];
                
                for (int j = 0; j < 9; j++)
                    adder2_stage3[i][j+5] <= adder2_stage2[i][j*2] + adder2_stage2[i][j*2+1];
                adder2_stage3[i][4:0]   <= mult_out[i][4:0];
                
                for (int j = 0; j < 7; j++)
                    adder2_stage4[i][j+5] <= adder2_stage3[i][j*2] + adder2_stage3[i][j*2+1];
                    
                adder2_stage5[i][3]     <= adder2_stage4[i][6];
                for (int j = 0; j < 3; j++)
                    adder2_stage5[i][j] <= adder2_stage4[i][j*2] + adder2_stage4[i][j*2+1];
                    
                for (int j = 0; j < 2; j++)
                    adder2_stage6[i][j+5] <= adder2_stage5[i][j*2] + adder2_stage5[i][j*2+1];
                
                adder2_result[i]        <= adder2_stage6[i][1] + adder2_stage6[i][0];
                
                // Adder tree structure 3
                adder3_stage1[i][9:5]   <= mult_out[i][14:10];
                adder3_stage1[i][4:0]   <= mult_out[i][9:5];
                
                for (int j = 0; j < 5; j++)
                    adder3_stage2[i][j+15] <= adder3_stage1[i][j*2] + adder3_stage1[i][j*2+1];
                adder3_stage2[i][14:10] <= mult_out[i][14:10];
                adder3_stage2[i][9:5]   <= mult_out[i][9:5];
                adder3_stage2[i][4:0]   <= mult_out[i][4:0];
                
                for (int j = 0; j < 10; j++)
                    adder3_stage3[i][j] <= adder3_stage2[i][j*2] + adder3_stage2[i][j*2+1];
                
                for (int j = 0; j < 5; j++)
                    adder3_stage4[i][j] <= adder3_stage3[i][j*2] + adder3_stage3[i][j*2+1];
                
                // Same principle as with adder tree structure 1, can we bring this signal down to stage 6 directly?
                adder3_stage5[i][2] <= adder3_stage4[i][4];
                for (int j = 0; j < 2; j++)
                    adder3_stage5[i][j] <= adder3_stage4[i][j*2] + adder3_stage4[i][j*2+1];
                    
                adder3_stage6[i][1]     <= adder3_stage5[i][2];
                adder3_stage6[i][0]     <= adder3_stage5[i][0] + adder3_stage5[i][1];
                
                adder3_result[i]        <= adder3_stage6[i][1] + adder3_stage6[i][0];
            end
        end
    end
    
    always_comb
        // Would casex block be better here?
        if (adder_tree_valid_sr[0][6])
            macc_acc <= adder1_result;
        else if (adder_tree_valid_sr[1][6])
            macc_acc <= adder2_result;
        else if (adder_tree_valid_sr[2][6])
            macc_acc <= adder3_result;
        else
            macc_acc <= macc_acc;
    
    // Do we want to use an enable here?
    // Maybe could K-map this down to less lines, but the verbose version is more understandable
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
                    // 15 -> adder tree 1
                end
                TWO: begin
                    // 10 -> adder tree 1,
                    // 5  -> adder tree 2
                    feat_col_ctr <= feat_col_ctr + 1;
                end
                THREE: begin
                    // 15 -> adder tree 2
                end
                FOUR: begin
                    // 5  -> adder tree 2
                    // 10 -> adder tree 3
                    feat_col_ctr <= feat_col_ctr + 1;
                end
                FIVE: begin
                    // 15 -> adder tree 3
                    feat_col_ctr <= feat_col_ctr + 1;
                end
            endcase
            adder_tree_valid_sr[0] <= { adder_tree_valid_sr[0][5:0], state == ONE  };
            adder_tree_valid_sr[1] <= { adder_tree_valid_sr[1][5:0], state == TWO  };
            adder_tree_valid_sr[2] <= { adder_tree_valid_sr[2][5:0], state == FOUR };
        end
    end
    
    always_comb begin
        next_row = feat_col_ctr == COL_END-1 && state == FIVE;
        lb_full  = lb_row_ctr == FILTER_SIZE && lb_col_ctr == COL_END;
    end
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            macc_en      <= 0;
            feat_row_ctr <= ROW_START;
            feat_col_ctr <= COL_START;
            // Do we actually need to reset the line buffer to 0?
            line_buffer         <= '{default: 0};
            adder_tree_valid_sr <= '{default: 0};
        end else begin
            if (lb_full)
                macc_en <= 1;
            if (next_row) begin
                feat_row_ctr <= feat_row_ctr + 1;
                feat_col_ctr <= COL_START;
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            lb_row_ctr <= ROW_START;
            lb_col_ctr <= COL_START;
        end else begin
            if (i_feature_valid)
                if (lb_full)
                    if (next_row)
                        for (int i = 0; i < FILTER_SIZE-1; i++)
                            line_buffer[i] <= line_buffer[i+1];
                // Bug here, if we reach this the input feature was guarenteed to be valid
                else if (i_feature_valid) begin
                    line_buffer[lb_row_ctr][lb_col_ctr] <= i_feature;
                    if (lb_col_ctr == COL_END) begin
                        lb_col_ctr <= COL_START;
                        lb_row_ctr <= lb_row_ctr + 1;
                    end
                end
        end
    end
    
    // How many features do we want to output in parallel?
    assign o_features      = macc_acc;
    assign o_feature_valid = adder_tree_valid_sr[0][6] ||
                             adder_tree_valid_sr[1][6] ||
                             adder_tree_valid_sr[2][6];
    assign o_buffer_full   = lb_full;

endmodule