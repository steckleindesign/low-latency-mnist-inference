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
    
    Potential mapping of the 18 DSP groups by cycle
    cyc 1:         cyc 2:         cyc 3:         cyc 4:         cyc 5:
        row 1: 4       row 1: 4       row 1: 3       row 1: 4       row 1: 3
        row 2: 4       row 2: 3       row 2: 4       row 2: 4       row 2: 3
        row 3: 4       row 3: 3       row 3: 4       row 3: 3       row 3: 4
        row 4: 3       row 4: 4       row 4: 4       row 4: 3       row 4: 4
        row 5: 3       row 5: 4       row 5: 3       row 5: 4       row 5: 4
    
    FUTURE IDEAS
    -------------------------------------------------------------------------------
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
    
    We are only doing 9x9 convolutions
    and there are 10 weight kernals for
    each S2 map and 90 DSPs.
    
    So we divide DSPs into 10 groups of 9.
    Each DSP group has the job of working on its own row
    It will take 25 clock cycles For each of these rows
    
    16 10x10 output feature maps = 1600 8-bit values = 12,800 bits
    So there are 1600 accumulate values
    
    -------------------------------------------------------------------------------
    
    Another idea is to have a single DSP dedicated to each input feature map
    However, there are only 60 input features maps.
    
    6x196 8-bit feature RAMs of S2 feature data each RAM feeds feature operands to 10 different DSPs
    
    While we are performing a 5x5 kernel multiply on a single DSP
    We also need to accumulate each of the 25 multiply results
    Every 5x5=25 cycles, we store an output feature which is the accumulate value of the DSP
    
    60 intermediate maps x 10x10 features x 8-bit values = 60x10x10x8 = 48,000 bits
    They will have to be stored in BRAM as SRs
    
    After we have the 60 intermediate maps, we have to use this data for add
    operations to compute the C3 feature maps
    
    MACC (DSP48E1) output muxing to C3 feature maps:
    There are either 3, 4, or 6 DSP outputs to be added
    The remaining 30 DSP48E1s shall be used efficiently to perform these additions
    Each of the 60 "*" DSP outputs can be directly connected to the
    appropriate "+" DSP inputs as adder operands.
    The DSP48E1 based adder tree structure may need to be instantiated or at least
    synthesis attributes shall be used to ensure the adder tree structure uses DSPs
    This architecture will minimize hardware resources and eliminates large muxes.
    The tradeoff is latency wont be optimal.
    
    The last thing we decide is how the output data shall be configured in HW.
    conv3 processes the feature maps sequentially from top left of S4 to
    bottom right of S4. So we need to store the output feature map data for
    this layer in a single deep shift register.
    
    
    Theory of operation:
    1) Gather features into 6 14x5 8-bit feature buffers (6x70 8-bit data)
    2) When the feature buffer is full enough (4 rows and first feature of 5th row)
        MACC operations should begin
    3) MACC operation consists of 25 cycles per output feature accumulation
    4) Store output feature accumulations in their own 60 feature maps
        That's 60x10x10 8-bit values = 6000 8-bit values, or 48,000 bits (Needs 3 18kb BRAMs)
    5) Use DSPs to add appropriate output feature map values into 16 C3 feature maps
    
    Difficult part is the control logic and the mechanism for storing data between
    each data processing phase
    
    The data from S2 comes in parallel between all 6 feature maps, and serially
    on a per feature map basis
    
    
    
    Define the full DSP48E1 register pipeline for 60 DSPs                            - X
    Create the datapaths from input_features[0-5][0-9] to DSPs first stage regs      - X
    Develop the conv MACC DSP48 function logic                                       - X
    Develop datapaths from Preg (accumulate) of DSP48 to intermediate feature RAMs   - X
    Develop datapaths from intermediate feature RAMs to adder function DSP48s        - X
    
    Develop adder function DSPs function logic                                       
    
    Develop datapaths from adder DSPs to output ports                                
        - Data shall be serially sent to max pooling layer 2,
            in parallel between the 16 C3 feature maps
        - It is the max pooling layers job to to arange the
            data in an ordered RAM format
    
