`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Organize incoming pixel data from SPI interface
*/
//////////////////////////////////////////////////////////////////////////////////


module pixel_curation(
    input  wire          i_clk,
    input  wire          i_wr_req,
    input  wire    [7:0] i_pixel_data,
    output wire [1023:0] o_image_vector,
    output wire          o_data_ready
);

    wire [9:0] vector_pos_upper;

    // 2FF synchronizer for SPI to global clock domain cross
    reg           sync_ff0       = 1'b0; 
    reg           sync_ff1       = 1'b0;
    reg           sync_ff2       = 1'b0;
 
    reg     [9:0] vector_pos     = 10'b0;

    assign vector_pos_upper = vector_pos + 3'd7;
    always_ff @(posedge i_clk)
    begin
        sync_ff0 <= i_wr_req;
        sync_ff1 <= sync_ff0;
        sync_ff2 <= sync_ff1;
        if (~sync_ff1 & sync_ff2)
        begin
            vector_pos   <= vector_pos + 4'd8;
            o_image_vector[vector_pos_upper:vector_pos] <= i_pixel_data;
            o_data_ready <= vector_pos == 10'd1016;
        end
    end
        
endmodule
