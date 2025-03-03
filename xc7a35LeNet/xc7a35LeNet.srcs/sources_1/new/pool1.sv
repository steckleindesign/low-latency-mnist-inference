`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module pool1(
    input  logic               clk,
    input  logic               rst,
    input  logic               valid_in,
    input  logic signed [15:0] features_in[0:5],
    output logic               valid_out,
    output logic signed [15:0] features_out[0:5]
);

    localparam NUM_FILTERS       = 6;
    localparam FEATURE_MAP_WIDTH = 28;

    logic row, col;
    logic [$clog2(FEATURE_MAP_WIDTH/2):0] cnt;
    logic signed [15:0] row_buf [0:NUM_FILTERS-1][0:FEATURE_MAP_WIDTH/2-1];
    
    always_ff @(clk)
        if (rst)
        begin
            row <= 0;
            col <= 0;
            cnt <= 0;
            row_buf <= '{default: 0};
            valid_out <= 0;
        end
        else
        begin
            valid_out <= 0;
            if (valid_in)
            begin
                col <= ~col;
                cnt <= cnt + 1;
                if (cnt == FEATURE_MAP_WIDTH/2 - 1)
                begin
                    cnt <= 0;
                    row <= ~row;
                end
                if (~row & ~col)
                    for (int i = 0; i < NUM_FILTERS; i++)
                        row_buf[i][cnt] <= features_in[i];
                else
                begin
                    for (int i = 0; i < NUM_FILTERS; i++)
                        if (features_in[i] > row_buf[i][cnt])
                        begin
                            row_buf[i][cnt] <= features_in[i];
                            features_out[i] <= features_in[i];
                        end
                        else
                            features_out[i] <= row_buf[i][cnt];
                    if (row & col)
                        valid_out <= 1;
                end
            end
        end

endmodule
