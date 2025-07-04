`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Trainable parameters = 120 * (16*5*5 + 1) = 48120
    Num multiplies = 120*16*5*5 = 48000
    90 DSP48s, 48000/90 = 533.3 = 534 clock cycles
    
    Architecture: 4 state FSM
    DSP48E1 mapping by state
    State:      1,  2,  3,  4
    Neuron n+1: 90, 30
    Neuron n+2:     60, 60
    Neuron n+3:         30, 90
    
    TODO: Verify control logic and check for off-by-ones
    
*/

//////////////////////////////////////////////////////////////////////////////////

module conv3(
    input  logic        i_clk,
    input  logic        i_rst,
    input  logic        i_feature_valid,
    input  logic [15:0] i_feature,
    output logic        o_feature_valid,
    output logic [15:0] o_feature[0:119]
);
    
    localparam string WEIGHTS_FILE = "weights.mem";
    localparam string BIASES_FILE  = "biases.mem";
    
    // Each convolution is 16*5*5, each of the 120 neurons in this layer connects to all 16 S4 feature maps
    localparam S4_NUM_MAPS = 16;
    localparam S4_MAP_SIZE = 5;
    localparam NUM_NEURONS = 120;
    localparam NUM_DSP     = 90;
    
    // Initialize trainable parameters
    // Weights
    // Will probably need to be reshaped into 90 RAMs dedicated to each DSP throughout the design
    // (* rom_style = "block" *)
    logic signed [7:0]
    weights [0:NUM_NEURONS-1][0:S4_MAP_SIZE-1][0:S4_MAP_SIZE-1];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    // (* rom_style = "block" *)
    logic signed [7:0]
    biases [0:NUM_NEURONS-1];
    initial $readmemb(BIASES_FILE, biases);
    
    // 120 accumulate values for each of the 120 neurons in the following layer
    logic [8+$clog2(NUM_NEURONS)-1:0] accumulates[0:NUM_NEURONS-1] = '{default: 0};
    
    // 3 DSP groups (30 DSP48E1s per group)
    logic signed [23:0] macc_out[0:2][0:(NUM_DSP/3)-1];
    
    logic signed [7:0] feature_operands[0:2];
    logic signed [7:0] weight_operands[0:NUM_DSP-1];
    logic signed [$clog2(S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE)+7:0] accumulate_operands
                                                                    [0:2][0:(NUM_DSP/3)-1];
    
    // TODO: Can we shink this so we dont take up 3200 FFs? Thats 400 slices.
    logic signed [7:0] feature_buf[0:S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE-1];
    logic signed [7:0] current_features[0:1];
    
    // Used for storing incoming features at their arrival location
    logic [$clog2(S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE)-1:0] feature_buf_ctr  = 0;
    // Used for reading feature from buffer into current feature slot
    logic [$clog2(S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE)-1:0] feature_buf_addr = 0;
    
    logic [$clog2(NUM_NEURONS)-1:0] conv_pattern_rollover_cnt = 0;
    
    // 544 clock cycles of * operations in this layer
    logic [$clog2(543)-1:0] conv3_cyc;
    
    logic is_processing    = 0;
    logic feature_buf_full = 0;
    logic data_valid       = 0;
    
    typedef enum logic [1:0] {
        CONV3_ONE,
        CONV3_TWO,
        CONV3_THREE,
        CONV3_FOUR
    } conv3_state_t;
    conv3_state_t state = CONV3_ONE;
    
    always_ff @(posedge i_clk) begin
        if (is_processing) begin
            case(state)
                CONV3_ONE: begin
                    current_features <= {current_features[0], feature_buf[feature_buf_addr]};
                    feature_buf_addr <= feature_buf_addr + 1;
                    state <= CONV3_TWO;
                end
                CONV3_TWO: begin
                    current_features <= {current_features[0], feature_buf[feature_buf_addr]};
                    feature_buf_addr <= feature_buf_addr + 1;
                    state <= CONV3_THREE;
                end
                CONV3_THREE: begin
                    current_features <= {current_features[0], feature_buf[feature_buf_addr]};
                    feature_buf_addr <= feature_buf_addr + 1;
                    state <= CONV3_FOUR;
                end
                CONV3_FOUR: begin
                    conv_pattern_rollover_cnt <= conv_pattern_rollover_cnt + 1;
                    state <= CONV3_ONE;
                end
            endcase
        end
    end
    
    always_ff @(posedge i_clk)
        if (i_feature_valid) begin
            is_processing <= 1;
            if (~feature_buf_full) begin
                feature_buf[feature_buf_ctr] <= i_feature;
                feature_buf_ctr <= feature_buf_ctr + 1;
                if (feature_buf_ctr == S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE)
                    feature_buf_full <= 1;
            end
        end
    
//    always_ff @(posedge i_clk)
//        if (is_processing)
//            conv3_cyc <= conv3_cyc + 1;
    
    always_ff @(posedge i_clk)
        // 16*5*5=400 features, 3 features per pattern, 400/3=133.3
        // All valid data is present in 2 cycles
        // 30 neurons are ready on the first cycle valid is high
        // 90 other neurons are valid the next cycle
        if (conv_pattern_rollover_cnt == 8'd133 && (state == CONV3_THREE || state == CONV3_FOUR))
            data_valid <= 1;
    
    always_ff @(posedge i_clk) begin
        if (is_processing) begin
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
        if (is_processing) begin
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
        if (is_processing) begin
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
        o_feature <= accumulates;
    
endmodule