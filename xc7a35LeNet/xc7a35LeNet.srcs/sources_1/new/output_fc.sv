`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Connections (# of * ops): 84 * 10 = 840
    Trainable parameters = (84 + 1) * 10 = 850
    @ 90 DSPs, 840 / 90 = 10 clock cycles
    Adder tree latency = $clog2(84) = 7 clock cycles
    Total latency of layer = 10 + 7 = 17 clock cycles
    
    Theory of operation
    1) 84 neurons come in serially, buffer them into 84x8-bit parallel neurons, enable MACC when full
    2) When MACC is enabled, register the 84 values into the A inputs of 84 DSP48E1s, set bit 0 of valid shreg
    3) When Preg is valid, put 84 multiply results into adder tree root combinatorial logic
    
*/

//////////////////////////////////////////////////////////////////////////////////

module output_fc (
    input  logic       i_clk,
    input  logic       i_rst,
    input  logic       i_feature_valid,
    input  logic [7:0] i_feature,
    output logic       o_result_valid,
    output logic [3:0] o_result
);

    localparam INPUT_FEATURE_DEPTH = 84;
    localparam NUM_CLASSES         = 10;
    
     // Weights
     localparam string WEIGHTS_FILE = "weights.mem";
     logic signed [7:0] weights[0:INPUT_FEATURE_DEPTH-1][0:NUM_CLASSES-1];
     initial $readmemb(WEIGHTS_FILE, weights);
    
    // Biases
    localparam string BIASES_FILE = "biases.mem";
    logic signed [7:0] biases[0:NUM_CLASSES-1];
    initial $readmemb(BIASES_FILE, biases);
    
    logic                                   macc_en;

    logic signed                      [7:0] upstream_features[0:INPUT_FEATURE_DEPTH-1];
    logic [$clog2(INPUT_FEATURE_DEPTH)-1:0] upstream_features_cnt;
    
    logic                            [11:0] class_valid_sr;
    
    logic         [$clog2(NUM_CLASSES)-1:0] operand_load_cnt;
    
    logic signed                      [7:0] feature_operands[0:INPUT_FEATURE_DEPTH-1];
    logic signed                      [7:0] weight_operands[0:INPUT_FEATURE_DEPTH-1];
    logic signed                      [7:0] A1reg[0:INPUT_FEATURE_DEPTH-1];
    logic signed                      [7:0] B1reg[0:INPUT_FEATURE_DEPTH-1];
    logic signed                      [7:0] A2reg[0:INPUT_FEATURE_DEPTH-1];
    logic signed                      [7:0] B2reg[0:INPUT_FEATURE_DEPTH-1];
    logic signed                      [7:0]  Mreg[0:INPUT_FEATURE_DEPTH-1];
    logic signed                      [7:0]  Preg[0:INPUT_FEATURE_DEPTH-1];
        
    logic signed                      [7:0] adder_stage2[0:41];
    logic signed                      [7:0] adder_stage3[0:20];
    logic signed                      [7:0] adder_stage4[0:10];
    logic signed                      [7:0] adder_stage5[0:5];
    logic signed                      [7:0] adder_stage6[0:2];
    logic signed                      [7:0] adder_stage7[0:1];
    logic signed                      [7:0] adder_result;
    
    logic         [$clog2(NUM_CLASSES)-1:0] class_valid_cnt;
    
    // {4-bit class, 8-bit magnitude}
    logic       [$clog2(NUM_CLASSES)+8-1:0] internal_result_bus;
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            macc_en               <= 0;
            upstream_features_cnt <= 0;
        end else begin
            if (i_feature_valid) begin
                upstream_features[upstream_features_cnt] <= i_feature;
                upstream_features_cnt <= upstream_features_cnt + 1;
                if (upstream_features_cnt == (INPUT_FEATURE_DEPTH-1)) begin
                    macc_en               <= 1;
                    upstream_features_cnt <= 0;
                end
                if (class_valid_cnt == (NUM_CLASSES-1)) begin
                    macc_en <= 0;
                end
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            operand_load_cnt <= 0;
            class_valid_sr   <= {class_valid_sr[10:0], 1'b0};
        end else begin
            class_valid_sr <= {class_valid_sr[10:0], 1'b0};
            if (macc_en && (operand_load_cnt < NUM_CLASSES)) begin
                operand_load_cnt <= operand_load_cnt + 1;
                feature_operands <= upstream_features;
                weight_operands  <= weights[operand_load_cnt];
                class_valid_sr   <= {class_valid_sr[10:0], 1'b1};
            end
            if (class_valid_cnt == (NUM_CLASSES-1)) begin
                operand_load_cnt <= 0;
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            for (int i = 0; i < INPUT_FEATURE_DEPTH; i++) begin
                A1reg[i] <= feature_operands[i];
                B1reg[i] <= weight_operands[i];
                A2reg[i] <= A1reg[i];
                B2reg[i] <= B1reg[i];
                Mreg [i] <= A2reg[i] * B2reg[i];
                Preg [i] <= Mreg[i];
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        for (int i = 0; i < 42; i++)
            adder_stage2[i] <= Preg[i*2] + Preg[i*2+1];
    
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
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            internal_result_bus <= 0;
            class_valid_cnt     <= 0;
        end else begin
            if (class_valid_sr[11]) begin
                if (adder_result > internal_result_bus[15:0]) begin
                    internal_result_bus <= { class_valid_cnt, adder_result};
                end
                class_valid_cnt <= class_valid_cnt + 1;
                if (class_valid_cnt == (NUM_CLASSES-1)) begin
                    class_valid_cnt     <= 0;
                    internal_result_bus <= 0;
                end
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        o_result_valid <= class_valid_cnt == (NUM_CLASSES-1) ? 1'b1 : 1'b0;
        o_result       <= internal_result_bus[$clog2(NUM_CLASSES)+8-1:8];
    end

endmodule