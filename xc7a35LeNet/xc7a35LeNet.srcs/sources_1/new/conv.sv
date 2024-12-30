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

module conv #(
    parameter string WEIGHTS_FILE3MAP = "weights3map.mem",
    parameter string WEIGHTS_FILE4MAP = "weights4map.mem",
    parameter string WEIGHTS_FILE6MAP = "weights6map.mem",
    parameter string BIASES_FILE      = "biases.mem",
    parameter        INPUT_WIDTH      = 14,
    parameter        INPUT_HEIGHT     = 14,
    parameter        FILTER_SIZE      = 5,
    parameter        NUM_FILTERS      = 16
) (
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic               i_feature_valid,
    input  logic         [7:0] i_feature,
    output logic               o_feature_valid,
    output logic signed [15:0] o_features[NUM_FILTERS-1:0]
);

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
    initial $readmemb(WEIGHTS_FILE3MAP, weights);
    // 4 S2 map connections weights
    (* rom_style = "block" *) logic signed [15:0]
    weights4map [8:0][3:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    initial $readmemb(WEIGHTS_FILE4MAP, weights);
    // 6 S2 map connections weights
    (* rom_style = "block" *) logic signed [15:0]
    weights6map [5:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    initial $readmemb(WEIGHTS_FILE6MAP, weights);
    // Biases (1 bias per C3 feature map)
    (* rom_style = "block" *) logic signed [15:0]
    biases [NUM_FILTERS-1:0];
    initial $readmemb(BIASES_FILE, biases);

endmodule