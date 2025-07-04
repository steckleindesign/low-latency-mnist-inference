`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
Can still use FIFO18 here similar to the FIFO after s4

What control logic do we need to control data coming out of the 6 S2 BRAMs?
    - A counter compare value or state value to know when data is valid
*/

//////////////////////////////////////////////////////////////////////////////////

module s2_ram_c3(
    input  logic       clk,
    input  logic       rst,
    input  logic       din_valid,
    input  logic [7:0] din[0:5],
    input  logic       dout_valid,
    output logic [7:0] dout[0:5]
);
    
    // 6xBRAMFIFO -> FIFO18E1 2k x 9 -> 144x8-bits used
    generate
    genvar i;
    for (i = 0; i < 6; i++)
        fifo_generator_1 c3_fifo (.clk(clk),
                                  .rst(rst),
                                  .din(din[i]),
                                  .wr_en(din_valid),
                                  .rd_en(), // once the fifo is near full (once of DSPs are done multiplying conv1)
                                  .dout(dout[i]),
                                  .full(), // should never be reach
                                  .empty(), // NC
                                  .valid(dout_valid), // Perhaps this module port needs to AND dout_valid and other control for when data should truly be consumed by the next layer
                                  .prog_full(fifo_almost_full), // To be used to control read enable
                                  .prog_empty(fifo_almost_empty)); // NC
    endgenerate

endmodule