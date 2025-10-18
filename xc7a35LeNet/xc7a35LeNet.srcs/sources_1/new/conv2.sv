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
    
    Trainable parameters = (6*3 + 9*4 + 6) * (5*5) + 6 + 9 + 1 = 60*(5*5) + 15 = 1516
    Num multiplies       = (6*3 + 9*4 + 6) * (10*10*5*5) = 10*10*(1516-16) = 150000
    Clock cycles when 100% DSP48E1 utilization w/ no overclocking = 150000/90 = 1666.67 = 1667
    
    input  logic              i_feature_valid
    input  logic signed [7:0] i_features[0:5]
    
    Theory of operation:
    1) Gather features into 6 14x14 8-bit input feature maps (syntehesized as 6x25 8x8-bit Distributed RAMs)
    2) When the feature buffer is full MACC operations should begin
    3) MACC operation consists of 25 cycles per output feature accumulation, 2D convolution counter
        iterates from 0 to 9, left to right, top to bottom. 2D kernel counter counts from 0 to 4,
            left to right, top to bottom. Address to weights is kernel counter, address to features
                is convolution counter + kernel counter
    4) During multiplications, connect P reg of * DSPs to first stage pipeline registers of + DSPs
    5) Output is 16 10x10 feature maps
    
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
    
    logic                               first_stage_p_reg_valid;
    
    // 6x10 x 10x10x8-bit feature map = 60x800=48000 bits -> 1.5 36Kb BRAMs
    logic        [$clog2(10)-1:0] first_stage_feature_map_col_cnt;
    logic        [$clog2(10)-1:0] first_stage_feature_map_row_cnt;
    logic signed            [7:0] first_stage_feature_map[0:15][0:9][0:9];
    logic signed                  first_stage_feature_map_full;
    
    logic        [$clog2(10)-1:0] output_feature_map_col_cnt;
    logic        [$clog2(10)-1:0] output_feature_map_row_cnt;
    
    // Fill 6x14x14 input feature map
    // enabled MACC when full
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
            first_stage_p_reg_valid <= 0;
            mult_result_valid_sr <= {mult_result_valid_sr[7:0], 1'b0};
            if (macc_en) begin
                mult_kernel_col_cnt <= mult_kernel_col_cnt + 1;
                if (mult_kernel_col_cnt == 4) begin
                    mult_kernel_col_cnt <= 0;
                    mult_kernel_row_cnt <= mult_kernel_row_cnt + 1;
                    if (mult_kernel_row_cnt == 4) begin
                        mult_kernel_row_cnt <= 0;
                        mult_result_valid_sr <= {mult_result_valid_sr[7:0], 1'b1};
                        first_stage_p_reg_valid <= 1;
                        mult_feature_col_cnt <= mult_feature_col_cnt + 1;
                        if (mult_feature_col_cnt == 9) begin
                            mult_feature_col_cnt <= 0;
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
        if (first_stage_p_reg_valid) begin
            first_stage_feature_map[0]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][0] +
                       first_stage_macc_dsps_Preg[1][0] +
                       first_stage_macc_dsps_Preg[2][0];
            
            first_stage_feature_map[1]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[1][1] +
                       first_stage_macc_dsps_Preg[2][1] +
                       first_stage_macc_dsps_Preg[3][0];
            
            first_stage_feature_map[2]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[2][2] +
                       first_stage_macc_dsps_Preg[3][1] +
                       first_stage_macc_dsps_Preg[4][0];
            
            first_stage_feature_map[3]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[3][2] +
                       first_stage_macc_dsps_Preg[4][1] +
                       first_stage_macc_dsps_Preg[5][0];
            
            first_stage_feature_map[4]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][1] +
                       first_stage_macc_dsps_Preg[4][2] +
                       first_stage_macc_dsps_Preg[5][1];
            
            first_stage_feature_map[5]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][2] +
                       first_stage_macc_dsps_Preg[1][2] +
                       first_stage_macc_dsps_Preg[5][2];
            
            first_stage_feature_map[6]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][3] +
                       first_stage_macc_dsps_Preg[1][3] +
                       first_stage_macc_dsps_Preg[2][3] +
                       first_stage_macc_dsps_Preg[3][3];
           
            first_stage_feature_map[7]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[1][4] +
                       first_stage_macc_dsps_Preg[2][4] +
                       first_stage_macc_dsps_Preg[3][4] +
                       first_stage_macc_dsps_Preg[4][3];
            
            first_stage_feature_map[8]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[2][5] +
                       first_stage_macc_dsps_Preg[3][5] +
                       first_stage_macc_dsps_Preg[4][4] +
                       first_stage_macc_dsps_Preg[5][3];
                
            first_stage_feature_map[9]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][4] +
                       first_stage_macc_dsps_Preg[3][6] +
                       first_stage_macc_dsps_Preg[4][5] +
                       first_stage_macc_dsps_Preg[5][4];
            
            first_stage_feature_map[10]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][5] +
                       first_stage_macc_dsps_Preg[1][5] +
                       first_stage_macc_dsps_Preg[4][6] +
                       first_stage_macc_dsps_Preg[5][5];
            
            first_stage_feature_map[11]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][6] +
                       first_stage_macc_dsps_Preg[1][6] +
                       first_stage_macc_dsps_Preg[2][6] +
                       first_stage_macc_dsps_Preg[5][6];
            
            first_stage_feature_map[12]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][7] +
                       first_stage_macc_dsps_Preg[1][7] +
                       first_stage_macc_dsps_Preg[3][7] +
                       first_stage_macc_dsps_Preg[4][7];
            
            first_stage_feature_map[13]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[1][8] +
                       first_stage_macc_dsps_Preg[2][7] +
                       first_stage_macc_dsps_Preg[4][8] +
                       first_stage_macc_dsps_Preg[5][7];
            
            first_stage_feature_map[14]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][8] +
                       first_stage_macc_dsps_Preg[2][8] +
                       first_stage_macc_dsps_Preg[3][8] +
                       first_stage_macc_dsps_Preg[5][8];
            
            first_stage_feature_map[15]
                [first_stage_feature_map_row_cnt]
                [first_stage_feature_map_col_cnt]
                    <= first_stage_macc_dsps_Preg[0][9] +
                       first_stage_macc_dsps_Preg[1][9] +
                       first_stage_macc_dsps_Preg[2][9] +
                       first_stage_macc_dsps_Preg[3][9] +
                       first_stage_macc_dsps_Preg[4][9] +
                       first_stage_macc_dsps_Preg[5][9];
            
            first_stage_feature_map_col_cnt <= first_stage_feature_map_col_cnt + 1;
            if (first_stage_feature_map_col_cnt == 9) begin
                first_stage_feature_map_col_cnt <= 0;
                first_stage_feature_map_row_cnt <= first_stage_feature_map_row_cnt + 1;
                if (first_stage_feature_map_row_cnt == 9) begin
                    first_stage_feature_map_row_cnt <= 0;
                    // Each of the 6x10 first stage feature maps are full
                    first_stage_feature_map_full <= 1;
                end
            end
        end
    end
    
    // Next step is to write the output features directly
    // don't need to go through a 48,000-bit BRAM intermediate feature map
    
    always_ff @(posedge i_clk) begin
        o_feature_valid <= 0;
        if (first_stage_feature_map_full) begin
            output_feature_map_col_cnt <= output_feature_map_col_cnt + 1;
            if (output_feature_map_col_cnt == 9) begin
                output_feature_map_col_cnt <= 0;
                output_feature_map_row_cnt <= output_feature_map_row_cnt + 1;
                if (output_feature_map_row_cnt == 9) begin
                    output_feature_map_row_cnt <= 0;
                    // Layer done!
                end
            end
            o_feature_valid <= 1;
            o_features[0]   <= first_stage_feature_map[0] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[1]   <= first_stage_feature_map[1] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[2]   <= first_stage_feature_map[2] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[3]   <= first_stage_feature_map[3] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[4]   <= first_stage_feature_map[4] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[5]   <= first_stage_feature_map[5] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[6]   <= first_stage_feature_map[6] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[7]   <= first_stage_feature_map[7] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[8]   <= first_stage_feature_map[8] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[9]   <= first_stage_feature_map[9] [output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[10]  <= first_stage_feature_map[10][output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[11]  <= first_stage_feature_map[11][output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[12]  <= first_stage_feature_map[12][output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[13]  <= first_stage_feature_map[13][output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[14]  <= first_stage_feature_map[14][output_feature_map_row_cnt][output_feature_map_col_cnt];
            o_features[15]  <= first_stage_feature_map[15][output_feature_map_row_cnt][output_feature_map_col_cnt];
        end
    end
    
endmodule