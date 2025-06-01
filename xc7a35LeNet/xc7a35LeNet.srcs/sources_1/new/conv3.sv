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
    
    So we will be able to process 120/9 = 13.x = 13 sets of 9 features = 117,
    so the last 3 features will be inefficient by 1 clock cycle, but we could
    optimize by seeing how we can use the open DSP48E1s in the next layer
    
    40 Cycles:
    Feature n*9 + 0: 90, 90, 90, 90, 40, x,  x,  x,  x,  x,  x,  x,  x
    Feature n*9 + 1:                 50, 90, 90, 90, 80, x,  x,  x,  x,  x,  x,  x,  x,  x
    Feature n*9 + 2:                                 10, 90, 90, 90, 90, 30, x,  x,  x,  x,  x,  x,  x,  x,  x
    Feature n*9 + 3:                                                     60, 90, 90, 90, 70, x,  x,  x,  x,  x,  x,  x,  x,  x
    Feature n*9 + 4:                                                                     20, 90, 90, 90, 90, 20, x,  x,  x,  x,  x,  x,  x,  x,  x
    Feature n*9 + 5:                                                                                         70, 90, 90, 90, 60, x,  x,  x,  x,  x,  x,  x,  x,  x
    Feature n*9 + 6:                                                                                                         30, 90, 90, 90, 90, 10, x,  x,  x,  x,  x,  x,  x,  x,
    Feature n*9 + 7: x,                                                                                                                          80, 90, 90, 90, 50, x,  x,  x,  x,
    Feature n*9 + 8: x,  x,  x,  x,  x                                                                                                                           40, 90, 90, 90, 90,
    
    40 states (adder tree structure - sequential)
    TODO: How to time multiplex resources? We use more registers than the device has with conv3 adder tree alone
    
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
    
    logic signed [23:0] mult_out[89:0];
    
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
    logic signed [23:0] adder2_stage7[40:0];
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
    logic signed [23:0] adder6_stage6[71:0];
    logic signed [23:0] adder6_stage7[35:0];
    logic signed [23:0] adder6_stage8[17:0];
    logic signed [23:0] adder6_stage9[8:0];
    logic signed [23:0] adder6_stage10[4:0];
    logic signed [23:0] adder6_stage11[2:0];
    logic signed [23:0] adder6_stage12[1:0];
    logic signed [23:0] adder6_result;
    
    logic signed [23:0] adder7_stage1[29:0];
    logic signed [23:0] adder7_stage2[104:0];
    logic signed [23:0] adder7_stage3[142:0];
    logic signed [23:0] adder7_stage4[161:0];
    logic signed [23:0] adder7_stage5[171:0];
    logic signed [23:0] adder7_stage6[95:0];
    logic signed [23:0] adder7_stage7[47:0];
    logic signed [23:0] adder7_stage8[23:0];
    logic signed [23:0] adder7_stage9[11:0];
    logic signed [23:0] adder7_stage10[5:0];
    logic signed [23:0] adder7_stage11[2:0];
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
    
    
    always_ff @(posedge i_clk)
    begin
        adder1_stage1 <= mult_out;
        
        for (int i = 0; i < 45; i++)
            adder1_stage2[i+90] <= adder1_stage1[i*2] + adder1_stage1[i*2+1];
        adder1_stage2[89:0] <= mult_out;
        
        adder1_stage3[157] <= adder1_stage2[134];
        for (int i = 0; i < 67; i++)
            adder1_stage3[i+90] <= adder1_stage2[i*2] + adder1_stage2[i*2+1];
        adder1_stage3[89:0] <= mult_out;
        
        for (int i = 0; i < 79; i++)
            adder1_stage4[i+90] <= adder1_stage3[i*2] + adder1_stage3[i*2+1];
        adder1_stage4[89:0] <= mult_out;
        
        adder1_stage5[124] <= adder1_stage4[168];
        for (int i = 0; i < 84; i++)
            adder1_stage5[i+40] <= adder1_stage4[i*2] + adder1_stage4[i*2+1];
        adder1_stage5[39:0] <= mult_out[39:0];
        
        adder1_stage6[62] <= adder1_stage5[124];
        for (int i = 0; i < 62; i++)
            adder1_stage6[i] <= adder1_stage5[i*2] + adder1_stage5[i*2+1];
        
        adder1_stage7[31] <= adder1_stage6[62] + biases[bias_cnt];
        for (int i = 0; i < 31; i++)
            adder1_stage7[i] <= adder1_stage6[i*2] + adder1_stage6[i*2+1];
        
        for (int i = 0; i < 16; i++)
            adder1_stage8[i] <= adder1_stage7[i*2] + adder1_stage7[i*2+1];
        
        for (int i = 0; i < 8; i++)
            adder1_stage9[i] <= adder1_stage8[i*2] + adder1_stage8[i*2+1];
        
        for (int i = 0; i < 4; i++)
            adder1_stage10[i] <= adder1_stage9[i*2] + adder1_stage9[i*2+1];
        
        for (int i = 0; i < 2; i++)
            adder1_stage11[i] <= adder1_stage10[i*2] + adder1_stage10[i*2+1];
        
        adder1_result <= adder1_stage11[1] + adder1_stage11[0];
        
        adder2_stage1 <= mult_out[89:40];
        
        for (int i = 0; i < 25; i++)
            adder2_stage2[i+90] <= adder2_stage1[i*2] + adder2_stage1[1*2+1];
        adder2_stage2[89:0] <= mult_out;
        
        adder2_stage3[147] <= adder2_stage2[114];
        for (int i = 0; i < 57; i++)
            adder2_stage3[i+90] <= adder2_stage2[i*2] + adder2_stage2[i*2+1];
        adder2_stage3[89:0] <= mult_out;
        
        for (int i = 0; i < 74; i++)
            adder2_stage4[i+90] <= adder2_stage3[i*2] + adder2_stage3[i*2+1];
        adder2_stage4[89:0] <= mult_out;
        
        for (int i = 0; i < 82; i++)
            adder2_stage5[i+80] <= adder2_stage4[i*2] + adder2_stage4[i*2+1];
        adder2_stage5[79:0] <= mult_out[79:0];
        
        for (int i = 0; i < 81; i++)
            adder2_stage6[i] <= adder2_stage5[i*2] + adder2_stage5[i*2+1];
        
        adder2_stage7[41] <= adder2_stage6[80];
        for (int i = 0; i < 41; i++)
            adder2_stage7[i] <= adder2_stage6[i*2] + adder2_stage6[i*2+1];
        
        adder2_stage8[20] <= adder2_stage7[41];
        for (int i = 0; i < 20; i++)
            adder2_stage8[i] <= adder2_stage7[i*2] + adder2_stage7[i*2+1];
        
        adder2_stage9[10] <= adder2_stage8[20];
        for (int i = 0; i < 10; i++)
            adder2_stage9[i] <= adder2_stage8[i*2] + adder2_stage8[i*2+1];
        
        adder2_stage10[5] <= adder2_stage9[10] + biases[bias_cnt];
        for (int i = 0; i < 10; i++)
            adder2_stage10[i] <= adder2_stage9[i*2] + adder2_stage9[i*2+1];
        
        for (int i = 0; i < 3; i++)
            adder2_stage11[i] <= adder2_stage10[i*2] + adder2_stage10[i*2+1];
        
        for (int i = 0; i < 2; i++)
            adder2_stage12[i] <= adder2_stage11[i*2] + adder2_stage11[i*2+1];
        
        adder2_result <= adder2_stage12[1] + adder2_stage12[0];
        
        adder3_stage1 <= mult_out[89:80];
        
        for (int i = 0; i < 5; i++)
            adder3_stage2[i+90] <= adder3_stage1[i*2] + adder3_stage1[i*2+1];
        adder3_stage2[89:0] <= mult_out;
        
        adder3_stage3[137] <= adder3_stage2[94];
        for (int i = 0; i < 47; i++)
            adder3_stage3[i+90] <= adder3_stage2[i*2] + adder3_stage2[i*2+1];
        adder3_stage3[89:0] <= mult_out;
        
        for (int i = 0; i < 69; i++)
            adder3_stage4[i+90] <= adder3_stage3[i*2] + adder3_stage3[i*2+1];
        adder3_stage4[89:0] <= mult_out;
        
        adder3_stage5[169] <= adder3_stage4[158];
        for (int i = 0; i < 79; i++)
            adder3_stage5[i+90] <= adder3_stage4[i*2] + adder3_stage4[i*2+1];
        adder3_stage5[89:0] <= mult_out;
    
        for (int i = 0; i < 85; i++)
            adder3_stage6[i+30] <= adder3_stage5[i*2] + adder3_stage5[i*2+1];
        adder3_stage6[29:0] <= mult_out[29:0];
        
        adder3_stage7[57] <= adder3_stage6[114];
        for (int i = 0; i < 57; i++)
            adder3_stage7[i] <= adder3_stage6[i*2] + adder3_stage6[i*2+1];
        
        for (int i = 0; i < 29; i++)
            adder3_stage8[i] <= adder3_stage7[i*2] + adder3_stage7[i*2+1];
        
        adder3_stage9[14] <= adder3_stage8[28];
        for (int i = 0; i < 14; i++)
            adder3_stage9[i] <= adder3_stage8[i*2] + adder3_stage8[i*2+1];
        
        adder3_stage10[7] <= adder3_stage9[14] + biases[bias_cnt];
        for (int i = 0; i < 7; i++)
            adder3_stage10[i] <= adder3_stage9[i*2] + adder3_stage9[i*2+1];
        
        for (int i = 0; i < 4; i++)
            adder3_stage11[i] <= adder3_stage10[i*2] + adder3_stage10[i*2+1];
        
        for (int i = 0; i < 2; i++)
            adder3_stage12[i] <= adder3_stage11[i*2] + adder3_stage11[i*2+1];
        
        adder3_result <= adder3_stage12[1] + adder3_stage12[0];
        
        adder4_stage1[59:0] <= mult_out[89:30];
        
        for (int i = 0; i < 30; i++)
            adder4_stage2[i+90] <= adder4_stage1[i*2] + adder4_stage1[i*2+1];
        adder4_stage2[89:0] <= mult_out;
        
        for (int i = 0; i < 60; i++)
            adder4_stage3[i+90] <= adder4_stage2[i*2] + adder4_stage2[i*2+1];
        adder4_stage3[89:0] <= mult_out;
        
        for (int i = 0; i < 75; i++)
            adder4_stage4[i+90] <= adder4_stage3[i*2] + adder4_stage3[i*2+1];
        adder4_stage4[89:0] <= mult_out;
        
        adder4_stage5[152] <= adder4_stage4[164];
        for (int i = 0; i < 83; i++)
            adder4_stage5[i+70] <= adder4_stage4[i*2] + adder4_stage4[i*2+1];
        adder4_stage5[69:0] <= mult_out[69:0];
        
        adder4_stage6[76] <= adder4_stage5[152];
        for (int i = 0; i < 76; i++)
            adder4_stage6[i] <= adder4_stage5[i*2] + adder4_stage5[i*2+1];
        
        adder4_stage7[38] <= adder4_stage6[76];
        for (int i = 0; i < 38; i++)
            adder4_stage7[i] <= adder4_stage6[i*2] + adder4_stage6[i*2+1];
        
        adder4_stage8[19] <= adder4_stage7[38];
        for (int i = 0; i < 19; i++)
            adder4_stage8[i] <= adder4_stage7[i*2] + adder4_stage7[i*2+1];
        
        for (int i = 0; i < 10; i++)
            adder4_stage9[i] <= adder4_stage8[i*2] + adder4_stage8[i*2+1];
        
        for (int i = 0; i < 5; i++)
            adder4_stage10[i] <= adder4_stage9[i*2] + adder4_stage9[i*2+1];
        
        adder4_stage11[2] <= adder4_stage10[4] + biases[bias_cnt];
        for (int i = 0; i < 2; i++)
            adder4_stage11[i] <= adder4_stage10[i*2] + adder4_stage10[i*2+1];
        
        for (int i = 0; i < 2; i++)
            adder4_stage12[i] <= adder4_stage11[i*2] + adder4_stage11[i*2+1];
        
        adder4_result <= adder4_stage12[1] + adder4_stage12[0];       
        
        adder5_stage1[19:0] <= mult_out[89:70];
        
        for (int i = 0; i < 10; i++)
            adder5_stage2[i+90] <= adder5_stage1[i*2] + adder5_stage1[1*2+1];
        adder5_stage2[89:0] <= mult_out;
        
        for (int i = 0; i < 50; i++)
            adder5_stage3[i+90] <= adder5_stage2[i*2] + adder5_stage2[1*2+1];
        adder5_stage3[89:0] <= mult_out;
        
        for (int i = 0; i < 70; i++)
            adder5_stage4[i+90] <= adder5_stage3[i*2] + adder5_stage3[1*2+1];
        adder5_stage4[89:0] <= mult_out;
        
        for (int i = 0; i < 80; i++)
            adder5_stage5[i+90] <= adder5_stage4[i*2] + adder5_stage4[1*2+1];
        adder5_stage5[89:0] <= mult_out;
        
        for (int i = 0; i < 85; i++)
            adder5_stage6[i+20] <= adder5_stage5[i*2] + adder5_stage5[1*2+1];
        adder5_stage6[19:0] <= mult_out[19:0];
        
        adder5_stage7[52] <= adder5_stage6[104];
        for (int i = 0; i < 52; i++)
            adder5_stage7[i] <= adder5_stage6[i*2] + adder5_stage6[1*2+1];
        
        adder5_stage8[26] <= adder5_stage7[104];
        for (int i = 0; i < 26; i++)
            adder5_stage8[i] <= adder5_stage7[i*2] + adder5_stage7[1*2+1];
        
        adder5_stage9[13] <= adder5_stage8[104];
        for (int i = 0; i < 13; i++)
            adder5_stage9[i] <= adder5_stage8[i*2] + adder5_stage8[1*2+1];
        
        for (int i = 0; i < 7; i++)
            adder5_stage10[i] <= adder5_stage9[i*2] + adder5_stage9[1*2+1];
        
        adder5_stage11[3] <= adder5_stage10[6] + biases[bias_cnt];
        for (int i = 0; i < 3; i++)
            adder5_stage11[i] <= adder5_stage10[i*2] + adder5_stage10[1*2+1];
        
        for (int i = 0; i < 2; i++)
            adder5_stage12[i] <= adder5_stage11[i*2] + adder5_stage11[1*2+1];
            
        adder5_result <= adder5_stage12[1] + adder5_stage12[0];       
        
        adder6_stage1[69:0] <= mult_out[89:20];
        
        for (int i = 0; i < 35; i++)
            adder6_stage2[i+90] <= adder6_stage1[i*2] + adder6_stage1[i*2+1];
        adder6_stage2[89:0] <= mult_out;
        
        adder6_stage3[152] <= adder6_stage2[124];
        for (int i = 0; i < 62; i++)
            adder6_stage3[i+90] <= adder6_stage2[i*2] + adder6_stage2[i*2+1];
        adder6_stage3[89:0] <= mult_out;
        
        adder6_stage4[166] <= adder6_stage3[152];
        for (int i = 0; i < 62; i++)
            adder6_stage4[i+90] <= adder6_stage3[i*2] + adder6_stage3[i*2+1];
        adder6_stage4[89:0] <= mult_out;
        
        adder6_stage5[143] <= adder6_stage4[166];
        for (int i = 0; i < 83; i++)
            adder6_stage5[i+60] <= adder6_stage4[i*2] + adder6_stage4[i*2+1];
        adder6_stage5[59:0] <= mult_out[59:0];
        
        for (int i = 0; i < 72; i++)
            adder6_stage6[i] <= adder6_stage5[i*2] + adder6_stage5[i*2+1];
        
        for (int i = 0; i < 36; i++)
            adder6_stage7[i] <= adder6_stage6[i*2] + adder6_stage6[i*2+1];
        
        for (int i = 0; i < 18; i++)
            adder6_stage8[i] <= adder6_stage7[i*2] + adder6_stage7[i*2+1];
        
        for (int i = 0; i < 9; i++)
            adder6_stage9[i] <= adder6_stage8[i*2] + adder6_stage8[i*2+1];
        
        adder6_stage10[4] <= adder6_stage9[8];
        for (int i = 0; i < 4; i++)
            adder6_stage10[i] <= adder6_stage9[i*2] + adder6_stage9[i*2+1];
        
        adder6_stage11[2] <= adder6_stage10[4];
        for (int i = 0; i < 2; i++)
            adder6_stage11[i] <= adder6_stage10[i*2] + adder6_stage10[i*2+1];
        
        adder6_stage12[1] <= adder6_stage11[2] + biases[bias_cnt];
        adder6_stage12[0] <= adder6_stage11[1] + adder6_stage11[0];
        
        adder6_result <= adder6_stage12[1] + adder6_stage12[0];
        
        adder7_stage1[29:0] <= mult_out[89:60];
        
        for (int i = 0; i < 15; i++)
            adder7_stage2[i+90] <= adder7_stage1[i*2] + adder7_stage1[i*2+1];
        adder7_stage2[89:0] <= mult_out;
        
        adder7_stage3[142] <= adder7_stage2[104];
        for (int i = 0; i < 52; i++)
            adder7_stage3[i+90] <= adder7_stage2[i*2] + adder7_stage2[i*2+1];
        adder7_stage3[89:0] <= mult_out;
        
        adder7_stage4[161] <= adder7_stage3[142];
        for (int i = 0; i < 71; i++)
            adder7_stage4[i+90] <= adder7_stage3[i*2] + adder7_stage3[i*2+1];
        adder7_stage4[89:0] <= mult_out;
        
        for (int i = 0; i < 82; i++)
            adder7_stage5[i+90] <= adder7_stage4[i*2] + adder7_stage4[i*2+1];
        adder7_stage5[89:0] <= mult_out;
        
        for (int i = 0; i < 86; i++)
            adder7_stage6[i+10] <= adder7_stage5[i*2] + adder7_stage5[i*2+1];
        adder7_stage6[9:0] <= mult_out[9:0];
        
        for (int i = 0; i < 48; i++)
            adder7_stage7[i] <= adder7_stage6[i*2] + adder7_stage6[i*2+1];
        
        for (int i = 0; i < 24; i++)
            adder7_stage8[i] <= adder7_stage7[i*2] + adder7_stage7[i*2+1];
        
        for (int i = 0; i < 12; i++)
            adder7_stage9[i] <= adder7_stage8[i*2] + adder7_stage8[i*2+1];
        
        for (int i = 0; i < 6; i++)
            adder7_stage10[i] <= adder7_stage9[i*2] + adder7_stage9[i*2+1];
        
        for (int i = 0; i < 3; i++)
            adder7_stage11[i] <= adder7_stage10[i*2] + adder7_stage10[i*2+1];
        
        adder7_stage12[1] <= adder7_stage11[2] + biases[bias_cnt];
        adder7_stage12[0] <= adder7_stage11[1] + adder7_stage11[0];
        
        adder7_result <= adder7_stage12[1] + adder7_stage12[0];
        
        adder8_stage1 <= mult_out[89:10];
        
        for (int i = 0; i < 40; i++)
            adder8_stage2[i+90] <= adder8_stage1[i*2] + adder8_stage1[i*2+1];
        adder8_stage2[89:0] <= mult_out;
        
        for (int i = 0; i < 65; i++)
            adder8_stage3[i+90] <= adder8_stage2[i*2] + adder8_stage2[i*2+1];
        adder8_stage3[89:0] <= mult_out;
        
        adder8_stage4[167] <= adder8_stage3[154];
        for (int i = 0; i < 77; i++)
            adder8_stage4[i+90] <= adder8_stage3[i*2] + adder8_stage3[i*2+1];
        adder8_stage4[89:0] <= mult_out;
        
        for (int i = 0; i < 84; i++)
            adder8_stage5[i+50] <= adder8_stage4[i*2] + adder8_stage4[i*2+1];
        adder8_stage5[49:0] <= mult_out[49:0];
        
        for (int i = 0; i < 67; i++)
            adder8_stage6[i] <= adder8_stage5[i*2] + adder8_stage5[i*2+1];
        
        adder8_stage7[33] <= adder8_stage6[66];
        for (int i = 0; i < 33; i++)
            adder8_stage7[i] <= adder8_stage6[i*2] + adder8_stage6[i*2+1];
        
        for (int i = 0; i < 17; i++)
            adder8_stage8[i] <= adder8_stage7[i*2] + adder8_stage7[i*2+1];
        
        adder8_stage9[8] <= adder8_stage8[16];
        for (int i = 0; i < 8; i++)
            adder8_stage9[i] <= adder8_stage8[i*2] + adder8_stage8[i*2+1];
        
        adder8_stage10[4] <= adder8_stage9[8];
        for (int i = 0; i < 4; i++)
            adder8_stage10[i] <= adder8_stage9[i*2] + adder8_stage9[i*2+1];
        
        adder8_stage11[2] <= adder8_stage10[4];
        for (int i = 0; i < 2; i++)
            adder8_stage11[i] <= adder8_stage10[i*2] + adder8_stage10[i*2+1];
        
        adder8_stage12[1] <= adder8_stage11[2] + biases[bias_cnt];
        adder8_stage12[0] <= adder8_stage11[1] + adder8_stage11[0];
        
        adder8_result <= adder8_stage12[1] + adder8_stage12[0];
        
        adder9_stage1 <= mult_out[89:50];
        
        for (int i = 0; i < 20; i++)
            adder9_stage2[i+90] <= adder9_stage1[i*2] + adder9_stage1[i*2+1];
        adder9_stage2[89:0] <= mult_out;
        
        for (int i = 0; i < 55; i++)
            adder9_stage3[i+90] <= adder9_stage2[i*2] + adder9_stage2[i*2+1];
        adder9_stage3[89:0] <= mult_out;
        
        adder9_stage4[162] <= adder9_stage3[144];
        for (int i = 0; i < 72; i++)
            adder9_stage4[i+90] <= adder9_stage3[i*2] + adder9_stage3[i*2+1];
        adder9_stage4[89:0] <= mult_out;
        
        adder9_stage5[171] <= adder9_stage4[162];
        for (int i = 0; i < 81; i++)
            adder9_stage5[i+90] <= adder9_stage4[i*2] + adder9_stage4[i*2+1];
        adder9_stage5[89:0] <= mult_out;
        
        for (int i = 0; i < 86; i++)
            adder9_stage6[i] <= adder9_stage5[i*2] + adder9_stage5[i*2+1];
        
        for (int i = 0; i < 43; i++)
            adder9_stage7[i] <= adder9_stage6[i*2] + adder9_stage6[i*2+1];
        
        adder9_stage8[21] <= adder9_stage7[42];
        for (int i = 0; i < 21; i++)
            adder9_stage8[i] <= adder9_stage7[i*2] + adder9_stage7[i*2+1];
        
        for (int i = 0; i < 11; i++)
            adder9_stage9[i] <= adder9_stage8[i*2] + adder9_stage8[i*2+1];
        
        adder9_stage10[5] <= adder9_stage9[10];
        for (int i = 0; i < 5; i++)
            adder9_stage10[i] <= adder9_stage9[i*2] + adder9_stage9[i*2+1];
        
        for (int i = 0; i < 3; i++)
            adder9_stage11[i] <= adder9_stage10[i*2] + adder9_stage10[i*2+1];
                
        adder9_stage12[1] <= adder9_stage11[2] + biases[bias_cnt];
        adder9_stage12[0] <= adder9_stage11[1] + adder9_stage11[0];
        adder9_result <= adder9_stage12[1] + adder9_stage12[0];
        
    end
    
endmodule