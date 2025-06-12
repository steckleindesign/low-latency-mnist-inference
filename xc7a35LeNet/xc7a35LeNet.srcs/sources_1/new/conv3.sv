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
    input  logic [15:0] i_features,
    output logic        o_feature_valid,
    output logic [15:0] o_features
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
    logic signed [8+$clog2(NUM_NEURONS)-1:0] accumulates[0:NUM_NEURONS-1];
    
    // 3 DSP groups (30 DSP48E1s per group)
    logic signed [23:0] mult_out[0:2][0:(NUM_DSP/3)-1];
    
    // TODO: Can we shink this so we dont take up 3200 FFs? Thats 400 slices.
    logic signed [7:0] feature_buf[0:S4_NUM_MAPS*S4_MAP_SIZE*S4_MAP_SIZE-1];
    logic signed [7:0] current_features[0:1];
    
    typedef enum logic [1:0] {
        CONV3_ONE,
        CONV3_TWO,
        CONV3_THREE,
        CONV3_FOUR
    } conv3_state_t;
    conv3_state_t state = CONV3_ONE;
    
    // Fill feature buffer with input data when valid
    
    // Begin processing via MACC operations when we have first feature
    
    // Current feature slot conditional shift and datapath from feature buffer
    
    // Datapath from current feature slots to DSPs
    
    // Datapath from DSPs to accumulates, includes 2 logic levels, mux and adder
    
    // Data out valid control
    
    
endmodule