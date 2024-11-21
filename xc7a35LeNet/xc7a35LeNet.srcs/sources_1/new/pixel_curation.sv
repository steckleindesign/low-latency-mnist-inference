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

    wire [9:0] vector_pos_upper;

    // 2FF synchronizer for SPI to global clock domain cross
    reg            sync_ff0       = 1'b0; 
    reg            sync_ff1       = 1'b0;
    reg            sync_ff2       = 1'b0;
 
    reg      [6:0] byte_cnt     = 7'b0;
    logic [1023:0] image_vector = 1024'b0;
    
    task convert_1d_to_2d(input logic [1023:0] data);
        int x, y;
        for (int i = 0; i < 1024; i++)
        begin
            indices_1d_to_2d(i, x, y);
            o_image[x][y] = {6'b0, data[i]};
        end
    endtask
    
    function void indices_1d_to_2d(input int vector_index, output int x, output int y);
        x = vector_index / 32;
        y = vector_index % 32;
    endfunction
    
    always_ff @(posedge i_clk)
    begin
        sync_ff0 <= i_wr_req;
        sync_ff1 <= sync_ff0;
        sync_ff2 <= sync_ff1;
        if (~sync_ff1 & sync_ff2)
        begin
            image_vector <= {image_vector[1015:0], i_pixel_data};
            o_data_ready <= byte_cnt == 7'd127;
            byte_cnt     <= byte_cnt + 1'b1;
        end
    end
        
endmodule
