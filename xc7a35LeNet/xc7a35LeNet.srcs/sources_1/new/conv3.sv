`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Trainable parameters:
        120 * (16*5*5 + 1) = 48120
        
    # of * ops = 120*16*5*5 = 48000
    
    90 DSP48s, 48000/90 = 533.3 = 534 clock cycles
    
    400 * ops required for each of the 120 features
    
    least common multiple of 400 and 9 is 9*400=3600
    
    9 sets of 400, will require 3600/90 = 40 clock cycles
    
    We perform 120 5x5 convolutions on each S4 map.
    So each s4 map has 120x25 = 3000 * operations.
    3000/90 = 34 cycles.
    
    Architecture:
    Focus on a max of 2 features each cycle
    Greatly reduces latency
    FSM has 4 states:
    DSP48E1 usage by state:
    State:      1,  2,  3,  4
    Neuron n+1: 90, 30
    Neuron n+2:     60, 60
    Neuron n+3:         30, 90
    
    2 levels of logic (2:1 mux between DSP output and adder w/ ACC)
    We could keep this basic architecture to minimize area, or if
    logic is not too congested (rent is not too high) then we could have
    2 adders on each DSP output datapath and mux between the adder results.
    We could also use the DSPs for the ACC operation so that the DSPs
    perform a MACC operation instead of just Multiply.
    
    Feature operand datapath to DSP input:
    2:1 muxes from 2 features facing the array of muxes at a single point in time.
    
    
    Theory of operation:
    
*/

//////////////////////////////////////////////////////////////////////////////////

module conv3(
    input  logic        i_clk,
    input  logic        i_rst,
    input  logic        i_feature_valid,
    input  logic [15:0] i_feature,
    output logic        o_feature_valid,
    output logic [15:0] o_feature
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
    logic signed [8+$clog2(NUM_NEURONS)-1:0] accumulates[0:NUM_NEURONS-1] = '{default: 0};
    
    // 3 DSP groups (30 DSP48E1s per group)
    logic signed [23:0] macc_out[0:2][0:(NUM_DSP/3)-1];
    
    logic signed [7:0] feature_operands[0:2];
    logic signed [7:0] weight_operands[0:NUM_DSP-1];
    
    // TODO: Can we shink this so we dont take up 3200 FFs? Thats 400 slices.
    logic signed [7:0] feature_buf[0:S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE-1];
    logic signed [7:0] current_features[0:1];
    
    // Used for storing incoming features at their arrival location
    logic [$clog2(S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE)-1:0] feature_buf_ctr  = 0;
    // Used for reading feature from buffer into current feature slot
    logic [$clog2(S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE)-1:0] feature_buf_addr = 0;
    
    logic [$clog2(NUM_NEURONS)-1:0] neuron_ctr = 0;
    
    // 544 clock cycles of * operations in this layer
    logic [$clog2(543)-1:0] conv3_cyc;
    
    logic is_processing    = 0;
    logic feature_buf_full = 0;
    
    
    
    
    typedef enum logic [1:0] {
        CONV3_ONE,
        CONV3_TWO,
        CONV3_THREE,
        CONV3_FOUR
    } conv3_state_t;
    conv3_state_t state = CONV3_ONE;
    
    always_ff @(posedge i_clk) begin
        
        case(state)
            CONV3_ONE: begin
                if (is_processing)
                    state <= CONV3_TWO;
                current_features <= {current_features[0], feature_buf[feature_buf_addr]};
                feature_buf_addr <= feature_buf_addr + 1;
                // 90
                // [0,x] | [3,x] | [6,x]
            end
            CONV3_TWO: begin
                if (is_processing)
                    state <= CONV3_THREE;
                current_features <= {current_features[0], feature_buf[feature_buf_addr]};
                feature_buf_addr <= feature_buf_addr + 1;
                // 30, 60
                // [1,0] | [4,3] | [7,6]
            end
            CONV3_THREE: begin
                if (is_processing)
                    state <= CONV3_FOUR;
                current_features <= {current_features[0], feature_buf[feature_buf_addr]};
                feature_buf_addr <= feature_buf_addr + 1;
                // 60, 30
                // [2,1] | [5,4] | [8,7]
            end
            CONV3_FOUR: begin
                if (is_processing)
                    state <= CONV3_ONE;
                // 90
                // [3,2] | [6,5], [9,8]
            end
            default: state <= state;
        endcase
    end
    
    always_ff @(posedge i_clk) begin
        if (i_feature_valid) begin
            is_processing <= 1;
            if (~feature_buf_full) begin
                feature_buf[feature_buf_ctr] <= i_feature;
                feature_buf_ctr <= feature_buf_ctr + 1;
                if (feature_buf_ctr == S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE)
                    feature_buf_full <= 1;
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (is_processing) begin
            conv3_cyc <= conv3_cyc + 1;
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
                default: state <= state;
            endcase
        end
    end
    
    always_ff @(posedge i_clk)
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 30; j++)
                macc_out[i][j] <=
                    feature_operands[i] *
                        weight_operands[i*30+j] +
                            accumulate_operands[i*30+j];
    
    always_ff @(posedge i_clk) begin
        if (is_processing) begin
            case(state)
                CONV3_ONE: begin
                    for (int i = 0; i < 30; i++) begin
                        accumulates[neuron_ctr + 1] <=
                            [neuron_ctr + 1] + macc_out[0];
                        accumulates[neuron_ctr] <=
                            [neuron_ctr] + macc_out[1];
                        accumulates[neuron_ctr] <=
                            [neuron_ctr] + macc_out[2];
                    end
                end
                CONV3_TWO: begin
                    /*
                    dsp group 1 outputs mapped to neuron cnt+1 0-29
                    dsp group 2 outputs mapped to neuron cnt+1 30-59
                    dsp group 3 outputs mapped to neuron cnt 90-119
                    
                    For the 1st convolution pattern,
                    we perform MACC operations and store data
                    in MACC registers 0-29, 30-59, 60-89
                    
                    In the state before 1 (state 4),
                        we set the DSP operands
                            feature operands are set via state machine
                            weight operands are set via global weights RAMs (Large SR?, FIFO?)
                            Accumulates are fed back into C input of DSP48E1
                                They are also set via state machine, similar to features
                    
                    During state 1, the MACC operation executes
                        Stateless operation, multiply features and weights, add accumulates
                        Store result in output register (P reg of DSP, more pipelining later in design process)
                    
                    In the state after 1 (State 2), we store this value in the accumulates results
                        Capture P reg data into appropriate accumulate register
                            The proper accumulate registers to store data are the same
                            accumulate registers passed as accumulate operands 2 states before (state 4)
                    
                    */
                    
                    
                    
                    for (int i = 0; i < 30; i++) begin
                        accumulates[neuron_ctr] <=
                            accumulates[neuron_ctr] + macc_out[0];
                        accumulates[neuron_ctr+1] <=
                            accumulates[neuron_ctr+1] + macc_out[1];
                        accumulates[neuron_ctr+1] <=
                            accumulates[neuron_ctr+1] + macc_out[2];
                    end
                    neuron_ctr <= neuron_ctr + 1;
                end
                CONV3_THREE: begin
                    /*
                    dsp group 1 outputs mapped to neuron cnt 60-89
                    dsp group 2 outputs mapped to neuron cnt 90-119
                    dsp group 3 outputs mapped to neuron cnt+1 0-29
                    */
                    for (int i = 0; i < 30; i++) begin
                        accumulates[neuron_ctr] <=
                            accumulates[neuron_ctr] + macc_out[0];
                        accumulates[neuron_ctr] <=
                            accumulates[neuron_ctr] + macc_out[1];
                        accumulates[neuron_ctr+1] <=
                            accumulates[neuron_ctr+1] + macc_out[2];
                    end
                    neuron_ctr <= neuron_ctr + 1;
                end
                CONV3_FOUR: begin
                    /*
                    dsp group 1 outputs mapped to neuron cnt 30-59
                    dsp group 2 outputs mapped to neuron cnt 60-89
                    dsp group 3 outputs mapped to neuron cnt 90-119
                    */
                    for (int i = 0; i < 30; i++) begin
                        accumulates[neuron_ctr] <=
                            accumulates[neuron_ctr] + macc_out[0];
                        accumulates[neuron_ctr] <=
                            accumulates[neuron_ctr] + macc_out[1];
                        accumulates[neuron_ctr] <=
                            accumulates[neuron_ctr] + macc_out[2];
                    end
                    neuron_ctr <= neuron_ctr + 1;
                end
            endcase
        end
    end
    
    // Fill feature buffer with input data when valid                          - X
    // Begin processing via MACC operations when we have first feature         - X
    // Current feature slot conditional shift and datapath from feature buffer - X
    // Datapath from current feature slots to DSPs                             - X
    
    // Datapath from DSPs to accumulates, includes 2 logic levels, mux and adder
    
    // Data out valid control
    
    
endmodule