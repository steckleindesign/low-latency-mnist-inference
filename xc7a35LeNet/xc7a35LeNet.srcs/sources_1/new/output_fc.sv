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
    input  logic        i_clk,
    input  logic        i_rst,
    input  logic        i_feature_valid,
    input  logic [15:0] i_feature,
    output logic        o_result_valid,
    output logic  [3:0] o_result
);

    localparam string WEIGHTS_FILE = "weights.mem";
    localparam string BIASES_FILE  = "biases.mem";

    localparam INPUT_FEATURE_DEPTH = 84;
    localparam NUM_CLASSES         = 10;
    
    // Initialize trainable parameters
    // Weights
    // (* rom_style = "block" *)
    logic signed [15:0]
    weights [0:INPUT_FEATURE_DEPTH-1][0:NUM_CLASSES-1];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    // (* rom_style = "block" *)
    logic signed [15:0]
    biases [0:NUM_CLASSES-1];
    initial $readmemb(BIASES_FILE, biases);

    logic                            [15:0] upstream_feature_data[0:119];
    logic [$clog2(INPUT_FEATURE_DEPTH)-1:0] upstream_feature_cnt;

    logic        is_processing;
    logic [15:0] done_sr;
    
    logic [15:0] neurons[0:9];
    logic  [3:0] neuron_cnt;
    
    logic [19:0] internal_result_bus; // {4-bit class, 16-bit magnitude}
    
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
        o_result_valid <= 0;
        if (i_feature_valid && ~is_processing) begin
            upstream_feature_data[upstream_feature_cnt] <= i_feature;
            upstream_feature_cnt <= upstream_feature_cnt + 1;
            if (upstream_feature_cnt == 7'd83) is_processing <= 1;
        end else if (done_sr[15]) begin
            is_processing  <= 0;
            neuron_cnt     <= 0;
            o_result_valid <= 1;
        end else
            neuron_cnt <= neuron_cnt + 1;
    
        // Use shift register for done signal
        // SRL16 only takes single LUT
        if (is_processing)
            done_sr <= {done_sr[14:0], 1'b1};
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
    
    // Can DSP48E1 do the compare function?
    always_ff @(posedge i_clk)
        // As a class magnitude is finalized every clock cycle,
        // compare with the current highest magnitude to determine
        // largest class and store new class and magnitude in bus register
        // "If an adder result is ready"
        // "We use neuron cnt to check because we
        // can't access the value of the done SR"
        // TODO: Fix logic, this is prone so many bugs
        // Neuron cnt is only 4 bits, so it might not be able
        // to count as high as we need
        // Also there is going to need to be extra logic somewhere
        // To subract the offset of the neuron count so that the
        // correct value is set in internal_result_bus[19:16]
        if (neuron_cnt > 8)
            if (adder_result > internal_result_bus[15:0])
                internal_result_bus <= { neuron_cnt, adder_result};
    
    always_comb
        o_result <= internal_result_bus[19:16];

endmodule