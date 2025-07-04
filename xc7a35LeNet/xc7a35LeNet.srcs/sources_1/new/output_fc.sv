`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Connections (# of * ops): 84 * 10 = 840
    Trainable parameters = (84 + 1) * 10 = 850
    @ 90 DSPs, 840 / 90 = 10 clock cycles
    Adder tree latency = $clog2(84) = 7 clock cycles
    Total latency of layer = 10 + 7 = 17 clock cycles
    
    F6 neurons come serially for the current architecture
    we shall wait until all F6 features are valid
*/

//////////////////////////////////////////////////////////////////////////////////

module output_fc (
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
    localparam ADDER_TREE_DEPTH    = $clog2(INPUT_FEATURE_DEPTH)+1;
    
    // Initialize trainable parameters
    // Weights
    // (* rom_style = "block" *)
    logic signed [7:0] weights[0:INPUT_FEATURE_DEPTH-1]
                              [0:NUM_CLASSES-1];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    // (* rom_style = "block" *)
    logic signed [7:0] biases[0:NUM_CLASSES-1];
    initial $readmemb(BIASES_FILE, biases);

    logic [7:0] upstream_features[0:INPUT_FEATURE_DEPTH-1];
    logic [$clog2(INPUT_FEATURE_DEPTH)-1:0] upstream_features_cnt;
    
    logic [$clog2(NUM_CLASSES)+ADDER_TREE_DEPTH-1:0] layer_cycle_num;
    
    logic        is_processing;
    logic [15:0] done_sr;
    logic        output_valid;
    
    // logic [15:0] neurons[0:9];
    logic [19:0] internal_result_bus; // {4-bit class, 16-bit magnitude}
    
    // Adder tree structure (depth = 8)
    logic [15:0] adder_stage1[0:83];
    logic [15:0] adder_stage2[0:41];
    logic [15:0] adder_stage3[0:20];
    logic [15:0] adder_stage4[0:10];
    logic [15:0] adder_stage5[0:5];
    logic [15:0] adder_stage6[0:2];
    logic [15:0] adder_stage7[0:1];
    logic [15:0] adder_result;
    logic        adder_result_valid;
    
    always_ff @(posedge i_clk)
        if (i_rst) begin
            output_valid          <= 0;
            is_processing         <= 0;
            upstream_features_cnt <= 0;
            layer_cycle_num       <= 0;
        end else begin
            output_valid <= 0;
            
            if (i_feature_valid) begin
                upstream_features[upstream_features_cnt] <= i_feature;
                upstream_features_cnt <= upstream_features_cnt + 1;
                if (upstream_features_cnt == 7'd83)
                    is_processing <= 1;
            end
            
            if (is_processing) begin
                done_sr <= {done_sr[14:0], 1'b1};
                layer_cycle_num <= layer_cycle_num + 1;
            end
                
            if (done_sr[15]) begin
                is_processing   <= 0;
                output_valid    <= 1;
                layer_cycle_num <= 0;
            end
        end
    
    always_ff @(posedge i_clk) begin
        for (int i = 0; i < INPUT_FEATURE_DEPTH; i++)
            adder_stage1[i] <= upstream_features[i] * weights[?][i]; // TODO: Global weight FIFOs
    
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
    
    always_ff @(posedge i_clk)
        if (layer_cycle_num > 8)
            if (adder_result > internal_result_bus[15:0])
                internal_result_bus <= { layer_cycle_num, adder_result};
    
    always_comb begin
        o_result_valid <= output_valid;
        o_result       <= internal_result_bus[19:16] - ADDER_TREE_DEPTH;
    end

endmodule