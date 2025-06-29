`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module image_buffer_ram(
    input  clk,
    input  rst,
    input  pixel_in,
    input  pixel_in_valid,
    input  hold,
    output pixel_out
);

    parameter IMG_WIDTH     = 28;
    parameter IMG_HEIGHT    = 28;
    parameter IMG_RAM_DEPTH = IMG_WIDTH*IMG_HEIGHT;
    
    // Store image as 28x28 = 724 deep 8-bit wide BRAM
    
    logic [7:0] img_ram [0:IMG_RAM_DEPTH-1];
    
    logic [$clog2(IMG_RAM_DEPTH)-1:0] img_ram_wraddr, img_ram_rdaddr;
    
    logic [7:0] pixel_out_i;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            img_ram_wraddr <= 0;
            img_ram_rdaddr <= 0;
        end else begin
            if (pixel_in_valid) begin
                img_ram[img_ram_wraddr] <= pixel_in;
                img_ram_wraddr          <= img_ram_wraddr + 1;
            end
            if (~hold) begin
                pixel_out_i    <= img_ram[img_ram_rdaddr];
                img_ram_rdaddr <= img_ram_rdaddr + 1;
            end
        end
    end
    
    assign pixel_out = pixel_out_i;
    
endmodule