*/

//////////////////////////////////////////////////////////////////////////////////

module conv2(
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic               i_feature_valid,
    input  logic         [7:0] i_features[0:5],
    output logic               o_feature_valid,
    output logic signed [15:0] o_features
);

    localparam WEIGHTS_FILE     = "conv2_weights.mem";
    localparam BIASES_FILE      = "conv2_biases.mem";
    localparam INPUT_CHANNELS   = 6;
    localparam INPUT_WIDTH      = 14;
    localparam INPUT_HEIGHT     = 14;
    localparam FILTER_SIZE      = 5;
    localparam NUM_DSP          = 90;
    
    localparam WINDOW_AREA   = FILTER_SIZE * FILTER_SIZE;
    localparam OUTPUT_HEIGHT = INPUT_HEIGHT - FILTER_SIZE + 1;
    localparam OUTPUT_WIDTH  = INPUT_WIDTH - FILTER_SIZE + 1;

    logic signed [7:0] weights [0:59];
    initial $readmemb(WEIGHTS_FILE, weights);
    
    logic signed [7:0] biases [0:5][0:9];
    initial $readmemb(BIASES_FILE, biases);
    
    // DSP48E1 operands for the first stage of MACC operations
    logic        [7:0] s2_conv_feature_operands[0:59];
    logic signed [7:0] s2_conv_weight_operands[0:59];
    
    // Feature conv location
    logic [INPUT_HEIGHT-1:0] feat_row_ctr;
    logic [INPUT_WIDTH-1:0] feat_col_ctr;
    
    logic [$clog2(INPUT_HEIGHT)-1:0] ram_row_ctr;
    logic [$clog2(INPUT_WIDTH)-1:0]  ram_col_ctr;
    
    // Enable convolution MACC operations on this layer (CONV2)
    logic layer_en;
    
    
    
    
    // Keep track of how many output features we have computed
    logic [$clog2(10*10)-1:0] conv_output_feature_ctr;
    // Keep track of how many intermediate features we have computed
    logic [$clog2(10*10)-1:0] conv_interm_feature_ctr;
    // Keep track of how many elements in the current
    // 5x5 conv kernel we've performed a MACC operation
    logic [$clog2(25)-1:0] conv_acc_ctr;
    // Intermediate results after convolving the 60 instances
    // of convolutions on S2 input feature maps
    // 6 S2 maps | 10 unique weight kernels for each S2 map | 10x10 feature map
    // 48000 bits -> Distributed RAM utilization is 120 CLBs
    // This is the case if both slices in each CLB are SLICEM
    logic signed [7:0] s2_conv_acc_map[0:5][0:9][0:99];
    // First stage DSPs should be fully pipelined => dual AD, dual B, M, P registers
    // Register stage 1 -> pipeline inputs
    logic signed [15:0] first_stage_macc_dsps_dualAD1reg[0:59];
    logic signed [15:0] first_stage_macc_dsps_dualB1reg[0:59];
    // Register stage 2 -> pipeline outputs
    logic signed [15:0] first_stage_macc_dsps_dualAD2reg[0:59];
    logic signed [15:0] first_stage_macc_dsps_dualB2reg[0:59];
    // Register stage 3 -> multiplcation result
    logic signed [15:0] first_stage_macc_dsps_Mreg[0:59];
    // Register stage 4 -> accumulate
    logic signed [15:0] first_stage_macc_dsps_Preg[0:59];
    
    // Three operand add, need to add fabric FFs for
    // D and C operand to match pipeline delay of A operand
    // A -> A1 -> A2 -> AD ->  M ->  P
    // D -> FF ->  D -> AD ->  M ->  P
    // C -> FF -> FF -> FF ->  C ->  P -> P
    
    // C -> FF -> FF -> FF -> FF ->  C -> P
    
    // Adder DSPs
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
    
    // Stage 1 MACC logic
    always_ff @(posedge i_clk)
        for (int i = 0; i < 6; i++)
            for (int j = 0; j < 10; j++) begin
                first_stage_macc_dsps_dualAD1reg[i][j]
                    <= i_features[i];
                first_stage_macc_dsps_dualB1reg[i][j]
                    <= weights[i*10+j];
                
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
    
    always_ff @(posedge i_clk) begin
        if (conv_acc_ctr == 24) begin
            for (int i = 0; i < 6; i++)
                for (int j = 0; j < 10; j++)
                    s2_conv_acc_map[i][j][conv_interm_feature_ctr]
                        <= first_stage_macc_dsps_Preg[i][j];
            conv_interm_feature_ctr <= conv_interm_feature_ctr + 1;
        end
    end
    
    // Adder DSP logic
    always_ff @(posedge i_clk) begin
        // C3 maps 0-5  use 1 DSP
        // adder_dsp_0  -> map[0][0], map[1][0], map[2][0]
        // adder_dsp_1  -> map[1][1], map[2][1], map[3][0]
        // adder_dsp_2  -> map[2][2], map[3][1], map[4][0]
        // adder_dsp_3  -> map[3][2], map[4][1], map[5][0]
        // adder_dsp_4  -> map[0][1], map[4][2], map[5][1]
        // adder_dsp_5  -> map[0][2], map[1][2], map[5][2]
        
        // C3 maps 6-14 use 2 DSP
        // adder_dsp_6  -> map[0][3], map[1][3], map[2][3]
        // adder_dsp_7  -> adder_dsp_6, map[3][3]
        // adder_dsp_8  -> map[1][4], map[2][4], map[3][4]
        // adder_dsp_9  -> adder_dsp_8, map[4][3]
        // adder_dsp_10 -> map[2][5], map[3][5], map[4][4]
        // adder_dsp_11 -> adder_dsp_10, map[5][3]
        // adder_dsp_12 -> map[0][4], map[3][6], map[4][5]
        // adder_dsp_13 -> adder_dsp_12, map[5][4]
        // adder_dsp_14 -> map[0][5], map[1][5], map[4][6]
        // adder_dsp_15 -> adder_dsp_14, map[5][5]
        // adder_dsp_16 -> map[0][6], map[1][6], map[2][6]
        // adder_dsp_17 -> adder_dsp_16, map[5][6]
        // adder_dsp_18 -> map[0][7], map[1][7], map[3][7]
        // adder_dsp_19 -> adder_dsp_18, map[4][7]
        // adder_dsp_20 -> map[1][8], map[2][7], map[4][8]
        // adder_dsp_21 -> adder_dsp_20, map[5][7]
        // adder_dsp_22 -> map[0][8], map[2][8], map[3][8]
        // adder_dsp_23 -> adder_dsp_22, map[5][8]
        
        // C3 maps 15   use 3 DSP
        // adder_dsp_24 -> map[0][9], map[1][9], map[2][9]
        // adder_dsp_25 -> map[3][9], map[4][9], map[5][9]
        // adder_dsp_26 -> adder_dsp_24, adder_dsp_25
        
        // Operand 1
        adder_dsp_0_A1 <= s2_conv_acc_map[0][0];
        adder_dsp_0_A2 <= adder_dsp_0_A1;
        // Operand 2
        adder_dsp_0_FFD <= s2_conv_acc_map[1][0];
        adder_dsp_0_D <= adder_dsp_0_FFD;
        // Operand 1 + 2
        adder_dsp_0_AD <= adder_dsp_0_A2 + adder_dsp_0_D;
        // Multiply AD register value with B2 register value of 1
        // Result is just AD register value, delayed by 1 clock cycle
        // In other words, the AD register value with 1 clock cycle of latency
        adder_dsp_0_M <= adder_dsp_0_AD;
        // Operand 3
        adder_dsp_0_FFC0 <= s2_conv_acc_map[2][0];
        adder_dsp_0_FFC1 <= adder_dsp_0_FFC0;
        adder_dsp_0_FFC2 <= adder_dsp_0_FFC1;
        adder_dsp_0_C <= adder_dsp_0_FFC2;
        // Operand 1+2 + 3
        adder_dsp_0_P <= adder_dsp_0_M + adder_dsp_0_C;
        
        adder_dsp_1_A1 <= s2_conv_acc_map[1][1];
        adder_dsp_1_A2 <= adder_dsp_1_A1;
        adder_dsp_1_FFD <= s2_conv_acc_map[2][1];
        adder_dsp_1_D <= adder_dsp_1_FFD;
        adder_dsp_1_AD <= adder_dsp_1_A2 + adder_dsp_1_D;
        adder_dsp_1_M <= adder_dsp_1_AD;
        adder_dsp_1_FFC0 <= s2_conv_acc_map[3][0];
        adder_dsp_1_FFC1 <= adder_dsp_1_FFC0;
        adder_dsp_1_FFC2 <= adder_dsp_1_FFC1;
        adder_dsp_1_C <= adder_dsp_1_FFC2;
        adder_dsp_1_P <= adder_dsp_1_M + adder_dsp_1_C;
        
        adder_dsp_2_A1 <= s2_conv_acc_map[2][2];
        adder_dsp_2_A2 <= adder_dsp_2_A1;
        adder_dsp_2_FFD <= s2_conv_acc_map[3][1];
        adder_dsp_2_D <= adder_dsp_2_FFD;
        adder_dsp_2_AD <= adder_dsp_2_A2 + adder_dsp_2_D;
        adder_dsp_2_M <= adder_dsp_2_AD;
        adder_dsp_2_FFC0 <= s2_conv_acc_map[4][0];
        adder_dsp_2_FFC1 <= adder_dsp_2_FFC0;
        adder_dsp_2_FFC2 <= adder_dsp_2_FFC1;
        adder_dsp_2_C <= adder_dsp_2_FFC2;
        adder_dsp_2_P <= adder_dsp_2_M + adder_dsp_2_C;
        
        adder_dsp_3_A1 <= s2_conv_acc_map[3][2];
        adder_dsp_3_A2 <= adder_dsp_3_A1;
        adder_dsp_3_FFD <= s2_conv_acc_map[4][1];
        adder_dsp_3_D <= adder_dsp_3_FFD;
        adder_dsp_3_AD <= adder_dsp_3_A2 + adder_dsp_3_D;
        adder_dsp_3_M <= adder_dsp_3_AD;
        adder_dsp_3_FFC0 <= s2_conv_acc_map[5][0];
        adder_dsp_3_FFC1 <= adder_dsp_3_FFC0;
        adder_dsp_3_FFC2 <= adder_dsp_3_FFC1;
        adder_dsp_3_C <= adder_dsp_3_FFC2;
        adder_dsp_3_P <= adder_dsp_3_M + adder_dsp_3_C;
        
        adder_dsp_4_A1 <= s2_conv_acc_map[0][1];
        adder_dsp_4_A2 <= adder_dsp_4_A1;
        adder_dsp_4_FFD <= s2_conv_acc_map[4][2];
        adder_dsp_4_D <= adder_dsp_4_FFD;
        adder_dsp_4_AD <= adder_dsp_4_A2 + adder_dsp_4_D;
        adder_dsp_4_M <= adder_dsp_4_AD;
        adder_dsp_4_FFC0 <= s2_conv_acc_map[5][1];
        adder_dsp_4_FFC1 <= adder_dsp_4_FFC0;
        adder_dsp_4_FFC2 <= adder_dsp_4_FFC1;
        adder_dsp_4_C <= adder_dsp_4_FFC2;
        adder_dsp_4_P <= adder_dsp_4_M + adder_dsp_4_C;
        
        adder_dsp_5_A1 <= s2_conv_acc_map[0][2];
        adder_dsp_5_A2 <= adder_dsp_5_A1;
        adder_dsp_5_FFD <= s2_conv_acc_map[1][2];
        adder_dsp_5_D <= adder_dsp_5_FFD;
        adder_dsp_5_AD <= adder_dsp_5_A2 + adder_dsp_5_D;
        adder_dsp_5_M <= adder_dsp_5_AD;
        adder_dsp_5_FFC0 <= s2_conv_acc_map[5][2];
        adder_dsp_5_FFC1 <= adder_dsp_5_FFC0;
        adder_dsp_5_FFC2 <= adder_dsp_5_FFC1;
        adder_dsp_5_C <= adder_dsp_5_FFC2;
        adder_dsp_5_P <= adder_dsp_5_M + adder_dsp_5_C;
        
        
        adder_dsp_6_A1 <= s2_conv_acc_map[0][3];
        adder_dsp_6_A2 <= adder_dsp_6_A1;
        adder_dsp_6_FFD <= s2_conv_acc_map[1][3];
        adder_dsp_6_D <= adder_dsp_6_FFD;
        adder_dsp_6_AD <= adder_dsp_6_A2 + adder_dsp_6_D;
        adder_dsp_6_M <= adder_dsp_6_AD;
        adder_dsp_6_FFC0 <= s2_conv_acc_map[2][3];
        adder_dsp_6_FFC1 <= adder_dsp_6_FFC0;
        adder_dsp_6_FFC2 <= adder_dsp_6_FFC1;
        adder_dsp_6_C <= adder_dsp_6_FFC2;
        adder_dsp_6_P <= adder_dsp_6_M + adder_dsp_6_C;
        
        adder_dsp_7_FFC0 <= s2_conv_acc_map[3][3];
        adder_dsp_7_FFC1 <= adder_dsp_7_FFC0;
        adder_dsp_7_FFC2 <= adder_dsp_7_FFC1;
        adder_dsp_7_FFC3 <= adder_dsp_7_FFC2;
        adder_dsp_7_C <= adder_dsp_7_FFC3;
        adder_dsp_7_P <= adder_dsp_6_P + adder_dsp_7_C;
        
        adder_dsp_8_A1 <= s2_conv_acc_map[1][4];
        adder_dsp_8_A2 <= adder_dsp_8_A1;
        adder_dsp_8_FFD <= s2_conv_acc_map[2][4];
        adder_dsp_8_D <= adder_dsp_8_FFD;
        adder_dsp_8_AD <= adder_dsp_8_A2 + adder_dsp_8_D;
        adder_dsp_8_M <= adder_dsp_8_AD;
        adder_dsp_8_FFC0 <= s2_conv_acc_map[3][4];
        adder_dsp_8_FFC1 <= adder_dsp_8_FFC0;
        adder_dsp_8_FFC2 <= adder_dsp_8_FFC1;
        adder_dsp_8_C <= adder_dsp_8_FFC2;
        adder_dsp_8_P <= adder_dsp_8_M + adder_dsp_8_C;
        
        adder_dsp_9_FFC0 <= s2_conv_acc_map[4][3];
        adder_dsp_9_FFC1 <= adder_dsp_9_FFC0;
        adder_dsp_9_FFC2 <= adder_dsp_9_FFC1;
        adder_dsp_9_FFC3 <= adder_dsp_9_FFC2;
        adder_dsp_9_C <= adder_dsp_9_FFC3;
        adder_dsp_9_P <= adder_dsp_8_P + adder_dsp_9_C;
        
        adder_dsp_10_A1 <= s2_conv_acc_map[2][5];
        adder_dsp_10_A2 <= adder_dsp_10_A1;
        adder_dsp_10_FFD <= s2_conv_acc_map[3][5];
        adder_dsp_10_D <= adder_dsp_10_FFD;
        adder_dsp_10_AD <= adder_dsp_10_A2 + adder_dsp_10_D;
        adder_dsp_10_M <= adder_dsp_10_AD;
        adder_dsp_10_FFC0 <= s2_conv_acc_map[4][4];
        adder_dsp_10_FFC1 <= adder_dsp_10_FFC0;
        adder_dsp_10_FFC2 <= adder_dsp_10_FFC1;
        adder_dsp_10_C <= adder_dsp_10_FFC2;
        adder_dsp_10_P <= adder_dsp_10_M + adder_dsp_10_C;
        
        adder_dsp_11_FFC0 <= s2_conv_acc_map[5][3];
        adder_dsp_11_FFC1 <= adder_dsp_11_FFC0;
        adder_dsp_11_FFC2 <= adder_dsp_11_FFC1;
        adder_dsp_11_FFC3 <= adder_dsp_11_FFC2;
        adder_dsp_11_C <= adder_dsp_11_FFC3;
        adder_dsp_11_P <= adder_dsp_10_P + adder_dsp_11_C;
        
        adder_dsp_12_A1 <= s2_conv_acc_map[0][4];
        adder_dsp_12_A2 <= adder_dsp_12_A1;
        adder_dsp_12_FFD <= s2_conv_acc_map[3][6];
        adder_dsp_12_D <= adder_dsp_12_FFD;
        adder_dsp_12_AD <= adder_dsp_12_A2 + adder_dsp_12_D;
        adder_dsp_12_M <= adder_dsp_12_AD;
        adder_dsp_12_FFC0 <= s2_conv_acc_map[4][5];
        adder_dsp_12_FFC1 <= adder_dsp_12_FFC0;
        adder_dsp_12_FFC2 <= adder_dsp_12_FFC1;
        adder_dsp_12_C <= adder_dsp_12_FFC2;
        adder_dsp_12_P <= adder_dsp_12_M + adder_dsp_12_C;
        
        adder_dsp_13_FFC0 <= s2_conv_acc_map[5][4];
        adder_dsp_13_FFC1 <= adder_dsp_13_FFC0;
        adder_dsp_13_FFC2 <= adder_dsp_13_FFC1;
        adder_dsp_13_FFC3 <= adder_dsp_13_FFC2;
        adder_dsp_13_C <= adder_dsp_13_FFC3;
        adder_dsp_13_P <= adder_dsp_12_P + adder_dsp_13_C;
        
        adder_dsp_14_A1 <= s2_conv_acc_map[0][5];
        adder_dsp_14_A2 <= adder_dsp_14_A1;
        adder_dsp_14_FFD <= s2_conv_acc_map[1][5];
        adder_dsp_14_D <= adder_dsp_14_FFD;
        adder_dsp_14_AD <= adder_dsp_14_A2 + adder_dsp_14_D;
        adder_dsp_14_M <= adder_dsp_14_AD;
        adder_dsp_14_FFC0 <= s2_conv_acc_map[4][6];
        adder_dsp_14_FFC1 <= adder_dsp_14_FFC0;
        adder_dsp_14_FFC2 <= adder_dsp_14_FFC1;
        adder_dsp_14_C <= adder_dsp_14_FFC2;
        adder_dsp_14_P <= adder_dsp_14_M + adder_dsp_14_C;
        
        adder_dsp_15_FFC0 <= s2_conv_acc_map[5][5];
        adder_dsp_15_FFC1 <= adder_dsp_15_FFC0;
        adder_dsp_15_FFC2 <= adder_dsp_15_FFC1;
        adder_dsp_15_FFC3 <= adder_dsp_15_FFC2;
        adder_dsp_15_C <= adder_dsp_15_FFC3;
        adder_dsp_15_P <= adder_dsp_14_P + adder_dsp_15_C;
        
        adder_dsp_16_A1 <= s2_conv_acc_map[0][6];
        adder_dsp_16_A2 <= adder_dsp_16_A1;
        adder_dsp_16_FFD <= s2_conv_acc_map[1][6];
        adder_dsp_16_D <= adder_dsp_16_FFD;
        adder_dsp_16_AD <= adder_dsp_16_A2 + adder_dsp_16_D;
        adder_dsp_16_M <= adder_dsp_16_AD;
        adder_dsp_16_FFC0 <= s2_conv_acc_map[2][6];
        adder_dsp_16_FFC1 <= adder_dsp_16_FFC0;
        adder_dsp_16_FFC2 <= adder_dsp_16_FFC1;
        adder_dsp_16_C <= adder_dsp_16_FFC2;
        adder_dsp_16_P <= adder_dsp_16_M + adder_dsp_16_C;
        
        adder_dsp_17_FFC0 <= s2_conv_acc_map[5][6];
        adder_dsp_17_FFC1 <= adder_dsp_17_FFC0;
        adder_dsp_17_FFC2 <= adder_dsp_17_FFC1;
        adder_dsp_17_FFC3 <= adder_dsp_17_FFC2;
        adder_dsp_17_C <= adder_dsp_17_FFC3;
        adder_dsp_17_P <= adder_dsp_16_P + adder_dsp_17_C;
        
        adder_dsp_18_A1 <= s2_conv_acc_map[0][7];
        adder_dsp_18_A2 <= adder_dsp_18_A1;
        adder_dsp_18_FFD <= s2_conv_acc_map[1][7];
        adder_dsp_18_D <= adder_dsp_18_FFD;
        adder_dsp_18_AD <= adder_dsp_18_A2 + adder_dsp_18_D;
        adder_dsp_18_M <= adder_dsp_18_AD;
        adder_dsp_18_FFC0 <= s2_conv_acc_map[3][7];
        adder_dsp_18_FFC1 <= adder_dsp_18_FFC0;
        adder_dsp_18_FFC2 <= adder_dsp_18_FFC1;
        adder_dsp_18_C <= adder_dsp_18_FFC2;
        adder_dsp_18_P <= adder_dsp_18_M + adder_dsp_18_C;
        
        adder_dsp_19_FFC0 <= s2_conv_acc_map[4][7];
        adder_dsp_19_FFC1 <= adder_dsp_19_FFC0;
        adder_dsp_19_FFC2 <= adder_dsp_19_FFC1;
        adder_dsp_19_FFC3 <= adder_dsp_19_FFC2;
        adder_dsp_19_C <= adder_dsp_19_FFC3;
        adder_dsp_19_P <= adder_dsp_18_P + adder_dsp_19_C;
        
        adder_dsp_20_A1 <= s2_conv_acc_map[1][8];
        adder_dsp_20_A2 <= adder_dsp_20_A1;
        adder_dsp_20_FFD <= s2_conv_acc_map[2][7];
        adder_dsp_20_D <= adder_dsp_20_FFD;
        adder_dsp_20_AD <= adder_dsp_20_A2 + adder_dsp_20_D;
        adder_dsp_20_M <= adder_dsp_20_AD;
        adder_dsp_20_FFC0 <= s2_conv_acc_map[4][8];
        adder_dsp_20_FFC1 <= adder_dsp_20_FFC0;
        adder_dsp_20_FFC2 <= adder_dsp_20_FFC1;
        adder_dsp_20_C <= adder_dsp_20_FFC2;
        adder_dsp_20_P <= adder_dsp_20_M + adder_dsp_20_C;
        
        adder_dsp_21_FFC0 <= s2_conv_acc_map[5][7];
        adder_dsp_21_FFC1 <= adder_dsp_21_FFC0;
        adder_dsp_21_FFC2 <= adder_dsp_21_FFC1;
        adder_dsp_21_FFC3 <= adder_dsp_21_FFC2;
        adder_dsp_21_C <= adder_dsp_21_FFC3;
        adder_dsp_21_P <= adder_dsp_20_P + adder_dsp_21_C;
        
        adder_dsp_22_A1 <= s2_conv_acc_map[0][8];
        adder_dsp_22_A2 <= adder_dsp_22_A1;
        adder_dsp_22_FFD <= s2_conv_acc_map[2][8];
        adder_dsp_22_D <= adder_dsp_22_FFD;
        adder_dsp_22_AD <= adder_dsp_22_A2 + adder_dsp_22_D;
        adder_dsp_22_M <= adder_dsp_22_AD;
        adder_dsp_22_FFC0 <= s2_conv_acc_map[3][8];
        adder_dsp_22_FFC1 <= adder_dsp_22_FFC0;
        adder_dsp_22_FFC2 <= adder_dsp_22_FFC1;
        adder_dsp_22_C <= adder_dsp_22_FFC2;
        adder_dsp_22_P <= adder_dsp_22_M + adder_dsp_22_C;
        
        adder_dsp_23_FFC0 <= s2_conv_acc_map[5][8];
        adder_dsp_23_FFC1 <= adder_dsp_23_FFC0;
        adder_dsp_23_FFC2 <= adder_dsp_23_FFC1;
        adder_dsp_23_FFC3 <= adder_dsp_23_FFC2;
        adder_dsp_23_C <= adder_dsp_23_FFC3;
        adder_dsp_23_P <= adder_dsp_22_P + adder_dsp_23_C;
        
        
        adder_dsp_24_A1 <= s2_conv_acc_map[0][9];
        adder_dsp_24_A2 <= adder_dsp_24_A1;
        adder_dsp_24_FFD <= s2_conv_acc_map[1][9];
        adder_dsp_24_D <= adder_dsp_24_FFD;
        adder_dsp_24_AD <= adder_dsp_24_A2 + adder_dsp_24_D;
        adder_dsp_24_M <= adder_dsp_24_AD;
        adder_dsp_24_FFC0 <= s2_conv_acc_map[2][9];
        adder_dsp_24_FFC1 <= adder_dsp_24_FFC0;
        adder_dsp_24_FFC2 <= adder_dsp_24_FFC1;
        adder_dsp_24_C <= adder_dsp_24_FFC2;
        adder_dsp_24_P <= adder_dsp_24_M + adder_dsp_24_C;
        
        adder_dsp_25_A1 <= s2_conv_acc_map[3][9];
        adder_dsp_25_A2 <= adder_dsp_25_A1;
        adder_dsp_25_FFD <= s2_conv_acc_map[4][9];
        adder_dsp_25_D <= adder_dsp_25_FFD;
        adder_dsp_25_AD <= adder_dsp_25_A2 + adder_dsp_25_D;
        adder_dsp_25_M <= adder_dsp_25_AD;
        adder_dsp_25_FFC0 <= s2_conv_acc_map[5][9];
        adder_dsp_25_FFC1 <= adder_dsp_25_FFC0;
        adder_dsp_25_FFC2 <= adder_dsp_25_FFC1;
        adder_dsp_25_C <= adder_dsp_25_FFC2;
        adder_dsp_25_P <= adder_dsp_25_M + adder_dsp_25_C;
        
        adder_dsp_26_P <= adder_dsp_24_P + adder_dsp_25_P;
    end
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst) begin
            ram_row_ctr      <= 0;
            ram_col_ctr      <= 0;
            feature_ram_full <= 0;
            layer_en         <= 0;
        end else begin
            if (i_feature_valid) begin
                for (int i = 0; i < INPUT_CHANNELS; i++)
                    feature_ram[i][ram_row_ctr][ram_col_ctr] <= i_features[i];
                ram_col_ctr <= ram_col_ctr + 1;
                if (ram_col_ctr == INPUT_WIDTH-1)
                    ram_row_ctr <= ram_row_ctr + 1;
                if (ram_row_ctr[2] & ram_row_ctr[0])
                    macc_en <= 1;
                // What logic is going to use the RAM full flag?
                if (ram_row_ctr == INPUT_HEIGHT-1 && ram_col_ctr == INPUT_WIDTH-1)
                    ram_full <= 1;
            end
        end
    end
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst) begin
            feat_row_ctr <= ROW_START;
            feat_col_ctr <= COL_START;
        end else begin
            feat_col_ctr <= feat_col_ctr + 1;
            if (feat_col_ctr == COL_END) begin
                feat_col_ctr <= 0;
                feat_row_ctr <= feat_row_ctr == COL_END ? 0: feat_row_ctr + 1;
            end
        end
    end

endmodule