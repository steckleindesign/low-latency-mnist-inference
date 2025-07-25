`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
How is the data coming in from conv1?
    - in parallel between 6 c1 maps and serially per map

How should we develop systemverilog code to store max pool output data into 6 BRAMs?
    - separate BRAM based module after max pool 1 and conv2

What control logic do we need to control data coming out of the 6 S2 BRAMs?
    - A counter compare value or state value to know when data is valid

*/

//////////////////////////////////////////////////////////////////////////////////

module pool2(
    input  logic       i_clk,
    input  logic       i_rst,
    input  logic       i_feature_valid,
    input  logic [7:0] i_features[0:15],
    output logic       o_feature_valid,
    output logic [7:0] o_features[0:15]
);
    
    logic [$clog2(5)-1:0] col_cnt = 0;
    logic [$clog2(5)-1:0] row_cnt = 0;
    
    logic [7:0] feature_sr[0:15][0:4];
    
    logic [7:0] reg_0_0[0:15];
    logic [7:0] reg_0_1[0:15];
    logic [7:0] reg_0_c[0:15];
    
    logic [7:0] reg_1_0[0:15];
    logic [7:0] reg_1_1[0:15];
    logic [7:0] reg_1_c[0:15];
    
    always_ff @(posedge i_clk) begin
        if (i_feature_valid) begin
            for (int i = 0; i < 15; i++) begin
                if (col_cnt[0]) begin
                    feature_sr[i] <= {feature_sr[i][0:3], reg_0_c};
                    reg_1_1[i] <= reg_1_c[i];
                end else if (~col_cnt[0]) begin
                    reg_1_1[i] <= feature_sr[i][4];
                end
                reg_0_0[i] <= i_features[i];
                reg_0_1[i] <= reg_0_0[i];
                reg_0_c[i] <= (reg_0_1[i] > reg_0_0[i]) ? reg_0_1[i] : reg_0_0[i];
                reg_1_0[i] <= i_features[i];
                reg_1_c[i] <= (reg_1_1[i] > reg_1_0[i]) ? reg_1_1[i] : reg_1_0[i];
                o_feature_valid <= row_cnt[0] & col_cnt[0];
            end
            col_cnt <= col_cnt + 1;
            if (col_cnt == 4) begin
                col_cnt <= 0;
                row_cnt <= row_cnt + 1;
            end
        end
    end

endmodule
