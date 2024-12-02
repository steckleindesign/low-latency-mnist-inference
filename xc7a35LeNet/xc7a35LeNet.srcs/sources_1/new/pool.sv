`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module pool #(
    parameter INPUT_WIDTH  = 28,
    parameter INPUT_HEIGHT = 28,
    parameter NUM_CHANNELS = 6,
    parameter POOL_SIZE    = 2,
    parameter STRIDE       = 2
) (
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic signed [15:0] i_feature_map,
    output logic signed [15:0] o_feature_map
);

    // output parallel dimensions [NUM_CHANNELS-1:0][(INPUT_HEIGHT/POOL_SIZE)-1:0][(INPUT_WIDTH/POOL_SIZE)-1:0]


    /*
    integer c, i, j, k, l;
    always_ff @(posedge i_clk)
    begin
        for (c = 0; c < NUM_CHANNELS; c++)
            for (i = 0; i < INPUT_HEIGHT/POOL_SIZE; i++)
                for (j = 0; j < INPUT_WIDTH/POOL_SIZE; j++) begin
                    automatic logic signed [15:0] max_value = {16{1'b1}};
                    for (k = 0; k < POOL_SIZE; k++)
                        for (l = 0; l < POOL_SIZE; l++)
                            if (i_feature_map[c][i*STRIDE + k][j*STRIDE + l] > max_value)
                                max_value = i_feature_map[c][i*STRIDE + k][j*STRIDE + l];
                end
    end
    */
    
endmodule
