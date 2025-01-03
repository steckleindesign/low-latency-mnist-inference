`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Trainable parameters:
        120 * (16*5*5 + 1) = 48120
        
    # of * ops = 120*16*5*5 = 48000
    
    90 DSP48s, 48000/90 = 533.3 = 534 clock cycles
    
    400 * ops required for each of the 120 features
    
    least common multiple of 400 and 9 is 9*400=3600
    
    9 sets of 400, will require 3600/90 = 40 clock cycles
    
    40 Cycles:
    Feature n*9 + 0: 90, 90, 90, 90, 40
    Feature n*9 + 1:                 50, 90, 90, 90, 80
    Feature n*9 + 2:                                 10, 90, 90, 90, 90, 30
    Feature n*9 + 3:                                                     60, 90, 90, 90, 70
    Feature n*9 + 4:                                                                     20, 90, 90, 90, 90, 20
    Feature n*9 + 5:                                                                                         70, 90, 90, 90, 60
    Feature n*9 + 6:                                                                                                         30, 90, 90, 90, 90, 10
    Feature n*9 + 7:                                                                                                                             80, 90, 90, 90, 50
    Feature n*9 + 8:                                                                                                                                             40, 90, 90, 90, 90
    
    40 states (adder tree structure - sequential)
    TODO: How to time multiplex resources? We use more registers than the device has with conv3 adder tree alone
        F(9n+0) - 90
                  45 + 90
                  68 + 90
                  79 + 90
                  85 + 40
                  63
                  32
                  16
                  8
                  4
                  2
                  1
        
        F(9n+1) - 50
                  25 + 90
                  58 + 90
                  74 + 90
                  82 + 80
                  81
                  42
                  21
                  11
                  6
                  3
                  2
                  1
        
        F(9n+2) - 10
                  5 + 90
                  48 + 90
                  69 + 90
                  80 + 90
                  85 + 30
                  58
                  29
                  15
                  8
                  4
                  2
                  1
        
        F(9n+3) - 60
                  30 + 90
                  60 + 90
                  75 + 90
                  83 + 70
                  77
                  39
                  20
                  10
                  5
                  3
                  2
                  1
        
        F(9n+4) - 20
                  10 + 90
                  50 + 90
                  70 + 90
                  80 + 90
                  85 + 20
                  53
                  27
                  14
                  7
                  4
                  2
                  1
        
        F(9n+5) - 70
                  35 + 90
                  63 + 90
                  77 + 90
                  84 + 60
                  77
                  39
                  20
                  10
                  5
                  3
                  2
                  1
        
        F(9n+6) - 30
                  15 + 90
                  53 + 90
                  77 + 90
                  84 + 90
                  87 + 10
                  49
                  25
                  13
                  7
                  4
                  2
                  1
        
        F(9n+7) - 80
                  40 + 90
                  65 + 90
                  78 + 90
                  84 + 50
                  67
                  34
                  17
                  9
                  5
                  3
                  2
                  1
        
        F(9n+8) - 40
                  20 + 90
                  55 + 90
                  73 + 90
                  82 + 90
                  86
                  43
                  22
                  11
                  6
                  3
                  2
                  1
    
    40 states (operands - combinatorial)
        1:
            F(9n+0) - S0, S1, S2, S3[14:0]
        
        2:
            F(9n+0) - S3[24:15], S4, S5, S6, S7[4:0]
        
        3:
            F(9n+0) - S7[24:5], S8, S9, S10[19:0]
        
        4:
            F(9n+0) - S10[24:20], S11, S12, S13, S14[9:0]
        
        5:
            F(9n+0) - S14[24:10], S15
            F(9n+1) - S0, S1
        
        6:
            F(9n+1) - S2, S3, S4, S5[14:0]
        
        7:
            F(9n+1) - S5[24:15], S6, S7, S8, S9[4:0]
            
        8:
            F(9n+1) - S9[24:5], S10, S11, S12[19:0]
        
        9:
            F(9n+1) - S12[24:20], S13, S14, S15
            F(9n+2) - S0[9:0]
        
        10:
            F(9n+2) - S0[24:10], S1, S2, S3
        
        11:
            F(9n+2) - S4, S5, S6. S7[14:0]
        
        11:
            F(9n+2) - S7[24:15], S8, S9, S10, S11[4:0]
        
        12:
            F(9n+2) - S11[24:5], S12, S13, S14[19:0]
        
        13:
            F(9n+2) - S14[24:20], S15
            F(9n+3) - S0, S1, S2[9:0]
        
        14:
            F(9n+3) - S2[24:10], S3, S4, S5
        
        15:
            F(9n+3) - S6, S7, S8, S9[14:0]
        
        16:
            F(9n+3) - S9[24:15], S10, S11, S12, S13[4:0]
        
        17:
            F(9n+3) - S13[24:5], S14, S15
            F(9n+4) - S0[19:0]
        
        18:
            F(9n+4) - S0[24:20], S1, S2, S3, S4[9:0]
        
        19:
            F(9n+4) - S4[24:10], S5, S6, S7
        
        20:
            F(9n+4) - S8, S9, S10, S11[14:0]
        
        21:
            F(9n+4) - S11[24:15], S12, S13, S14, S15[4:0]
        
        22:
            F(9n+4) - S15[24:5]
            F(9n+5) - S0, S1, S2[19:0]
        
        23:
            F(9n+5) - S2[24:20], S3, S4, S5, S6[9:0]
        
        24:
            F(9n+5) - S6[24:10], S7, S8, S9
        
        25:
            F(9n+5) - S10, S11, S12, S13[14:0]
        
        26:
            F(9n+5) - S13[24:15], S14, S15
            F(9n+6) - S0, S1[4:0]
        
        27:
            F(9n+6) - S1[24:5], S2, S3, S4[19:0]
        
        28:
            F(9n+6) - S4[24:20], S5, S6, S7, S8[9:0]
        
        29:
            F(9n+6) - S8[24:10], S9, S10, S11
        
        30:
            F(9n+6) - S12, S13, S14, S15[14:0]
        
        31:
            F(9n+6) - S15[24:15]
            F(9n+7) - S0, S1, S2, S3[4:0]
        
        32:
            F(9n+7) - S3[24:5], S4, S5, S6[19:0]
        
        33:
            F(9n+7) - S6[24:20], S7, S8, S9, S10[9:0]
        
        34:
            F(9n+7) - S10[24:10], S11, S12, S13
        
        35:
            F(9n+7) - S14, S15
            F(9n+8) - S0, S1[14:0]
        
        36:
            F(9n+8) - S1[24:15], S2, S3, S4, S5[4:0]
        
        37:
            F(9n+8) - S5[24:5], S6, S7, S8[19:0]
        
        38:
            F(9n+8) - S8[24:20], S9, S10, S11, S12[9:0]
        
        39:
            F(9n+8) - S12[24:10], S13, S14, S15
*/

//////////////////////////////////////////////////////////////////////////////////

module conv3(
    input  logic        i_clk,
    input  logic        i_rst,
    input  logic        i_feature_valid,
    input  logic [15:0] i_features,
    output logic        o_feature_valid,
    output logic [15:0] o_features
);
    
    localparam string WEIGHTS_FILE = "weights.mem";
    localparam string BIASES_FILE  = "biases.mem";
    localparam        INPUT_WIDTH  = 32;
    localparam        INPUT_HEIGHT = 32;
    localparam        FILTER_SIZE  = 5;
    
    // Each convolution is 16*5*5, each of the 120 neurons in this layer connects to all 16 S4 feature maps
    localparam S4_MAPS     = 16;
    localparam KERNEL_SIZE = 5;
    localparam NEURONS     = 120;

    // Computed local params from module parameters
    localparam OUTPUT_HEIGHT = INPUT_HEIGHT - FILTER_SIZE + 1;
    localparam OUTPUT_WIDTH  = INPUT_WIDTH - FILTER_SIZE + 1;
    localparam ROW_START     = FILTER_SIZE/2;
    localparam ROW_END       = INPUT_HEIGHT - FILTER_SIZE/2 - 1;
    localparam COL_START     = FILTER_SIZE/2;
    localparam COL_END       = INPUT_WIDTH - FILTER_SIZE/2 - 1;
    
    // Initialize trainable parameters
    // Weights
    (* rom_style = "block" *) logic signed [15:0]
    weights [NUM_FILTERS-1:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    (* rom_style = "block" *) logic signed [15:0]
    biases [NUM_FILTERS-1:0];
    initial $readmemb(BIASES_FILE, biases);
    
    // Adder tree register structure
    logic signed [23:0] adder1_stage1[89:0];
    logic signed [23:0] adder1_stage2[134:0];
    logic signed [23:0] adder1_stage3[157:0];
    logic signed [23:0] adder1_stage4[168:0];
    logic signed [23:0] adder1_stage5[124:0];
    logic signed [23:0] adder1_stage6[62:0];
    logic signed [23:0] adder1_stage7[31:0];
    logic signed [23:0] adder1_stage8[15:0];
    logic signed [23:0] adder1_stage9[7:0];
    logic signed [23:0] adder1_stage10[3:0];
    logic signed [23:0] adder1_stage11[1:0];
    logic signed [23:0] adder1_result;
    
    logic signed [23:0] adder2_stage1[49:0];
    logic signed [23:0] adder2_stage2[114:0];
    logic signed [23:0] adder2_stage3[147:0];
    logic signed [23:0] adder2_stage4[163:0];
    logic signed [23:0] adder2_stage5[161:0];
    logic signed [23:0] adder2_stage6[80:0];
    logic signed [23:0] adder2_stage7[41:0];
    logic signed [23:0] adder2_stage8[20:0];
    logic signed [23:0] adder2_stage9[10:0];
    logic signed [23:0] adder2_stage10[5:0];
    logic signed [23:0] adder2_stage11[2:0];
    logic signed [23:0] adder2_stage12[1:0];
    logic signed [23:0] adder2_result;
    
    logic signed [23:0] adder3_stage1[9:0];
    logic signed [23:0] adder3_stage2[94:0];
    logic signed [23:0] adder3_stage3[137:0];
    logic signed [23:0] adder3_stage4[158:0];
    logic signed [23:0] adder3_stage5[169:0];
    logic signed [23:0] adder3_stage6[114:0];
    logic signed [23:0] adder3_stage7[57:0];
    logic signed [23:0] adder3_stage8[28:0];
    logic signed [23:0] adder3_stage9[14:0];
    logic signed [23:0] adder3_stage10[7:0];
    logic signed [23:0] adder3_stage11[3:0];
    logic signed [23:0] adder3_stage12[1:0];
    logic signed [23:0] adder3_result;
    
    logic signed [23:0] adder4_stage1[59:0];
    logic signed [23:0] adder4_stage2[119:0];
    logic signed [23:0] adder4_stage3[149:0];
    logic signed [23:0] adder4_stage4[164:0];
    logic signed [23:0] adder4_stage5[152:0];
    logic signed [23:0] adder4_stage6[76:0];
    logic signed [23:0] adder4_stage7[38:0];
    logic signed [23:0] adder4_stage8[19:0];
    logic signed [23:0] adder4_stage9[9:0];
    logic signed [23:0] adder4_stage10[4:0];
    logic signed [23:0] adder4_stage11[2:0];
    logic signed [23:0] adder4_stage12[1:0];
    logic signed [23:0] adder4_result;
    
    logic signed [23:0] adder5_stage1[19:0];
    logic signed [23:0] adder5_stage2[99:0];
    logic signed [23:0] adder5_stage3[139:0];
    logic signed [23:0] adder5_stage4[159:0];
    logic signed [23:0] adder5_stage5[169:0];
    logic signed [23:0] adder5_stage6[104:0];
    logic signed [23:0] adder5_stage7[52:0];
    logic signed [23:0] adder5_stage8[26:0];
    logic signed [23:0] adder5_stage9[13:0];
    logic signed [23:0] adder5_stage10[6:0];
    logic signed [23:0] adder5_stage11[3:0];
    logic signed [23:0] adder5_stage12[1:0];
    logic signed [23:0] adder5_result;
    
    logic signed [23:0] adder6_stage1[69:0];
    logic signed [23:0] adder6_stage2[124:0];
    logic signed [23:0] adder6_stage3[152:0];
    logic signed [23:0] adder6_stage4[166:0];
    logic signed [23:0] adder6_stage5[143:0];
    logic signed [23:0] adder6_stage6[76:0];
    logic signed [23:0] adder6_stage7[38:0];
    logic signed [23:0] adder6_stage8[19:0];
    logic signed [23:0] adder6_stage9[9:0];
    logic signed [23:0] adder6_stage10[4:0];
    logic signed [23:0] adder6_stage11[2:0];
    logic signed [23:0] adder6_stage12[1:0];
    logic signed [23:0] adder6_result;
    
    logic signed [23:0] adder7_stage1[29:0];
    logic signed [23:0] adder7_stage2[104:0];
    logic signed [23:0] adder7_stage3[142:0];
    logic signed [23:0] adder7_stage4[166:0];
    logic signed [23:0] adder7_stage5[173:0];
    logic signed [23:0] adder7_stage6[96:0];
    logic signed [23:0] adder7_stage7[48:0];
    logic signed [23:0] adder7_stage8[24:0];
    logic signed [23:0] adder7_stage9[12:0];
    logic signed [23:0] adder7_stage10[6:0];
    logic signed [23:0] adder7_stage11[3:0];
    logic signed [23:0] adder7_stage12[1:0];
    logic signed [23:0] adder7_result;
    
    logic signed [23:0] adder8_stage1[79:0];
    logic signed [23:0] adder8_stage2[129:0];
    logic signed [23:0] adder8_stage3[154:0];
    logic signed [23:0] adder8_stage4[167:0];
    logic signed [23:0] adder8_stage5[133:0];
    logic signed [23:0] adder8_stage6[66:0];
    logic signed [23:0] adder8_stage7[33:0];
    logic signed [23:0] adder8_stage8[16:0];
    logic signed [23:0] adder8_stage9[8:0];
    logic signed [23:0] adder8_stage10[4:0];
    logic signed [23:0] adder8_stage11[2:0];
    logic signed [23:0] adder8_stage12[1:0];
    logic signed [23:0] adder8_result;
    
    logic signed [23:0] adder9_stage1[39:0];
    logic signed [23:0] adder9_stage2[109:0];
    logic signed [23:0] adder9_stage3[144:0];
    logic signed [23:0] adder9_stage4[162:0];
    logic signed [23:0] adder9_stage5[171:0];
    logic signed [23:0] adder9_stage6[85:0];
    logic signed [23:0] adder9_stage7[42:0];
    logic signed [23:0] adder9_stage8[21:0];
    logic signed [23:0] adder9_stage9[10:0];
    logic signed [23:0] adder9_stage10[5:0];
    logic signed [23:0] adder9_stage11[2:0];
    logic signed [23:0] adder9_stage12[1:0];
    logic signed [23:0] adder9_result;
    
    
endmodule