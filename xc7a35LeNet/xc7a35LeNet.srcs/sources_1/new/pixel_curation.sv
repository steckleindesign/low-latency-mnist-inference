`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Organize incoming pixel data from SPI interface
*/
//////////////////////////////////////////////////////////////////////////////////


module pixel_curation(
    input  logic       i_clk,
    input  logic       i_wr_req,
    input  logic [7:0] i_pixel_data,
    output logic [7:0] o_image[31:0][31:0],
    output logic       o_data_ready
);

    // 2FF synchronizer for SPI to global clock domain cross
    logic          sync_ff0       = 1'b0; 
    logic          sync_ff1       = 1'b0;
    logic          sync_ff2       = 1'b0;
    
    logic    [4:0] i              = 5'b0;
    logic    [4:0] j              = 5'b0;
        
    always_ff @(posedge i_clk)
    begin
        sync_ff0 <= i_wr_req;
        sync_ff1 <= sync_ff0;
        sync_ff2 <= sync_ff1;
        if (~sync_ff1 & sync_ff2)
        begin
            // Turn into for loop
            o_image[i][j]   = {6'b0, i_pixel_data[0]};
            o_image[i][j+1] = {6'b0, i_pixel_data[1]};
            o_image[i][j+1] = {6'b0, i_pixel_data[2]};
            o_image[i][j+3] = {6'b0, i_pixel_data[3]};
            o_image[i][j+4] = {6'b0, i_pixel_data[4]};
            o_image[i][j+5] = {6'b0, i_pixel_data[5]};
            o_image[i][j+6] = {6'b0, i_pixel_data[6]};
            o_image[i][j+7] = {6'b0, i_pixel_data[7]};
            // Update indices
            if (j == 5'd24) i = i + 1'b1;
            j <= j + 4'd8;
            o_data_ready <= (i == 5'd31) & (j == 5'd24);
        end
    end
        
endmodule
