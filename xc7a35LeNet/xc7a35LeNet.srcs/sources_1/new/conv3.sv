`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Trainable parameters = 120 * (16*5*5 + 1) = 48120
    Num multiplies = 120*16*5*5 = 48000
    90 DSP48s, 48000/90 = 533.3 = 534 clock cycles
    
    INPUT: 16x 5x5 feature maps
    OUTPUT: 120 neurons
    
    Theory of operation:
    Start with multiplying map 0 location 0,0 and work our way left to right on the input map
    then work our way top to bottom on the input map, then work our way through each input map
    all the way through map 15.
    TODO: Pipeline DSP48E1s
    
    Architecture: 4 state FSM
    DSP48E1 mapping by state
    State:      1,  2,  3,  4
    Neuron n+1: 90, 30
    Neuron n+2:     60, 60
    Neuron n+3:         30, 90
    Throughout 4 states, we compute 3 features
    400 features, so 4* 400/3 = 533.3 = 534 cycles
        
*/

//////////////////////////////////////////////////////////////////////////////////

module conv3(
    input  logic              i_clk,
    input  logic              i_rst,
    input  logic              i_feature_valid,
    input  logic        [7:0] i_features[0:15],
    output logic              o_feature_valid,
    output logic signed [7:0] o_features[0:119],
    
    input  logic        [7:0] weights[0:89]
);

    // Each of the 120 output neurons connect to all 16 S4 feature maps (16x5x5=400)
    localparam S4_NUM_MAPS = 16;
    localparam S4_MAP_SIZE = 5;
    localparam NUM_NEURONS = 120;
    localparam NUM_DSP     = 90;
    
    // Weights
    // localparam string WEIGHTS_FILE = "weights.mem";
    // logic signed [7:0]
    // weights [0:NUM_NEURONS-1][0:S4_MAP_SIZE-1][0:S4_MAP_SIZE-1];
    // initial $readmemb(WEIGHTS_FILE, weights);
    
    // Biases
    localparam string BIASES_FILE = "biases.mem";
    logic signed [7:0] biases [0:NUM_NEURONS-1];
    initial $readmemb(BIASES_FILE, biases);
    
    logic                                  macc_en;
    
    logic signed                     [7:0] s4_map[0:15][0:4][0:4];
    
    logic                  [$clog2(5)-1:0] input_feature_col_cnt;
    logic                  [$clog2(5)-1:0] input_feature_row_cnt;
    
    logic                 [$clog2(16)-1:0] feature_operand_map_cnt;
    logic                  [$clog2(5)-1:0] feature_operand_row_cnt;
    logic                  [$clog2(5)-1:0] feature_operand_col_cnt;
    
    logic signed                     [7:0] current_features[0:1];
    logic signed                     [7:0] feature_operands[0:2];
    logic signed                     [7:0] weight_operands[0:NUM_DSP-1];
    logic signed                     [7:0] accumulate_operands[0:2][0:(NUM_DSP/3)-1];
    logic signed                     [7:0] macc_out[0:2][0:(NUM_DSP/3)-1];
    
    logic signed                     [7:0] accumulates[0:NUM_NEURONS-1] = '{default: 0};
    
    logic        [$clog2(NUM_NEURONS)-1:0] conv_pattern_rollover_cnt = 0;
    
    logic                [$clog2(543)-1:0] conv3_cyc;
    
    typedef enum logic [1:0] {
        CONV3_ONE,
        CONV3_TWO,
        CONV3_THREE,
        CONV3_FOUR
    } conv3_state_t;
    conv3_state_t state = CONV3_ONE;
    
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            case(state)
                CONV3_ONE: begin
                    state <= CONV3_TWO;
                end
                CONV3_TWO: begin
                    state <= CONV3_THREE;
                end
                CONV3_THREE: begin
                    state <= CONV3_FOUR;
                end
                CONV3_FOUR: begin
                    conv_pattern_rollover_cnt <= conv_pattern_rollover_cnt + 1;
                    state <= CONV3_ONE;
                end
            endcase
            if (state == CONV3_ONE | state == CONV3_TWO | state == CONV3_THREE) begin
                current_features <= {current_features[0], s4_map[feature_operand_map_cnt]
                                                                [feature_operand_row_cnt]
                                                                [feature_operand_col_cnt]};
                feature_operand_col_cnt <= feature_operand_col_cnt + 1;
                if (feature_operand_col_cnt == 4) begin
                    feature_operand_col_cnt <= 0;
                    feature_operand_row_cnt <= feature_operand_row_cnt + 1;
                    if (feature_operand_row_cnt == 4) begin
                        feature_operand_row_cnt <= 0;
                        feature_operand_map_cnt <= feature_operand_map_cnt + 1;
                        if (feature_operand_map_cnt == 15) begin
                            // Layer is done.
                        end
                    end
                end
            end
        end
    end
    
    // We need to take in 16 features in parallel, and place them in appropriate feature buffer location
    // Maybe the dimensions of the feature buffer should be 16x5x5.
    // We could have 16 separate distributed RAMs, 32x8 bits each. Would use 16 slices?
    // We then would need 3D feature buffer counter: map #, row #, column #.
    always_ff @(posedge i_clk)
        if (i_feature_valid) begin
            for (int i = 0; i < 16; i++)
                s4_map[i][input_feature_row_cnt]
                         [input_feature_col_cnt] <= i_features[i];
            input_feature_col_cnt <= input_feature_col_cnt + 1;
            if (input_feature_col_cnt == 4) begin
                input_feature_col_cnt <= 0;
                input_feature_row_cnt <= input_feature_row_cnt + 1;
                if (input_feature_row_cnt == 4) begin
                    macc_en <= 1;
                end
            end
        end
    
    // What to do with cycle count?
    always_ff @(posedge i_clk)
        if (macc_en)
            conv3_cyc <= conv3_cyc + 1;
    
    // All date becomes valid during 2 cycles, 30 neurons are ready on the
    // first valid cycle and the 90 other neurons are valid the next cycle
    always_ff @(posedge i_clk)
        if (conv_pattern_rollover_cnt == 8'd133 && (state == CONV3_THREE || state == CONV3_FOUR))
            o_feature_valid <= 1;
        else
            o_feature_valid <= 0;
    
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            case(state)
                CONV3_ONE: begin
                    feature_operands[0] <= current_features[0];
                    feature_operands[1] <= current_features[1];
                    feature_operands[2] <= current_features[1];
                    // weight_operands <= weights[conv3_cyc];
                end
                CONV3_TWO: begin
                    feature_operands[0] <= current_features[0];
                    feature_operands[1] <= current_features[0];
                    feature_operands[2] <= current_features[1];
                    // weight_operands <= weights[conv3_cyc];
                end
                CONV3_THREE: begin
                    feature_operands[0] <= current_features[1];
                    feature_operands[1] <= current_features[1];
                    feature_operands[2] <= current_features[1];
                    // weight_operands <= weights[conv3_cyc];
                end
                CONV3_FOUR: begin
                    feature_operands[0] <= current_features[0];
                    feature_operands[1] <= current_features[0];
                    feature_operands[2] <= current_features[0];
                    // weight_operands <= weights[conv3_cyc];
                end
            endcase
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            case(state)
                CONV3_ONE: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulate_operands[0][i] <= accumulates[90 + i];
                        accumulate_operands[1][i] <= accumulates[     i];
                        accumulate_operands[2][i] <= accumulates[30 + i];
                    end
                end
                CONV3_TWO: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulate_operands[0][i] <= accumulates[60 + i];
                        accumulate_operands[1][i] <= accumulates[90 + i];
                        accumulate_operands[2][i] <= accumulates[     i];
                    end
                end
                CONV3_THREE: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulate_operands[0][i] <= accumulates[30 + i];
                        accumulate_operands[1][i] <= accumulates[60 + i];
                        accumulate_operands[2][i] <= accumulates[90 + i];
                    end
                end
                CONV3_FOUR: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulate_operands[0][i] <= accumulates[     i];
                        accumulate_operands[1][i] <= accumulates[30 + i];
                        accumulate_operands[2][i] <= accumulates[60 + i];
                    end
                end
            endcase
        end
    end
    
    always_ff @(posedge i_clk)
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 30; j++)
                macc_out[i][j] <=
                    feature_operands[i] *
                        weight_operands[i*30+j] +
                            accumulate_operands[i][j];
    
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            case(state)
                CONV3_ONE: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulates[30 + i] <= macc_out[0][i];
                        accumulates[60 + i] <= macc_out[1][i];
                        accumulates[90 + i] <= macc_out[2][i];
                    end
                end
                CONV3_TWO: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulates[     i] <= macc_out[0][i];
                        accumulates[30 + i] <= macc_out[1][i];
                        accumulates[60 + i] <= macc_out[2][i];
                    end
                end
                CONV3_THREE: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulates[90 + i] <= macc_out[0][i];
                        accumulates[     i] <= macc_out[1][i];
                        accumulates[30 + i] <= macc_out[2][i];
                    end
                end
                CONV3_FOUR: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulates[60 + i] <= macc_out[0][i];
                        accumulates[90 + i] <= macc_out[1][i];
                        accumulates[     i] <= macc_out[2][i];
                    end
                end
            endcase
        end
    end
    
    always_comb
        o_features <= accumulates;
    
endmodule