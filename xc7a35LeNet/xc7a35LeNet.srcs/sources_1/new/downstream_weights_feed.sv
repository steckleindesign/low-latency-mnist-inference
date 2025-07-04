`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module downstream_weights_feed (
    input  logic clk,
    input  logic rst,
    input  logic [3:0] feed_cycle, // Feed weights to conv2, conv3, fc, output layers
    output logic [7:0] weight_operands_out[0:89]
);

    logic  [7:0] weights_ram[0:89][0:2047]; // Really 2k x 9 in the hardware primitive mode
    logic [11:0] weights_ram_addr;

    always_ff @(posedge clk) begin
        if (|feed_cycle) begin
            weight_operands_out <= weights_ram[weights_ram_addr];
            weights_ram_addr    <= weights_ram_addr + 1;
        end
    end

endmodule