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
    output wire [1023:0] o_image_vector
);

    // 2FF synchronizer
    reg        sync_ff0     = 1'b0; 
    reg        sync_ff1     = 1'b0;
    reg        sync_ff2     = 1'b0;
    
    reg        r_pixel_byte = 8'b0;
    
    reg  [9:0] vector_pos   = 10'b0;

    always_ff @(posedge i_clk)
    begin
        sync_ff0 <= i_wr_req;
        sync_ff1 <= sync_ff0;
        sync_ff2 <= sync_ff1;
        if (~sync_ff1 & sync_ff2)
        begin
            r_pixel_byte <= i_pixel_data;
        end
    end
    
endmodule
