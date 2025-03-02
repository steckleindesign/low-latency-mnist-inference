`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
Registers
    row buffer
    
    


1) Consume 1 row
    Every second feature
        compare that and the previous adjacent value
            if 2nd value is max, then replace with max value
2) Consume second row
    every first feature
        if feature in is greater than column above,
            replace the row buf column with the feature
    every 2nd feature consumed, compute the max
    
    
    

*/

//////////////////////////////////////////////////////////////////////////////////

module pool1(
    input  logic               clk,
    input  logic               rst,
    input  logic               valid,
    input  logic signed [15:0] features[0:5],
    output logic               feature_out
);
    
    logic first_row;
    logic [4:0] col;

    logic signed [15:0] row_buf [0:27];
    initial row_buf = '{default: 0};
    logic 
    
    always_ff @(clk)
    begin
        if (rst)
        begin
            first_row <= 1;
            col       <= 0;
        end
        else
        begin
            if (valid)
            begin
                col <= col + 1;
                if (col == 5'd26)
                begin
                    col       <= 0;
                    first_row <= 0;
                    row_buf[0] <= row_buf[1];
                end
                row_buf[!first_row][col] <= features;
            end
        end
    end

endmodule
