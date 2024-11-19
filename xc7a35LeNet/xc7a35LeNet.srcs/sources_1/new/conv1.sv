`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module conv1 #(
    parameter IMAGE_WIDTH  = 32,
    parameter IMAGE_HEIGHT = 32,
    parameter FILTER_SIZE  = 5,
    parameter NUM_FILTERS  = 6
) (
    input  logic               i_clk,
    // Do we want grayscale, or binary black/white pixel data?
    input  logic         [7:0] i_image[IMAGE_HEIGHT-1:0][IMAGE_WIDTH-1:0],
    input  logic signed  [7:0] i_filters[NUM_FILTERS-1:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0],
    output logic signed [15:0] o_feature_map[NUM_FILTERS-1:0][IMAGE_HEIGHT-FILTER_SIZE:0][IMAGE_WIDTH-FILTER_SIZE:0]
);

    integer i, j, k, l, f;
    
    always_ff @(posedge i_clk)
    begin
        for (f = 0; f < NUM_FILTERS; f++)
        begin
            for (i = 0; i <= IMAGE_HEIGHT - FILTER_SIZE; i++)
            begin
                for (j = 0; j < IMAGE_WIDTH - FILTER_SIZE; j++)
                begin
                    o_feature_map[f][i][j] = 'b0;
                    for (k = 0; k < FILTER_SIZE; k++)
                    begin
                        for (l = 0; l < FILTER_SIZE; l++)
                        begin
                            o_feature_map[f][i][j] = o_feature_map[f][i][j] + i_image[i+k][j+l] * i_filters[f][k][l];
                        end
                    end
                    // ReLU activation
                    if (o_feature_map[f][i][j][15]) o_feature_map[f][i][j] = 'b0;
                end
            end
        end
    end
    
endmodule
