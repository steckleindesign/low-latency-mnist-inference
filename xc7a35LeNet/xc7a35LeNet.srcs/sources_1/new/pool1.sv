`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Conv1 data coming in parallel between 6 C1 maps and serially per map

//////////////////////////////////////////////////////////////////////////////////

module pool1(
    input  logic       i_clk,
    input  logic       i_rst,
    input  logic       i_feature_valid,
    input  logic [7:0] i_features[0:5],
    output logic       o_feature_valid,
    output logic [7:0] o_features[0:5]
);
    
    logic [$clog2(14)-1:0] col_cnt = 0;
    logic [$clog2(14)-1:0] row_cnt = 0;
    
    logic [7:0] feature_sr[0:5][0:13];
    
    logic [7:0] reg_0_0[0:5];
    logic [7:0] reg_0_1[0:5];
    logic [7:0] reg_0_c[0:5];
    logic [7:0] reg_1_0[0:5];
    logic [7:0] reg_1_1[0:5];
    logic [7:0] reg_1_c[0:5];
    
    always_ff @(posedge i_clk) begin
        if (i_feature_valid) begin
            for (int i = 0; i < 6; i++) begin
                // Conditional data flow - implemented as logic on D input or as CE?
                if (col_cnt[0]) begin
                    feature_sr[i] <= {feature_sr[i][0:12], reg_0_c};
                    reg_1_1[i] <= reg_1_c[i];
                end else if (~col_cnt[0]) begin
                    reg_1_1[i] <= feature_sr[i][13];
                end
                // Continuous Data flow
                reg_0_0[i] <= i_features[i];
                reg_0_1[i] <= reg_0_0[i];
                reg_0_c[i] <= (reg_0_1[i] > reg_0_0[i]) ? reg_0_1[i] : reg_0_0[i];
                reg_1_0[i] <= i_features[i];
                reg_1_c[i] <= (reg_1_1[i] > reg_1_0[i]) ? reg_1_1[i] : reg_1_0[i];
                o_feature_valid <= row_cnt[0] & col_cnt[0];
            end
            // Counters for control logic
            col_cnt <= col_cnt + 1;
            if (col_cnt == 13) begin
                col_cnt <= 0;
                row_cnt <= row_cnt + 1;
            end
        end
    end

endmodule
