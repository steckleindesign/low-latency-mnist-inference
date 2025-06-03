`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Connections (# of * ops): 84 * 10 = 840
    
    Trainable parameters = (84 + 1) * 10 = 850
    
    @ 90 DSPs, 840 / 90 = 10 clock cycles
    
    We will have a remainder of 60 DSPs, the last cycle.
    What can we do to be more efficient with the DSPs?
    Perhaps some operations for the next conv1 layer? - minimal pipelining could help throughout slightly
    
    We could also just allocate 1 DSP per feature so 6 DSPs would just be unused
    
    Adder trees: 85 operands, $clog2(85) = 7 clock cycles, latency of layer should be 17 clock cycles
*/

//////////////////////////////////////////////////////////////////////////////////

module output_fc #(
    parameter WIDTH = 16
)(
    input    logic            i_clk,
    input    logic            i_rst,
    input    logic            i_feature_valid,
    input    logic     [15:0] i_feature,
    output   logic            o_neuron_valid,
    output   logic     [15:0] o_neuron
);

    logic [15:0] neurons[0:9];
    logic  [3:0] neuron_cnt;
    
    logic is_processing;
    logic done;
    
    // Create single adder tree structure (depth = 8)
    
    always_ff @(posedge i_clk) begin
        if (i_feature)
            is_processing <= 1;
        else if (done) begin
            is_processing <= 0;
            neuron_cnt    <= 0;
        end
        neuron_cnt <= neuron_cnt + 1;
    end

endmodule