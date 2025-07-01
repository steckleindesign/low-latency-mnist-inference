`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module pool #(
    parameter NUM_FEATURE_MAPS  = 6,
    parameter FEATURE_MAP_WIDTH = 28,
    parameter DATA_WIDTH        = 8
)(
    input  logic                  i_clk,
    input  logic                  i_rst,
    input  logic                  i_feature_valid,
    input  logic [DATA_WIDTH-1:0] i_features[0:NUM_FEATURE_MAPS-1],
    output logic                  o_feature_valid,
    output logic [DATA_WIDTH-1:0] o_features[0:NUM_FEATURE_MAPS-1]
);
    
    logic [$clog2(FEATURE_MAP_WIDTH/2)-1:0] col_cnt = 0;
    logic [$clog2(FEATURE_MAP_WIDTH/2)-1:0] row_cnt = 0;
    
    logic [DATA_WIDTH-1:0] feature_sr[0:NUM_FEATURE_MAPS-1]
                                     [0:FEATURE_MAP_WIDTH/2-1];
    
    logic [DATA_WIDTH-1:0] reg_0_0[0:NUM_FEATURE_MAPS-1];
    logic [DATA_WIDTH-1:0] reg_0_1[0:NUM_FEATURE_MAPS-1];
    logic [DATA_WIDTH-1:0] reg_0_c[0:NUM_FEATURE_MAPS-1];
    
    logic [DATA_WIDTH-1:0] reg_1_0[0:NUM_FEATURE_MAPS-1];
    logic [DATA_WIDTH-1:0] reg_1_1[0:NUM_FEATURE_MAPS-1];
    logic [DATA_WIDTH-1:0] reg_1_c[0:NUM_FEATURE_MAPS-1];
    
    always_ff @(posedge i_clk) begin
        if (i_feature_valid) begin
            for (int i = 0; i < NUM_FEATURE_MAPS; i++) begin
                if (col_cnt[0]) begin
                    feature_sr[i] <= {
                        feature_sr[i][0:FEATURE_MAP_WIDTH/2-2],
                        reg_0_c
                    };
                    reg_1_1[i] <= reg_1_c[i];
                end else if (~col_cnt[0]) begin
                    reg_1_1[i] <= feature_sr[i][FEATURE_MAP_WIDTH/2-1];
                end
                reg_0_0[i] <= i_features[i];
                reg_0_1[i] <= reg_0_0[i];
                reg_0_c[i] <= (reg_0_1[i] > reg_0_0[i]) ? reg_0_1[i] : reg_0_0[i];
                reg_1_0[i] <= i_features[i];
                reg_1_c[i] <= (reg_1_1[i] > reg_1_0[i]) ? reg_1_1[i] : reg_1_0[i];
                o_feature_valid <= row_cnt[0] & col_cnt[0];
            end
            col_cnt <= col_cnt + 1;
            if (col_cnt == FEATURE_MAP_WIDTH/2-1) begin
                col_cnt <= 0;
                row_cnt <= row_cnt + 1;
            end
        end
    end

endmodule
