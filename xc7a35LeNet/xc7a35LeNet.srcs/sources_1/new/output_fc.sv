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

    localparam INPUT_FEATURE_DEPTH = 84;

    logic            [15:0] upstream_feature_data[0:119];
    logic [$clog2(120)-1:0] upstream_feature_cnt;

    logic [15:0] neurons[0:9];
    logic  [3:0] neuron_cnt;
    
    logic is_processing;
    logic done;
    
    // Create single adder tree structure (depth = 8)
    logic [15:0] adder_stage1[0:83];
    logic [15:0] adder_stage2[0:41];
    logic [15:0] adder_stage3[0:20];
    logic [15:0] adder_stage4[0:10];
    logic [15:0] adder_stage5[0:5];
    logic [15:0] adder_stage6[0:2];
    logic [15:0] adder_stage7[0:1];
    logic [15:0] adder_result;
    logic        adder_result_valid;
    
    always_ff @(posedge i_clk) begin
        if (i_feature_valid) begin
            upstream_feature_data[upstream_feature_cnt] <= i_feature;
            upstream_feature_cnt <= upstream_feature_cnt + 1;
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (i_feature)
            is_processing <= 1;
        else if (done) begin
            is_processing <= 0;
            neuron_cnt    <= 0;
        end
        neuron_cnt <= neuron_cnt + 1;
    end
    
    always_ff @(posedge i_clk) begin
        for (int i = 0; i < INPUT_FEATURE_DEPTH; i++)
            adder_stage1[i] <=
                upstream_feature_data[i] *
                    weights[neuron_cnt][i];
    
        for (int i = 0; i < 42; i++)
            adder_stage2[i] <= adder_stage1[i*2] + adder_stage1[i*2+1];
    
        for (int i = 0; i < 21; i++)
            adder_stage3[i] <= adder_stage2[i*2] + adder_stage2[i*2+1];
    
        adder_stage4[10] <= adder_stage3[21];
        for (int i = 0; i < 10; i++)
            adder_stage4[i] <= adder_stage3[i*2] + adder_stage3[i*2+1];
    
        adder_stage5[5] <= adder_stage4[10];
        for (int i = 0; i < 5; i++)
            adder_stage5[i] <= adder_stage4[i*2] + adder_stage4[i*2+1];
    
        for (int i = 0; i < 3; i++)
            adder_stage6[i] <= adder_stage5[i*2] + adder_stage5[i*2+1];
    
        adder_stage7[1] <= adder_stage6[2];
        adder_stage7[0] <= adder_stage6[0] + adder_stage6[1];
    
        adder_result <= adder_stage7[0] + adder_stage7[1];
    end
    
    always_comb
        done <= neuron_cnt == 4'd9;

endmodule