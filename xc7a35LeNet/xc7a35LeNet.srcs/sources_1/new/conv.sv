`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Generic convolutional layer module, not used right now. Generic == not suitable for low latency

//////////////////////////////////////////////////////////////////////////////////

module conv #(
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
    input  logic         [7:0] i_feature,
    output logic               o_feature_valid,
    output logic signed [15:0] o_features[NUM_FILTERS-1:0]
);

endmodule