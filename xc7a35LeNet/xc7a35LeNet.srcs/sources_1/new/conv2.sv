`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    S2 feature maps are connected to C3 feature maps as follows:
    Map  0: 0, 1, 2
    Map  1: 1, 2, 3
    Map  2: 2, 3, 4
    Map  3: 3, 4, 5
    Map  4: 0, 4, 5
    Map  5: 0, 1, 5
    Map  6: 0, 1, 2, 3
    Map  7: 1, 2, 3, 4
    Map  8: 2, 3, 4, 5
    Map  9: 0, 3, 4, 5
    Map 10: 0, 1, 4, 5
    Map 11: 0, 1, 2, 5
    Map 12: 0, 1, 3, 4
    Map 13: 1, 2, 4, 5
    Map 14: 0, 2, 3, 5
    Map 15: 0, 1, 2, 3, 4, 5
    
    Trainable parameters = (6*3 + 9*4 + 6) * (5*5) + 6 + 9 + 1 = 1516
    Num multiplies       = (6*3 + 9*4 + 6) * (10*10*5*5) = 10*10*(1516-16) = 150000
    Clock cycles when 100% DSP48E1 utilization w/ no overclocking = 150000/90 = 1666.67 = 1667
    
    Theory of operation:
    1) Gather features into 6 14x14 8-bit input feature maps. 6x25 8x8-bit Distributed RAMs
    2) When the feature buffer is full MACC operations should begin
    3) MACC operation consists of 25 cycles per output feature accumulation, 2D convolution counter
        iterates from 0 to 9, left to right, top to bottom. 2D kernel counter counts from 0 to 4,
            left to right, top to bottom. Address to weights is kernel counter, address to features
                is convolution counter + kernel counter
    4) During multiplications, connect P reg of * DSPs to first stage pipeline registers of + DSPs
    5) Use DSPs to add convolution MACCs into 16 C3 feature maps
    
    Takes 10*10*5*5 = 2500 cycles of multiplies
    
    
    FUTURE IDEAS
    -------------------------------------------------------------------------------
    Potential mapping of the 18 DSP groups by cycle
    cyc 1:         cyc 2:         cyc 3:         cyc 4:         cyc 5:
        row 1: 4       row 1: 4       row 1: 3       row 1: 4       row 1: 3
        row 2: 4       row 2: 3       row 2: 4       row 2: 4       row 2: 3
        row 3: 4       row 3: 3       row 3: 4       row 3: 3       row 3: 4
        row 4: 3       row 4: 4       row 4: 4       row 4: 3       row 4: 4
        row 5: 3       row 5: 4       row 5: 3       row 5: 4       row 5: 4
    
    Adder tree structure:
    Instead of having wide multiplexers on the outputs of the MACC operations,
    just store the data into a big SR and after the MACC operations finished
    processing we can shift out the processed data and we know the order
    We'll have 6 SRs, 1 for each S2 map. Each SR will be 10x9x9x8-bit = 6480 bits
    May need to store data in BRAMs. Study mux structure on the output datapath.
    
    Total of 10x10 = 100 kernels in each S2 map
    If we only process 9x9, then there is 81 kernels.
    Then there would be 2x81 = 162 kernels in 2 S2 maps.
    So it would take 162/18 * 5 = 45 cycles to compute the *
    for 2 full feature maps, and 5x45=225 cycles to
    process all multiplies for the 10 iterations over a single
    S2 map. So 6x225=1350 cycles for all multiply operations
    in the covolution computation for conv2.
    ______________________________________
    Maps:         \ 1 \ 2 \ 3 \ 4 \ 5 \ 6 \
    _______________________________________
    6 DSP groups: \ 6 \   \   \   \   \   \
    6 DSP groups: \ 4 \ 2 \   \   \   \   \
    6 DSP groups: \   \ 6 \   \   \   \   \
    6 DSP groups: \   \ 2 \ 4 \   \   \   \
    6 DSP groups: \   \   \ 6 \   \   \   \
    6 DSP groups: \   \   \   \ 6 \   \   \
    6 DSP groups: \   \   \   \ 4 \ 2 \   \
    6 DSP groups: \   \   \   \   \ 6 \   \
    6 DSP groups: \   \   \   \   \ 2 \ 4 \
    6 DSP groups: \   \   \   \   \   \ 6 \
    
    We are only doing 10x10 convolutions and there are 10 weight kernels for each S2 map and 90 DSPs.
    
    So we divide DSPs into 10 groups of 9. Each DSP group has the job of working on its own row.
    It will take 25 clock cycles For each of these rows.
    
    16 10x10 output feature maps = 1600 8-bit values = 12,800 bits
    So there are 1600 accumulate values.
    -------------------------------------------------------------------------------
    
*/

//////////////////////////////////////////////////////////////////////////////////

module conv2(
    input  logic              i_clk,
    input  logic              i_rst,
    input  logic              i_feature_valid,
    input  logic signed [7:0] i_features[0:5],
    output logic              o_feature_valid,
    output logic signed [7:0] o_features[0:15]
);

    localparam WEIGHTS_FILE = "conv2_weights.mem";
    logic signed [7:0] weights[0:5][0:9][0:4][0:4];
    initial $readmemb(WEIGHTS_FILE, weights);
    
    localparam BIASES_FILE = "conv2_biases.mem";
    logic signed [7:0] biases[0:5][0:9];
    initial $readmemb(BIASES_FILE, biases);
    
    logic                         macc_en;
    
    logic signed            [7:0] s2_map[0:5][0:13][0:13];
    
    logic        [$clog2(14)-1:0] input_feature_col_cnt;
    logic        [$clog2(14)-1:0] input_feature_row_cnt;
    
    logic        [$clog2(10)-1:0] mult_feature_col_cnt;
    logic        [$clog2(10)-1:0] mult_feature_row_cnt;
    
    logic         [$clog2(5)-1:0] mult_kernel_col_cnt;
    logic         [$clog2(5)-1:0] mult_kernel_row_cnt;
    
    logic                   [9:0] mult_result_valid_sr;
    
    logic signed            [7:0] first_stage_macc_dsps_dualAD1reg[0:5][0:9];
    logic signed            [7:0]  first_stage_macc_dsps_dualB1reg[0:5][0:9];
    logic signed            [7:0] first_stage_macc_dsps_dualAD2reg[0:5][0:9];
    logic signed            [7:0]  first_stage_macc_dsps_dualB2reg[0:5][0:9];
    logic signed            [7:0]       first_stage_macc_dsps_Mreg[0:5][0:9];
    logic signed            [7:0]       first_stage_macc_dsps_Preg[0:5][0:9];
    
    // Syntax simplify so we don't have so many signals
    logic [15:0] adder_dsp_0_A1;
    logic [15:0] adder_dsp_0_A2;
    logic [15:0] adder_dsp_0_FFD;
    logic [15:0] adder_dsp_0_D;
    logic [15:0] adder_dsp_0_AD;
    logic [15:0] adder_dsp_0_M;
    logic [15:0] adder_dsp_0_FFC0;
    logic [15:0] adder_dsp_0_FFC1;
    logic [15:0] adder_dsp_0_FFC2;
    logic [15:0] adder_dsp_0_C;
    logic [15:0] adder_dsp_0_P;
    
    logic [15:0] adder_dsp_1_A1;
    logic [15:0] adder_dsp_1_A2;
    logic [15:0] adder_dsp_1_FFD;
    logic [15:0] adder_dsp_1_D;
    logic [15:0] adder_dsp_1_AD;
    logic [15:0] adder_dsp_1_M;
    logic [15:0] adder_dsp_1_FFC0;
    logic [15:0] adder_dsp_1_FFC1;
    logic [15:0] adder_dsp_1_FFC2;
    logic [15:0] adder_dsp_1_C;
    logic [15:0] adder_dsp_1_P;
    
    logic [15:0] adder_dsp_2_A1;
    logic [15:0] adder_dsp_2_A2;
    logic [15:0] adder_dsp_2_FFD;
    logic [15:0] adder_dsp_2_D;
    logic [15:0] adder_dsp_2_AD;
    logic [15:0] adder_dsp_2_M;
    logic [15:0] adder_dsp_2_FFC0;
    logic [15:0] adder_dsp_2_FFC1;
    logic [15:0] adder_dsp_2_FFC2;
    logic [15:0] adder_dsp_2_C;
    logic [15:0] adder_dsp_2_P;
    
    logic [15:0] adder_dsp_3_A1;
    logic [15:0] adder_dsp_3_A2;
    logic [15:0] adder_dsp_3_FFD;
    logic [15:0] adder_dsp_3_D;
    logic [15:0] adder_dsp_3_AD;
    logic [15:0] adder_dsp_3_M;
    logic [15:0] adder_dsp_3_FFC0;
    logic [15:0] adder_dsp_3_FFC1;
    logic [15:0] adder_dsp_3_FFC2;
    logic [15:0] adder_dsp_3_C;
    logic [15:0] adder_dsp_3_P;
    
    logic [15:0] adder_dsp_4_A1;
    logic [15:0] adder_dsp_4_A2;
    logic [15:0] adder_dsp_4_FFD;
    logic [15:0] adder_dsp_4_D;
    logic [15:0] adder_dsp_4_AD;
    logic [15:0] adder_dsp_4_M;
    logic [15:0] adder_dsp_4_FFC0;
    logic [15:0] adder_dsp_4_FFC1;
    logic [15:0] adder_dsp_4_FFC2;
    logic [15:0] adder_dsp_4_C;
    logic [15:0] adder_dsp_4_P;
    
    logic [15:0] adder_dsp_5_A1;
    logic [15:0] adder_dsp_5_A2;
    logic [15:0] adder_dsp_5_FFD;
    logic [15:0] adder_dsp_5_D;
    logic [15:0] adder_dsp_5_AD;
    logic [15:0] adder_dsp_5_M;
    logic [15:0] adder_dsp_5_FFC0;
    logic [15:0] adder_dsp_5_FFC1;
    logic [15:0] adder_dsp_5_FFC2;
    logic [15:0] adder_dsp_5_C;
    logic [15:0] adder_dsp_5_P;
    
    
    logic [15:0] adder_dsp_6_A1;
    logic [15:0] adder_dsp_6_A2;
    logic [15:0] adder_dsp_6_FFD;
    logic [15:0] adder_dsp_6_D;
    logic [15:0] adder_dsp_6_AD;
    logic [15:0] adder_dsp_6_M;
    logic [15:0] adder_dsp_6_FFC0;
    logic [15:0] adder_dsp_6_FFC1;
    logic [15:0] adder_dsp_6_FFC2;
    logic [15:0] adder_dsp_6_C;
    logic [15:0] adder_dsp_6_P;
    
    logic [15:0] adder_dsp_7_FFC0;
    logic [15:0] adder_dsp_7_FFC1;
    logic [15:0] adder_dsp_7_FFC2;
    logic [15:0] adder_dsp_7_FFC3;
    logic [15:0] adder_dsp_7_C;
    logic [15:0] adder_dsp_7_P;
    
    logic [15:0] adder_dsp_8_A1;
    logic [15:0] adder_dsp_8_A2;
    logic [15:0] adder_dsp_8_FFD;
    logic [15:0] adder_dsp_8_D;
    logic [15:0] adder_dsp_8_AD;
    logic [15:0] adder_dsp_8_M;
    logic [15:0] adder_dsp_8_FFC0;
    logic [15:0] adder_dsp_8_FFC1;
    logic [15:0] adder_dsp_8_FFC2;
    logic [15:0] adder_dsp_8_C;
    logic [15:0] adder_dsp_8_P;
    
    logic [15:0] adder_dsp_9_FFC0;
    logic [15:0] adder_dsp_9_FFC1;
    logic [15:0] adder_dsp_9_FFC2;
    logic [15:0] adder_dsp_9_FFC3;
    logic [15:0] adder_dsp_9_C;
    logic [15:0] adder_dsp_9_P;
    
    logic [15:0] adder_dsp_10_A1;
    logic [15:0] adder_dsp_10_A2;
    logic [15:0] adder_dsp_10_FFD;
    logic [15:0] adder_dsp_10_D;
    logic [15:0] adder_dsp_10_AD;
    logic [15:0] adder_dsp_10_M;
    logic [15:0] adder_dsp_10_FFC0;
    logic [15:0] adder_dsp_10_FFC1;
    logic [15:0] adder_dsp_10_FFC2;
    logic [15:0] adder_dsp_10_C;
    logic [15:0] adder_dsp_10_P;
    
    logic [15:0] adder_dsp_11_FFC0;
    logic [15:0] adder_dsp_11_FFC1;
    logic [15:0] adder_dsp_11_FFC2;
    logic [15:0] adder_dsp_11_FFC3;
    logic [15:0] adder_dsp_11_C;
    logic [15:0] adder_dsp_11_P;
    
    logic [15:0] adder_dsp_12_A1;
    logic [15:0] adder_dsp_12_A2;
    logic [15:0] adder_dsp_12_FFD;
    logic [15:0] adder_dsp_12_D;
    logic [15:0] adder_dsp_12_AD;
    logic [15:0] adder_dsp_12_M;
    logic [15:0] adder_dsp_12_FFC0;
    logic [15:0] adder_dsp_12_FFC1;
    logic [15:0] adder_dsp_12_FFC2;
    logic [15:0] adder_dsp_12_C;
    logic [15:0] adder_dsp_12_P;
    
    logic [15:0] adder_dsp_13_FFC0;
    logic [15:0] adder_dsp_13_FFC1;
    logic [15:0] adder_dsp_13_FFC2;
    logic [15:0] adder_dsp_13_FFC3;
    logic [15:0] adder_dsp_13_C;
    logic [15:0] adder_dsp_13_P;
    
    logic [15:0] adder_dsp_14_A1;
    logic [15:0] adder_dsp_14_A2;
    logic [15:0] adder_dsp_14_FFD;
    logic [15:0] adder_dsp_14_D;
    logic [15:0] adder_dsp_14_AD;
    logic [15:0] adder_dsp_14_M;
    logic [15:0] adder_dsp_14_FFC0;
    logic [15:0] adder_dsp_14_FFC1;
    logic [15:0] adder_dsp_14_FFC2;
    logic [15:0] adder_dsp_14_C;
    logic [15:0] adder_dsp_14_P;
    
    logic [15:0] adder_dsp_15_FFC0;
    logic [15:0] adder_dsp_15_FFC1;
    logic [15:0] adder_dsp_15_FFC2;
    logic [15:0] adder_dsp_15_FFC3;
    logic [15:0] adder_dsp_15_C;
    logic [15:0] adder_dsp_15_P;
    
    logic [15:0] adder_dsp_16_A1;
    logic [15:0] adder_dsp_16_A2;
    logic [15:0] adder_dsp_16_FFD;
    logic [15:0] adder_dsp_16_D;
    logic [15:0] adder_dsp_16_AD;
    logic [15:0] adder_dsp_16_M;
    logic [15:0] adder_dsp_16_FFC0;
    logic [15:0] adder_dsp_16_FFC1;
    logic [15:0] adder_dsp_16_FFC2;
    logic [15:0] adder_dsp_16_C;
    logic [15:0] adder_dsp_16_P;
    
    logic [15:0] adder_dsp_17_FFC0;
    logic [15:0] adder_dsp_17_FFC1;
    logic [15:0] adder_dsp_17_FFC2;
    logic [15:0] adder_dsp_17_FFC3;
    logic [15:0] adder_dsp_17_C;
    logic [15:0] adder_dsp_17_P;
    
    logic [15:0] adder_dsp_18_A1;
    logic [15:0] adder_dsp_18_A2;
    logic [15:0] adder_dsp_18_FFD;
    logic [15:0] adder_dsp_18_D;
    logic [15:0] adder_dsp_18_AD;
    logic [15:0] adder_dsp_18_M;
    logic [15:0] adder_dsp_18_FFC0;
    logic [15:0] adder_dsp_18_FFC1;
    logic [15:0] adder_dsp_18_FFC2;
    logic [15:0] adder_dsp_18_C;
    logic [15:0] adder_dsp_18_P;
    
    logic [15:0] adder_dsp_19_FFC0;
    logic [15:0] adder_dsp_19_FFC1;
    logic [15:0] adder_dsp_19_FFC2;
    logic [15:0] adder_dsp_19_FFC3;
    logic [15:0] adder_dsp_19_C;
    logic [15:0] adder_dsp_19_P;
    
    logic [15:0] adder_dsp_20_A1;
    logic [15:0] adder_dsp_20_A2;
    logic [15:0] adder_dsp_20_FFD;
    logic [15:0] adder_dsp_20_D;
    logic [15:0] adder_dsp_20_AD;
    logic [15:0] adder_dsp_20_M;
    logic [15:0] adder_dsp_20_FFC0;
    logic [15:0] adder_dsp_20_FFC1;
    logic [15:0] adder_dsp_20_FFC2;
    logic [15:0] adder_dsp_20_C;
    logic [15:0] adder_dsp_20_P;
    
    logic [15:0] adder_dsp_21_FFC0;
    logic [15:0] adder_dsp_21_FFC1;
    logic [15:0] adder_dsp_21_FFC2;
    logic [15:0] adder_dsp_21_FFC3;
    logic [15:0] adder_dsp_21_C;
    logic [15:0] adder_dsp_21_P;
    
    logic [15:0] adder_dsp_22_A1;
    logic [15:0] adder_dsp_22_A2;
    logic [15:0] adder_dsp_22_FFD;
    logic [15:0] adder_dsp_22_D;
    logic [15:0] adder_dsp_22_AD;
    logic [15:0] adder_dsp_22_M;
    logic [15:0] adder_dsp_22_FFC0;
    logic [15:0] adder_dsp_22_FFC1;
    logic [15:0] adder_dsp_22_FFC2;
    logic [15:0] adder_dsp_22_C;
    logic [15:0] adder_dsp_22_P;
    
    logic [15:0] adder_dsp_23_FFC0;
    logic [15:0] adder_dsp_23_FFC1;
    logic [15:0] adder_dsp_23_FFC2;
    logic [15:0] adder_dsp_23_FFC3;
    logic [15:0] adder_dsp_23_C;
    logic [15:0] adder_dsp_23_P;
    
    
    logic [15:0] adder_dsp_24_A1;
    logic [15:0] adder_dsp_24_A2;
    logic [15:0] adder_dsp_24_FFD;
    logic [15:0] adder_dsp_24_D;
    logic [15:0] adder_dsp_24_AD;
    logic [15:0] adder_dsp_24_M;
    logic [15:0] adder_dsp_24_FFC0;
    logic [15:0] adder_dsp_24_FFC1;
    logic [15:0] adder_dsp_24_FFC2;
    logic [15:0] adder_dsp_24_C;
    logic [15:0] adder_dsp_24_P;
    
    logic [15:0] adder_dsp_25_A1;
    logic [15:0] adder_dsp_25_A2;
    logic [15:0] adder_dsp_25_FFD;
    logic [15:0] adder_dsp_25_D;
    logic [15:0] adder_dsp_25_AD;
    logic [15:0] adder_dsp_25_M;
    logic [15:0] adder_dsp_25_FFC0;
    logic [15:0] adder_dsp_25_FFC1;
    logic [15:0] adder_dsp_25_FFC2;
    logic [15:0] adder_dsp_25_C;
    logic [15:0] adder_dsp_25_P;
    
    logic [15:0] adder_dsp_26_P;
    
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            macc_en               <= 0;
            input_feature_col_cnt <= 0;
            input_feature_row_cnt <= 0;
        end else begin
            if (i_feature_valid) begin
                for (int i = 0; i < 6; i++)
                    s2_map[i][input_feature_row_cnt][input_feature_col_cnt] <= i_features[i];
                input_feature_col_cnt <= input_feature_col_cnt + 1;
                if (input_feature_col_cnt == 13) begin
                    input_feature_col_cnt <= 0;
                    input_feature_row_cnt <= input_feature_row_cnt + 1;
                    if (input_feature_row_cnt == 13) begin
                        macc_en <= 1;
                    end
                end
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            first_stage_macc_dsps_dualAD1reg <= '{default: 0};
             first_stage_macc_dsps_dualB1reg <= '{default: 0};
            first_stage_macc_dsps_dualAD2reg <= '{default: 0};
             first_stage_macc_dsps_dualB2reg <= '{default: 0};
                  first_stage_macc_dsps_Mreg <= '{default: 0};
                  first_stage_macc_dsps_Preg <= '{default: 0};
            // Is it a bad practice to shift in 0 during reset like this?
            mult_result_valid_sr <= {mult_result_valid_sr[7:0], 1'b0};
        end else begin
            mult_result_valid_sr <= {mult_result_valid_sr[7:0], 1'b0};
            if (macc_en) begin
                mult_kernel_col_cnt <= mult_kernel_col_cnt + 1;
                if (mult_kernel_col_cnt == 4) begin
                    mult_kernel_col_cnt <= 0;
                    mult_kernel_row_cnt <= mult_kernel_row_cnt + 1;
                    if (mult_kernel_row_cnt == 4) begin
                        mult_kernel_row_cnt <= 0;
                        mult_result_valid_sr <= {mult_result_valid_sr[7:0], 1'b1};
                        mult_kernel_col_cnt <= mult_kernel_col_cnt + 1;
                        if (mult_kernel_col_cnt == 9) begin
                            mult_kernel_col_cnt <= 0;
                            mult_feature_row_cnt <= mult_feature_row_cnt + 1;
                            if (mult_feature_row_cnt == 9) begin
                                // Multiplies in this layer is done.
                            end
                        end
                    end
                end
                
                for (int i = 0; i < 6; i++) begin
                    for (int j = 0; j < 10; j++) begin
                        first_stage_macc_dsps_dualAD1reg[i][j] <= s2_map[i][mult_feature_row_cnt]
                                                                           [mult_feature_col_cnt];
                        first_stage_macc_dsps_dualB1reg[i][j] <= weights[i][j][mult_kernel_row_cnt]
                                                                              [mult_kernel_col_cnt];
                        
                        first_stage_macc_dsps_dualAD2reg[i][j]
                            <= first_stage_macc_dsps_dualAD1reg[i][j];
                        first_stage_macc_dsps_dualB2reg[i][j]
                            <= first_stage_macc_dsps_dualB1reg[i][j];
                        
                        first_stage_macc_dsps_Mreg[i][j]
                            <= first_stage_macc_dsps_dualAD2reg[i][j]
                                * first_stage_macc_dsps_dualB2reg[i][j];
                        
                        first_stage_macc_dsps_Preg[i][j]
                            <= first_stage_macc_dsps_Preg[i][j]
                                + first_stage_macc_dsps_Mreg[i][j];
                    end
                end
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (mult_result_valid_sr[3]) begin
            adder_dsp_0_A1    <= first_stage_macc_dsps_Preg[0][0];
            adder_dsp_0_FFD   <= first_stage_macc_dsps_Preg[1][0];
            adder_dsp_0_FFC0  <= first_stage_macc_dsps_Preg[2][0];
            
            adder_dsp_1_A1    <= first_stage_macc_dsps_Preg[1][1];
            adder_dsp_1_FFD   <= first_stage_macc_dsps_Preg[2][1];
            adder_dsp_1_FFC0  <= first_stage_macc_dsps_Preg[3][0];
            
            adder_dsp_2_A1    <= first_stage_macc_dsps_Preg[2][2];
            adder_dsp_2_FFD   <= first_stage_macc_dsps_Preg[3][1];
            adder_dsp_2_FFC0  <= first_stage_macc_dsps_Preg[4][0];
            
            adder_dsp_3_A1    <= first_stage_macc_dsps_Preg[3][2];
            adder_dsp_3_FFD   <= first_stage_macc_dsps_Preg[4][1];
            adder_dsp_3_FFC0  <= first_stage_macc_dsps_Preg[5][0];
            
            adder_dsp_4_A1    <= first_stage_macc_dsps_Preg[0][1];
            adder_dsp_4_FFD   <= first_stage_macc_dsps_Preg[4][2];
            adder_dsp_4_FFC0  <= first_stage_macc_dsps_Preg[5][1];
            
            adder_dsp_5_A1    <= first_stage_macc_dsps_Preg[0][2];
            adder_dsp_5_FFD   <= first_stage_macc_dsps_Preg[1][2];
            adder_dsp_5_FFC0  <= first_stage_macc_dsps_Preg[5][2];
            
            adder_dsp_6_A1    <= first_stage_macc_dsps_Preg[0][3];
            adder_dsp_6_FFD   <= first_stage_macc_dsps_Preg[1][3];
            adder_dsp_6_FFC0  <= first_stage_macc_dsps_Preg[2][3];
           
            adder_dsp_7_FFC0  <= first_stage_macc_dsps_Preg[3][3];
           
            adder_dsp_8_A1    <= first_stage_macc_dsps_Preg[1][4];
            adder_dsp_8_FFD   <= first_stage_macc_dsps_Preg[2][4];
            adder_dsp_8_FFC0  <= first_stage_macc_dsps_Preg[3][4];
           
            adder_dsp_9_FFC0  <= first_stage_macc_dsps_Preg[4][3];
            
            adder_dsp_10_A1   <= first_stage_macc_dsps_Preg[2][5];
            adder_dsp_10_FFD  <= first_stage_macc_dsps_Preg[3][5];
            adder_dsp_10_FFC0 <= first_stage_macc_dsps_Preg[4][4];
           
            adder_dsp_11_FFC0 <= first_stage_macc_dsps_Preg[5][3];
                
            adder_dsp_12_A1   <= first_stage_macc_dsps_Preg[0][4];
            adder_dsp_12_FFD  <= first_stage_macc_dsps_Preg[3][6];
            adder_dsp_12_FFC0 <= first_stage_macc_dsps_Preg[4][5];
            
            adder_dsp_13_FFC0 <= first_stage_macc_dsps_Preg[5][4];
            
            adder_dsp_14_A1   <= first_stage_macc_dsps_Preg[0][5];
            adder_dsp_14_FFD  <= first_stage_macc_dsps_Preg[1][5];
            adder_dsp_14_FFC0 <= first_stage_macc_dsps_Preg[4][6];
            
            adder_dsp_15_FFC0 <= first_stage_macc_dsps_Preg[5][5];
            
            adder_dsp_16_A1   <= first_stage_macc_dsps_Preg[0][6];
            adder_dsp_16_FFD  <= first_stage_macc_dsps_Preg[1][6];
            adder_dsp_16_FFC0 <= first_stage_macc_dsps_Preg[2][6];
            
            adder_dsp_17_FFC0 <= first_stage_macc_dsps_Preg[5][6];
            
            adder_dsp_18_A1   <= first_stage_macc_dsps_Preg[0][7];
            adder_dsp_18_FFD  <= first_stage_macc_dsps_Preg[1][7];
            adder_dsp_18_FFC0 <= first_stage_macc_dsps_Preg[3][7];
            
            adder_dsp_19_FFC0 <= first_stage_macc_dsps_Preg[4][7];
            
            adder_dsp_20_A1   <= first_stage_macc_dsps_Preg[1][8];
            adder_dsp_20_FFD  <= first_stage_macc_dsps_Preg[2][7];
            adder_dsp_20_FFC0 <= first_stage_macc_dsps_Preg[4][8];
            
            adder_dsp_21_FFC0 <= first_stage_macc_dsps_Preg[5][7];
            
            adder_dsp_22_A1   <= first_stage_macc_dsps_Preg[0][8];
            adder_dsp_22_FFD  <= first_stage_macc_dsps_Preg[2][8];
            adder_dsp_22_FFC0 <= first_stage_macc_dsps_Preg[3][8];
            
            adder_dsp_23_FFC0 <= first_stage_macc_dsps_Preg[5][8];
            
            adder_dsp_24_A1   <= first_stage_macc_dsps_Preg[0][9];
            adder_dsp_24_FFD  <= first_stage_macc_dsps_Preg[1][9];
            adder_dsp_24_FFC0 <= first_stage_macc_dsps_Preg[2][9];
            
            adder_dsp_25_A1   <= first_stage_macc_dsps_Preg[3][9];
            adder_dsp_25_FFD  <= first_stage_macc_dsps_Preg[4][9];
            adder_dsp_25_FFC0 <= first_stage_macc_dsps_Preg[5][9];
        
        end else if (mult_result_valid_sr[8]) begin
            adder_dsp_0_A1    <= 0;     
            adder_dsp_0_A2    <= 0;     
            adder_dsp_0_FFD   <= 0;     
            adder_dsp_0_D     <= 0;     
            adder_dsp_0_AD    <= 0;     
            adder_dsp_0_M     <= 0;     
            adder_dsp_0_FFC0  <= 0;     
            adder_dsp_0_FFC1  <= 0;     
            adder_dsp_0_FFC2  <= 0;     
            adder_dsp_0_C     <= 0;     
            adder_dsp_0_P     <= 0;
            
            adder_dsp_1_A1    <= 0;     
            adder_dsp_1_A2    <= 0;     
            adder_dsp_1_FFD   <= 0;     
            adder_dsp_1_D     <= 0;     
            adder_dsp_1_AD    <= 0;     
            adder_dsp_1_M     <= 0;     
            adder_dsp_1_FFC0  <= 0;     
            adder_dsp_1_FFC1  <= 0;     
            adder_dsp_1_FFC2  <= 0;     
            adder_dsp_1_C     <= 0;     
            adder_dsp_1_P     <= 0;
            
            adder_dsp_2_A1    <= 0;     
            adder_dsp_2_A2    <= 0;     
            adder_dsp_2_FFD   <= 0;     
            adder_dsp_2_D     <= 0;     
            adder_dsp_2_AD    <= 0;     
            adder_dsp_2_M     <= 0;     
            adder_dsp_2_FFC0  <= 0;     
            adder_dsp_2_FFC1  <= 0;     
            adder_dsp_2_FFC2  <= 0;     
            adder_dsp_2_C     <= 0;     
            adder_dsp_2_P     <= 0;
            
            adder_dsp_3_A1    <= 0;     
            adder_dsp_3_A2    <= 0;     
            adder_dsp_3_FFD   <= 0;     
            adder_dsp_3_D     <= 0;     
            adder_dsp_3_AD    <= 0;     
            adder_dsp_3_M     <= 0;     
            adder_dsp_3_FFC0  <= 0;     
            adder_dsp_3_FFC1  <= 0;     
            adder_dsp_3_FFC2  <= 0;     
            adder_dsp_3_C     <= 0;     
            adder_dsp_3_P     <= 0;
            
            adder_dsp_4_A1    <= 0;     
            adder_dsp_4_A2    <= 0;     
            adder_dsp_4_FFD   <= 0;     
            adder_dsp_4_D     <= 0;     
            adder_dsp_4_AD    <= 0;     
            adder_dsp_4_M     <= 0;     
            adder_dsp_4_FFC0  <= 0;     
            adder_dsp_4_FFC1  <= 0;     
            adder_dsp_4_FFC2  <= 0;     
            adder_dsp_4_C     <= 0;     
            adder_dsp_4_P     <= 0;
            
            adder_dsp_5_A1    <= 0;     
            adder_dsp_5_A2    <= 0;     
            adder_dsp_5_FFD   <= 0;     
            adder_dsp_5_D     <= 0;     
            adder_dsp_5_AD    <= 0;     
            adder_dsp_5_M     <= 0;     
            adder_dsp_5_FFC0  <= 0;     
            adder_dsp_5_FFC1  <= 0;     
            adder_dsp_5_FFC2  <= 0;     
            adder_dsp_5_C     <= 0;     
            adder_dsp_5_P     <= 0;
            
            adder_dsp_6_A1    <= 0;     
            adder_dsp_6_A2    <= 0;     
            adder_dsp_6_FFD   <= 0;     
            adder_dsp_6_D     <= 0;     
            adder_dsp_6_AD    <= 0;     
            adder_dsp_6_M     <= 0;     
            adder_dsp_6_FFC0  <= 0;     
            adder_dsp_6_FFC1  <= 0;     
            adder_dsp_6_FFC2  <= 0;     
            adder_dsp_6_C     <= 0;     
            adder_dsp_6_P     <= 0;
            
            adder_dsp_7_FFC0  <= 0;     
            adder_dsp_7_FFC1  <= 0;     
            adder_dsp_7_FFC2  <= 0;     
            adder_dsp_7_FFC3  <= 0;     
            adder_dsp_7_C     <= 0;     
            adder_dsp_7_P     <= 0;
            
            adder_dsp_8_A1    <= 0;     
            adder_dsp_8_A2    <= 0;     
            adder_dsp_8_FFD   <= 0;     
            adder_dsp_8_D     <= 0;     
            adder_dsp_8_AD    <= 0;     
            adder_dsp_8_M     <= 0;     
            adder_dsp_8_FFC0  <= 0;     
            adder_dsp_8_FFC1  <= 0;     
            adder_dsp_8_FFC2  <= 0;     
            adder_dsp_8_C     <= 0;     
            adder_dsp_8_P     <= 0;
            
            adder_dsp_9_FFC0  <= 0;     
            adder_dsp_9_FFC1  <= 0;     
            adder_dsp_9_FFC2  <= 0;     
            adder_dsp_9_FFC3  <= 0;     
            adder_dsp_9_C     <= 0;     
            adder_dsp_9_P     <= 0;
            
            adder_dsp_10_A1   <= 0;     
            adder_dsp_10_A2   <= 0;     
            adder_dsp_10_FFD  <= 0;     
            adder_dsp_10_D    <= 0;     
            adder_dsp_10_AD   <= 0;     
            adder_dsp_10_M    <= 0;     
            adder_dsp_10_FFC0 <= 0;     
            adder_dsp_10_FFC1 <= 0;     
            adder_dsp_10_FFC2 <= 0;     
            adder_dsp_10_C    <= 0;     
            adder_dsp_10_P    <= 0;
            
            adder_dsp_11_FFC0 <= 0;     
            adder_dsp_11_FFC1 <= 0;     
            adder_dsp_11_FFC2 <= 0;     
            adder_dsp_11_FFC3 <= 0;     
            adder_dsp_11_C    <= 0;     
            adder_dsp_11_P    <= 0;
            
            adder_dsp_12_A1   <= 0;     
            adder_dsp_12_A2   <= 0;     
            adder_dsp_12_FFD  <= 0;     
            adder_dsp_12_D    <= 0;     
            adder_dsp_12_AD   <= 0;     
            adder_dsp_12_M    <= 0;     
            adder_dsp_12_FFC0 <= 0;     
            adder_dsp_12_FFC1 <= 0;     
            adder_dsp_12_FFC2 <= 0;     
            adder_dsp_12_C    <= 0;     
            adder_dsp_12_P    <= 0;
            
            adder_dsp_13_FFC0 <= 0;     
            adder_dsp_13_FFC1 <= 0;     
            adder_dsp_13_FFC2 <= 0;     
            adder_dsp_13_FFC3 <= 0;     
            adder_dsp_13_C    <= 0;     
            adder_dsp_13_P    <= 0;
            
            adder_dsp_14_A1   <= 0;     
            adder_dsp_14_A2   <= 0;     
            adder_dsp_14_FFD  <= 0;     
            adder_dsp_14_D    <= 0;     
            adder_dsp_14_AD   <= 0;     
            adder_dsp_14_M    <= 0;     
            adder_dsp_14_FFC0 <= 0;     
            adder_dsp_14_FFC1 <= 0;     
            adder_dsp_14_FFC2 <= 0;     
            adder_dsp_14_C    <= 0;     
            adder_dsp_14_P    <= 0;
            
            adder_dsp_15_FFC0 <= 0;     
            adder_dsp_15_FFC1 <= 0;     
            adder_dsp_15_FFC2 <= 0;     
            adder_dsp_15_FFC3 <= 0;     
            adder_dsp_15_C    <= 0;     
            adder_dsp_15_P    <= 0;
            
            adder_dsp_16_A1   <= 0;     
            adder_dsp_16_A2   <= 0;     
            adder_dsp_16_FFD  <= 0;     
            adder_dsp_16_D    <= 0;     
            adder_dsp_16_AD   <= 0;     
            adder_dsp_16_M    <= 0;     
            adder_dsp_16_FFC0 <= 0;     
            adder_dsp_16_FFC1 <= 0;     
            adder_dsp_16_FFC2 <= 0;     
            adder_dsp_16_C    <= 0;     
            adder_dsp_16_P    <= 0;
            
            adder_dsp_17_FFC0 <= 0;     
            adder_dsp_17_FFC1 <= 0;     
            adder_dsp_17_FFC2 <= 0;     
            adder_dsp_17_FFC3 <= 0;     
            adder_dsp_17_C    <= 0;     
            adder_dsp_17_P    <= 0;
            
            adder_dsp_18_A1   <= 0;     
            adder_dsp_18_A2   <= 0;     
            adder_dsp_18_FFD  <= 0;     
            adder_dsp_18_D    <= 0;     
            adder_dsp_18_AD   <= 0;     
            adder_dsp_18_M    <= 0;     
            adder_dsp_18_FFC0 <= 0;     
            adder_dsp_18_FFC1 <= 0;     
            adder_dsp_18_FFC2 <= 0;     
            adder_dsp_18_C    <= 0;     
            adder_dsp_18_P    <= 0;
            
            adder_dsp_19_FFC0 <= 0;     
            adder_dsp_19_FFC1 <= 0;     
            adder_dsp_19_FFC2 <= 0;     
            adder_dsp_19_FFC3 <= 0;     
            adder_dsp_19_C    <= 0;     
            adder_dsp_19_P    <= 0;
            
            adder_dsp_20_A1   <= 0;     
            adder_dsp_20_A2   <= 0;     
            adder_dsp_20_FFD  <= 0;     
            adder_dsp_20_D    <= 0;     
            adder_dsp_20_AD   <= 0;     
            adder_dsp_20_M    <= 0;     
            adder_dsp_20_FFC0 <= 0;     
            adder_dsp_20_FFC1 <= 0;     
            adder_dsp_20_FFC2 <= 0;     
            adder_dsp_20_C    <= 0;     
            adder_dsp_20_P    <= 0;
            
            adder_dsp_21_FFC0 <= 0;     
            adder_dsp_21_FFC1 <= 0;     
            adder_dsp_21_FFC2 <= 0;     
            adder_dsp_21_FFC3 <= 0;     
            adder_dsp_21_C    <= 0;     
            adder_dsp_21_P    <= 0;
            
            adder_dsp_22_A1   <= 0;     
            adder_dsp_22_A2   <= 0;     
            adder_dsp_22_FFD  <= 0;     
            adder_dsp_22_D    <= 0;     
            adder_dsp_22_AD   <= 0;     
            adder_dsp_22_M    <= 0;     
            adder_dsp_22_FFC0 <= 0;     
            adder_dsp_22_FFC1 <= 0;     
            adder_dsp_22_FFC2 <= 0;     
            adder_dsp_22_C    <= 0;     
            adder_dsp_22_P    <= 0;
            
            adder_dsp_23_FFC0 <= 0;     
            adder_dsp_23_FFC1 <= 0;     
            adder_dsp_23_FFC2 <= 0;     
            adder_dsp_23_FFC3 <= 0;     
            adder_dsp_23_C    <= 0;     
            adder_dsp_23_P    <= 0;
            
            adder_dsp_24_A1   <= 0;     
            adder_dsp_24_A2   <= 0;     
            adder_dsp_24_FFD  <= 0;     
            adder_dsp_24_D    <= 0;     
            adder_dsp_24_AD   <= 0;     
            adder_dsp_24_M    <= 0;     
            adder_dsp_24_FFC0 <= 0;     
            adder_dsp_24_FFC1 <= 0;     
            adder_dsp_24_FFC2 <= 0;     
            adder_dsp_24_C    <= 0;     
            adder_dsp_24_P    <= 0;
            
            adder_dsp_25_A1   <= 0;     
            adder_dsp_25_A2   <= 0;     
            adder_dsp_25_FFD  <= 0;     
            adder_dsp_25_D    <= 0;     
            adder_dsp_25_AD   <= 0;     
            adder_dsp_25_M    <= 0;     
            adder_dsp_25_FFC0 <= 0;     
            adder_dsp_25_FFC1 <= 0;     
            adder_dsp_25_FFC2 <= 0;     
            adder_dsp_25_C    <= 0;     
            adder_dsp_25_P    <= 0;
            
            adder_dsp_26_P    <= 0;     
        
            o_feature_valid   <= 1;
        end else begin
            adder_dsp_0_A1    <= 0;
            adder_dsp_0_FFD   <= 0;
            adder_dsp_0_FFC0  <= 0;
            
            adder_dsp_1_A1    <= 0;
            adder_dsp_1_FFD   <= 0;
            adder_dsp_1_FFC0  <= 0;
            
            adder_dsp_2_A1    <= 0;
            adder_dsp_2_FFD   <= 0;
            adder_dsp_2_FFC0  <= 0;
            
            adder_dsp_3_A1    <= 0;
            adder_dsp_3_FFD   <= 0;
            adder_dsp_3_FFC0  <= 0;
            
            adder_dsp_4_A1    <= 0;
            adder_dsp_4_FFD   <= 0;
            adder_dsp_4_FFC0  <= 0;
            
            adder_dsp_5_A1    <= 0;
            adder_dsp_5_FFD   <= 0;
            adder_dsp_5_FFC0  <= 0;
            
            adder_dsp_6_A1    <= 0;
            adder_dsp_6_FFD   <= 0;
            adder_dsp_6_FFC0  <= 0;
            
            adder_dsp_7_FFC0  <= 0;
            
            adder_dsp_8_A1    <= 0;
            adder_dsp_8_FFD   <= 0;
            adder_dsp_8_FFC0  <= 0;
            
            adder_dsp_9_FFC0  <= 0;
            
            adder_dsp_10_A1   <= 0;
            adder_dsp_10_FFD  <= 0;
            adder_dsp_10_FFC0 <= 0;
            
            adder_dsp_11_FFC0 <= 0;
            
            adder_dsp_12_A1   <= 0;
            adder_dsp_12_FFD  <= 0;
            adder_dsp_12_FFC0 <= 0;
            
            adder_dsp_13_FFC0 <= 0;
            
            adder_dsp_14_A1   <= 0;
            adder_dsp_14_FFD  <= 0;
            adder_dsp_14_FFC0 <= 0;
            
            adder_dsp_15_FFC0 <= 0;
            
            adder_dsp_16_A1   <= 0;
            adder_dsp_16_FFD  <= 0;
            adder_dsp_16_FFC0 <= 0;
            
            adder_dsp_17_FFC0 <= 0;
            
            adder_dsp_18_A1   <= 0;
            adder_dsp_18_FFD  <= 0;
            adder_dsp_18_FFC0 <= 0;
            
            adder_dsp_19_FFC0 <= 0;
            
            adder_dsp_20_A1   <= 0;
            adder_dsp_20_FFD  <= 0;
            adder_dsp_20_FFC0 <= 0;
            
            adder_dsp_21_FFC0 <= 0;
            
            adder_dsp_22_A1   <= 0;
            adder_dsp_22_FFD  <= 0;
            adder_dsp_22_FFC0 <= 0;
            
            adder_dsp_23_FFC0 <= 0;
            
            adder_dsp_24_A1   <= 0;
            adder_dsp_24_FFD  <= 0;
            adder_dsp_24_FFC0 <= 0;
            
            adder_dsp_25_A1   <= 0;
            adder_dsp_25_FFD  <= 0;
            adder_dsp_25_FFC0 <= 0;
        end
    
        adder_dsp_0_A2 <= adder_dsp_0_A1;
        adder_dsp_0_D <= adder_dsp_0_FFD;
        adder_dsp_0_AD <= adder_dsp_0_A2 + adder_dsp_0_D;
        adder_dsp_0_M <= adder_dsp_0_AD;
        adder_dsp_0_FFC1 <= adder_dsp_0_FFC0;
        adder_dsp_0_FFC2 <= adder_dsp_0_FFC1;
        adder_dsp_0_C <= adder_dsp_0_FFC2;
        adder_dsp_0_P <= adder_dsp_0_M + adder_dsp_0_C;
        
        adder_dsp_1_A2 <= adder_dsp_1_A1;
        adder_dsp_1_D <= adder_dsp_1_FFD;
        adder_dsp_1_AD <= adder_dsp_1_A2 + adder_dsp_1_D;
        adder_dsp_1_M <= adder_dsp_1_AD;
        adder_dsp_1_FFC1 <= adder_dsp_1_FFC0;
        adder_dsp_1_FFC2 <= adder_dsp_1_FFC1;
        adder_dsp_1_C <= adder_dsp_1_FFC2;
        adder_dsp_1_P <= adder_dsp_1_M + adder_dsp_1_C;
        
        adder_dsp_2_A2 <= adder_dsp_2_A1;
        adder_dsp_2_D <= adder_dsp_2_FFD;
        adder_dsp_2_AD <= adder_dsp_2_A2 + adder_dsp_2_D;
        adder_dsp_2_M <= adder_dsp_2_AD;
        adder_dsp_2_FFC1 <= adder_dsp_2_FFC0;
        adder_dsp_2_FFC2 <= adder_dsp_2_FFC1;
        adder_dsp_2_C <= adder_dsp_2_FFC2;
        adder_dsp_2_P <= adder_dsp_2_M + adder_dsp_2_C;
        
        adder_dsp_3_A2 <= adder_dsp_3_A1;
        adder_dsp_3_D <= adder_dsp_3_FFD;
        adder_dsp_3_AD <= adder_dsp_3_A2 + adder_dsp_3_D;
        adder_dsp_3_M <= adder_dsp_3_AD;
        adder_dsp_3_FFC1 <= adder_dsp_3_FFC0;
        adder_dsp_3_FFC2 <= adder_dsp_3_FFC1;
        adder_dsp_3_C <= adder_dsp_3_FFC2;
        adder_dsp_3_P <= adder_dsp_3_M + adder_dsp_3_C;
        
        adder_dsp_4_A2 <= adder_dsp_4_A1;
        adder_dsp_4_D <= adder_dsp_4_FFD;
        adder_dsp_4_AD <= adder_dsp_4_A2 + adder_dsp_4_D;
        adder_dsp_4_M <= adder_dsp_4_AD;
        adder_dsp_4_FFC1 <= adder_dsp_4_FFC0;
        adder_dsp_4_FFC2 <= adder_dsp_4_FFC1;
        adder_dsp_4_C <= adder_dsp_4_FFC2;
        adder_dsp_4_P <= adder_dsp_4_M + adder_dsp_4_C;
        
        adder_dsp_5_A2 <= adder_dsp_5_A1;
        adder_dsp_5_D <= adder_dsp_5_FFD;
        adder_dsp_5_AD <= adder_dsp_5_A2 + adder_dsp_5_D;
        adder_dsp_5_M <= adder_dsp_5_AD;
        adder_dsp_5_FFC1 <= adder_dsp_5_FFC0;
        adder_dsp_5_FFC2 <= adder_dsp_5_FFC1;
        adder_dsp_5_C <= adder_dsp_5_FFC2;
        adder_dsp_5_P <= adder_dsp_5_M + adder_dsp_5_C;
        
        adder_dsp_6_A2 <= adder_dsp_6_A1;
        adder_dsp_6_D <= adder_dsp_6_FFD;
        adder_dsp_6_AD <= adder_dsp_6_A2 + adder_dsp_6_D;
        adder_dsp_6_M <= adder_dsp_6_AD;
        adder_dsp_6_FFC1 <= adder_dsp_6_FFC0;
        adder_dsp_6_FFC2 <= adder_dsp_6_FFC1;
        adder_dsp_6_C <= adder_dsp_6_FFC2;
        adder_dsp_6_P <= adder_dsp_6_M + adder_dsp_6_C;
        
        adder_dsp_7_FFC1 <= adder_dsp_7_FFC0;
        adder_dsp_7_FFC2 <= adder_dsp_7_FFC1;
        adder_dsp_7_FFC3 <= adder_dsp_7_FFC2;
        adder_dsp_7_C <= adder_dsp_7_FFC3;
        adder_dsp_7_P <= adder_dsp_6_P + adder_dsp_7_C;
        
        adder_dsp_8_A2 <= adder_dsp_8_A1;
        adder_dsp_8_D <= adder_dsp_8_FFD;
        adder_dsp_8_AD <= adder_dsp_8_A2 + adder_dsp_8_D;
        adder_dsp_8_M <= adder_dsp_8_AD;
        adder_dsp_8_FFC1 <= adder_dsp_8_FFC0;
        adder_dsp_8_FFC2 <= adder_dsp_8_FFC1;
        adder_dsp_8_C <= adder_dsp_8_FFC2;
        adder_dsp_8_P <= adder_dsp_8_M + adder_dsp_8_C;
        
        adder_dsp_9_FFC1 <= adder_dsp_9_FFC0;
        adder_dsp_9_FFC2 <= adder_dsp_9_FFC1;
        adder_dsp_9_FFC3 <= adder_dsp_9_FFC2;
        adder_dsp_9_C <= adder_dsp_9_FFC3;
        adder_dsp_9_P <= adder_dsp_8_P + adder_dsp_9_C;
        
        adder_dsp_10_A2 <= adder_dsp_10_A1;
        adder_dsp_10_D <= adder_dsp_10_FFD;
        adder_dsp_10_AD <= adder_dsp_10_A2 + adder_dsp_10_D;
        adder_dsp_10_M <= adder_dsp_10_AD;
        adder_dsp_10_FFC1 <= adder_dsp_10_FFC0;
        adder_dsp_10_FFC2 <= adder_dsp_10_FFC1;
        adder_dsp_10_C <= adder_dsp_10_FFC2;
        adder_dsp_10_P <= adder_dsp_10_M + adder_dsp_10_C;
        
        adder_dsp_11_FFC1 <= adder_dsp_11_FFC0;
        adder_dsp_11_FFC2 <= adder_dsp_11_FFC1;
        adder_dsp_11_FFC3 <= adder_dsp_11_FFC2;
        adder_dsp_11_C <= adder_dsp_11_FFC3;
        adder_dsp_11_P <= adder_dsp_10_P + adder_dsp_11_C;
        
        adder_dsp_12_A2 <= adder_dsp_12_A1;
        adder_dsp_12_D <= adder_dsp_12_FFD;
        adder_dsp_12_AD <= adder_dsp_12_A2 + adder_dsp_12_D;
        adder_dsp_12_M <= adder_dsp_12_AD;
        adder_dsp_12_FFC1 <= adder_dsp_12_FFC0;
        adder_dsp_12_FFC2 <= adder_dsp_12_FFC1;
        adder_dsp_12_C <= adder_dsp_12_FFC2;
        adder_dsp_12_P <= adder_dsp_12_M + adder_dsp_12_C;
        
        adder_dsp_13_FFC1 <= adder_dsp_13_FFC0;
        adder_dsp_13_FFC2 <= adder_dsp_13_FFC1;
        adder_dsp_13_FFC3 <= adder_dsp_13_FFC2;
        adder_dsp_13_C <= adder_dsp_13_FFC3;
        adder_dsp_13_P <= adder_dsp_12_P + adder_dsp_13_C;
        
        adder_dsp_14_A2 <= adder_dsp_14_A1;
        adder_dsp_14_D <= adder_dsp_14_FFD;
        adder_dsp_14_AD <= adder_dsp_14_A2 + adder_dsp_14_D;
        adder_dsp_14_M <= adder_dsp_14_AD;
        adder_dsp_14_FFC1 <= adder_dsp_14_FFC0;
        adder_dsp_14_FFC2 <= adder_dsp_14_FFC1;
        adder_dsp_14_C <= adder_dsp_14_FFC2;
        adder_dsp_14_P <= adder_dsp_14_M + adder_dsp_14_C;
        
        adder_dsp_15_FFC1 <= adder_dsp_15_FFC0;
        adder_dsp_15_FFC2 <= adder_dsp_15_FFC1;
        adder_dsp_15_FFC3 <= adder_dsp_15_FFC2;
        adder_dsp_15_C <= adder_dsp_15_FFC3;
        adder_dsp_15_P <= adder_dsp_14_P + adder_dsp_15_C;
        
        adder_dsp_16_A2 <= adder_dsp_16_A1;
        adder_dsp_16_D <= adder_dsp_16_FFD;
        adder_dsp_16_AD <= adder_dsp_16_A2 + adder_dsp_16_D;
        adder_dsp_16_M <= adder_dsp_16_AD;
        adder_dsp_16_FFC1 <= adder_dsp_16_FFC0;
        adder_dsp_16_FFC2 <= adder_dsp_16_FFC1;
        adder_dsp_16_C <= adder_dsp_16_FFC2;
        adder_dsp_16_P <= adder_dsp_16_M + adder_dsp_16_C;
        
        adder_dsp_17_FFC1 <= adder_dsp_17_FFC0;
        adder_dsp_17_FFC2 <= adder_dsp_17_FFC1;
        adder_dsp_17_FFC3 <= adder_dsp_17_FFC2;
        adder_dsp_17_C <= adder_dsp_17_FFC3;
        adder_dsp_17_P <= adder_dsp_16_P + adder_dsp_17_C;
        
        adder_dsp_18_A2 <= adder_dsp_18_A1;
        adder_dsp_18_D <= adder_dsp_18_FFD;
        adder_dsp_18_AD <= adder_dsp_18_A2 + adder_dsp_18_D;
        adder_dsp_18_M <= adder_dsp_18_AD;
        adder_dsp_18_FFC1 <= adder_dsp_18_FFC0;
        adder_dsp_18_FFC2 <= adder_dsp_18_FFC1;
        adder_dsp_18_C <= adder_dsp_18_FFC2;
        adder_dsp_18_P <= adder_dsp_18_M + adder_dsp_18_C;
        
        adder_dsp_19_FFC1 <= adder_dsp_19_FFC0;
        adder_dsp_19_FFC2 <= adder_dsp_19_FFC1;
        adder_dsp_19_FFC3 <= adder_dsp_19_FFC2;
        adder_dsp_19_C <= adder_dsp_19_FFC3;
        adder_dsp_19_P <= adder_dsp_18_P + adder_dsp_19_C;
        
        adder_dsp_20_A2 <= adder_dsp_20_A1;
        adder_dsp_20_D <= adder_dsp_20_FFD;
        adder_dsp_20_AD <= adder_dsp_20_A2 + adder_dsp_20_D;
        adder_dsp_20_M <= adder_dsp_20_AD;
        adder_dsp_20_FFC1 <= adder_dsp_20_FFC0;
        adder_dsp_20_FFC2 <= adder_dsp_20_FFC1;
        adder_dsp_20_C <= adder_dsp_20_FFC2;
        adder_dsp_20_P <= adder_dsp_20_M + adder_dsp_20_C;
        
        adder_dsp_21_FFC1 <= adder_dsp_21_FFC0;
        adder_dsp_21_FFC2 <= adder_dsp_21_FFC1;
        adder_dsp_21_FFC3 <= adder_dsp_21_FFC2;
        adder_dsp_21_C <= adder_dsp_21_FFC3;
        adder_dsp_21_P <= adder_dsp_20_P + adder_dsp_21_C;
        
        adder_dsp_22_A2 <= adder_dsp_22_A1;
        adder_dsp_22_D <= adder_dsp_22_FFD;
        adder_dsp_22_AD <= adder_dsp_22_A2 + adder_dsp_22_D;
        adder_dsp_22_M <= adder_dsp_22_AD;
        adder_dsp_22_FFC1 <= adder_dsp_22_FFC0;
        adder_dsp_22_FFC2 <= adder_dsp_22_FFC1;
        adder_dsp_22_C <= adder_dsp_22_FFC2;
        adder_dsp_22_P <= adder_dsp_22_M + adder_dsp_22_C;
        
        adder_dsp_23_FFC1 <= adder_dsp_23_FFC0;
        adder_dsp_23_FFC2 <= adder_dsp_23_FFC1;
        adder_dsp_23_FFC3 <= adder_dsp_23_FFC2;
        adder_dsp_23_C <= adder_dsp_23_FFC3;
        adder_dsp_23_P <= adder_dsp_22_P + adder_dsp_23_C;
        
        adder_dsp_24_A2 <= adder_dsp_24_A1;
        adder_dsp_24_D <= adder_dsp_24_FFD;
        adder_dsp_24_AD <= adder_dsp_24_A2 + adder_dsp_24_D;
        adder_dsp_24_M <= adder_dsp_24_AD;
        adder_dsp_24_FFC1 <= adder_dsp_24_FFC0;
        adder_dsp_24_FFC2 <= adder_dsp_24_FFC1;
        adder_dsp_24_C <= adder_dsp_24_FFC2;
        adder_dsp_24_P <= adder_dsp_24_M + adder_dsp_24_C;
        
        adder_dsp_25_A2 <= adder_dsp_25_A1;
        adder_dsp_25_D <= adder_dsp_25_FFD;
        adder_dsp_25_AD <= adder_dsp_25_A2 + adder_dsp_25_D;
        adder_dsp_25_M <= adder_dsp_25_AD;
        adder_dsp_25_FFC1 <= adder_dsp_25_FFC0;
        adder_dsp_25_FFC2 <= adder_dsp_25_FFC1;
        adder_dsp_25_C <= adder_dsp_25_FFC2;
        adder_dsp_25_P <= adder_dsp_25_M + adder_dsp_25_C;
        
        adder_dsp_26_P <= adder_dsp_24_P + adder_dsp_25_P;
    end
    
    always_ff @(posedge i_clk) begin
        o_features[0]  <= adder_dsp_0_P;
        o_features[1]  <= adder_dsp_1_P;
        o_features[2]  <= adder_dsp_2_P;
        o_features[3]  <= adder_dsp_3_P;
        o_features[4]  <= adder_dsp_4_P;
        o_features[5]  <= adder_dsp_5_P;
        o_features[6]  <= adder_dsp_7_P;
        o_features[7]  <= adder_dsp_9_P;
        o_features[8]  <= adder_dsp_11_P;
        o_features[9]  <= adder_dsp_13_P;
        o_features[10] <= adder_dsp_15_P;
        o_features[11] <= adder_dsp_17_P;
        o_features[12] <= adder_dsp_19_P;
        o_features[13] <= adder_dsp_21_P;
        o_features[14] <= adder_dsp_23_P;
        o_features[15] <= adder_dsp_26_P;
    end
    
endmodule