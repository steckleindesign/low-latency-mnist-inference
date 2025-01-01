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
    
    40 Cycles:
    Feature n*9 + 0: 90, 90, 90, 90, 40
    Feature n*9 + 1:                 50, 90, 90, 90, 80
    Feature n*9 + 2:                                 10, 90, 90, 90, 90, 30
    Feature n*9 + 3:                                                     60, 90, 90, 90, 70
    Feature n*9 + 4:                                                                     20, 90, 90, 90, 90, 20
    Feature n*9 + 5:                                                                                         70, 90, 90, 90, 60
    Feature n*9 + 6:                                                                                                         30, 90, 90, 90, 10
    Feature n*9 + 7:                                                                                                                         80, 90, 90, 90, 50
    Feature n*9 + 8:                                                                                                                                         40, 90, 90, 90, 90

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
    localparam        INPUT_WIDTH  = 32;
    localparam        INPUT_HEIGHT = 32;
    localparam        FILTER_SIZE  = 5;
    
    
    // Each convolution is 16*5*5, each of the 120 neurons in this layer connects to all 16 S4 feature maps
    localparam S4_MAPS     = 16;
    localparam KERNEL_SIZE = 5;
    localparam NEURONS     = 120;

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

    
endmodule
