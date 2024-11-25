`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Organize incoming pixel data from SPI interface
*/
//////////////////////////////////////////////////////////////////////////////////


module pixel_curation #(
    parameter IMAGE_HEIGHT = 32,
    parameter IMAGE_WIDTH  = 32
) (
    input  logic       i_clk,
    input  logic       i_rst,
    input  logic       i_wr_req,
    input  logic [7:0] i_spi_data,
    output logic [7:0] o_pixel,
    output logic       o_pix_valid
);

    // 2FF synchronizer for SPI to global clock domain cross
    logic          sync_ff0 = 1'b0; 
    logic          sync_ff1 = 1'b0;
    logic          sync_ff2 = 1'b0;
    
    always_ff @(posedge i_clk or negedge i_rst)
    begin
        if (~i_rst) begin
            sync_ff0 <= 1'b0;
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            // So that ready signal is only 1 clk period wide
            o_pix_valid <= 1'b0;
            // 2FF sync
            sync_ff0    <= i_wr_req;
            sync_ff1    <= sync_ff0;
            sync_ff2    <= sync_ff1;
            if (~sync_ff1 & sync_ff2)
            begin
                // Update pixel data sent to conv1
                o_pixel     <= i_spi_data;
                // Signal valid data
                o_pix_valid <= 1'b1;
            end
        end
    end
        
endmodule
