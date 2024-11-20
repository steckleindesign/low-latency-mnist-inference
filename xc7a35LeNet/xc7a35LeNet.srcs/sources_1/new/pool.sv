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
    input  logic signed [15:0] i_feature_map[NUM_CHANNELS-1:0][INPUT_HEIGHT-1:0][INPUT_WIDTH-1:0],
    output logic signed [15:0] o_feature_map[NUM_CHANNELS-1:0][(INPUT_HEIGHT/POOL_SIZE)-1:0][(INPUT_WIDTH/POOL_SIZE)-1:0]
);

    integer c, i, j, k, l;
    
    always_ff @(posedge i_clk)
    begin
        for (c = 0; c < NUM_CHANNELS; c++)
        begin
            for (i = 0; i < INPUT_HEIGHT/POOL_SIZE; i++)
            begin
                for (j = 0; j < INPUT_WIDTH/POOL_SIZE; j++)
                begin
                    automatic logic signed [15:0] max_value = {16{1'b1}};
                    for (k = 0; k < POOL_SIZE; k++)
                    begin
                        for (l = 0; l < POOL_SIZE; l++)
                        begin
                            if (i_feature_map[c][i*STRIDE + k][j*STRIDE + l] > max_value)
                                max_value = i_feature_map[c][i*STRIDE + k][j*STRIDE + l];
                        end
                    end
                end
            end
        end
    end
    
endmodule
