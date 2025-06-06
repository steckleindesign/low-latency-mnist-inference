`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Connections (# of * ops): 120 * 84 = 10080
    
    Trainable parameters = (120 + 1) * 84 = 10164
    
    @ 90 DSPs, 10164 / 90 = 112 clock cycles
    
    Adder trees won't be so bad, 120 operands, $clog2(120) = 7 clock cycles,
    overall latency of layer should be within 120 clock cycles
    
    FSM has 4 states:
    DSP48E1 usage by state:
    State:      1,  2,  3,  4
    Neuron n+1: 90, 30
    Neuron n+2:     60, 60
    Neuron n+3:         30, 90
    
    4 neuron groups
    s0 [ 0 -  29]
    s1 [30 -  59]
    s2 [60 -  89]
    s3 [90 - 119]
    
    3 DSP groups, each DSP group is mapped to 2 neuron groups
    d0 -> [s0, s1]
    d1 -> [s1, s2]
    d2 -> [s2, s3]
    
    state 1: [0-29], [30-59], [60-89]
    state 2: [0-29], [30-59], [90-119]
    state 3: [60-89], [90-119], [0-29]
    state 4: [30-59], [60-89], [90-119]
    
    State 1: d0->s0, d1->s1, d2->s2
    State 2: d0->s0, d1->s1, d2->s3
    State 3: d0->s0, d1->s2, d2->s3
    State 4: d0->s1, d1->s2, d2->s3
    
    4 cycles to compute * operations for 3 neurons.
    4 * 84/3 = 4 * 28 = 112 clock cycles.
*/

//////////////////////////////////////////////////////////////////////////////////

module fc (
    input  logic        i_clk,
    input  logic        i_rst,
    input  logic        i_feature_valid,
    input  logic [15:0] i_feature,
    output logic        o_neuron_valid,
    output logic [15:0] o_neuron
);

    localparam string WEIGHTS_FILE = "weights.mem";
    localparam string BIASES_FILE  = "biases.mem";

    localparam NUM_FEATURES = 120;
    localparam NUM_NEURONS  = 84;
    
    // Initialize trainable parameters
    // Weights
    // (* rom_style = "block" *)
    logic signed [7:0] weights[0:NUM_FEATURES-1][0:NUM_NEURONS-1];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    // (* rom_style = "block" *)
    logic signed [7:0] biases[0:NUM_FEATURES-1];
    initial $readmemb(BIASES_FILE, biases);
    
    logic [8:0] upstream_neurons[0:NUM_FEATURES-1];
    
    // # ROMs = # DSPs = 90 | Width = 8 | ROM depth = cycles = 112
    logic [7:0] coefficients_rom[0:89][0:111];
    
    logic [8:0] mult[0:89];
    
    logic [7:0] feature_operands[0:89];
    logic [7:0] weight_operands[0:89];
    
    // One-hot encoding adder tree valid SR
    logic [8:0] adder_result_valid[0:2];
    
    logic [7:0] adder1_stage1[0:89];
    logic [7:0] adder1_stage2[0:74];
    logic [7:0] adder1_stage3[0:37];
    logic [7:0] adder1_stage4[0:18];
    logic [7:0] adder1_stage5[0:9];
    logic [7:0] adder1_stage6[0:4];
    logic [7:0] adder1_stage7[0:2];
    logic [7:0] adder1_stage8[0:1];
    logic [7:0] adder1_result;
    
    logic [7:0] adder2_stage1[0:59];
    logic [7:0] adder2_stage2[0:89];
    logic [7:0] adder2_stage3[0:44];
    logic [7:0] adder2_stage4[0:22];
    logic [7:0] adder2_stage5[0:11];
    logic [7:0] adder2_stage6[0:5];
    logic [7:0] adder2_stage7[0:2];
    logic [7:0] adder2_stage8[0:1];
    logic [7:0] adder2_result;
    
    logic [7:0] adder3_stage1[0:29];
    logic [7:0] adder3_stage2[0:104];
    logic [7:0] adder3_stage3[0:52];
    logic [7:0] adder3_stage4[0:26];
    logic [7:0] adder3_stage5[0:13];
    logic [7:0] adder3_stage6[0:6];
    logic [7:0] adder3_stage7[0:3];
    logic [7:0] adder3_stage8[0:1];
    logic [7:0] adder3_result;
    
    // Control counters
    logic          [$clog2(112)-1:0] cycle_cnt;
    logic [$clog2(NUM_FEATURES)-1:0] feature_ctr;
    logic [$clog2(NUM_NEURONS)-1:0]  neuron_ctr;
    
    logic is_processing;
    logic done;
    
    typedef enum logic [1:0] {
        FC_ONE,
        FC_TWO,
        FC_THREE,
        FC_FOUR
    } state_t;
    state_t state, next_state;
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst)
            state <= FC_ONE;
        else
            state <= next_state;
    end
    
    always_comb begin
        if (~is_processing) begin
            next_state = FC_ONE;
            feature_operands <= '{default: 0};
        end else
            case(state)
                FC_ONE: begin
                    next_state = FC_TWO;
                    feature_operands <= ;
                end
                FC_TWO: begin
                    next_state = FC_THREE;
                    feature_operands <= ;
                end
                FC_THREE: begin
                    next_state = FC_FOUR;
                    feature_operands <= ;
                end
                FC_FOUR: begin
                    next_state = FC_ONE;
                    feature_operands <= ;
                end
                default: next_state = FC_ONE;
            endcase
    end
    
    always_ff @(posedge i_clk) begin
        if (i_rst)
            cycle_cnt;
        else
            if (is_processing) begin
                for (int i = 0; i < 90; i++)
                    weight_operands[i] <= coefficients_rom[i][cycle_cnt];
                cycle_cnt <= cycle_cnt + 1;
            end
    end
    
    always_ff @(posedge i_clk)
        mult_out <= $signed(feature_operands) * $signed(weight_operands);
    
    always_ff @(posedge i_clk) begin
        if (i_feature_valid & |is_processing) begin
            upstream_neurons[feature_ctr] <= i_feature;
            feature_ctr <= feature_ctr + 1;
            if (feature_ctr == NUM_FEATURES-2)
                is_processing <= 1;
        end
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            feature_ctr = 'b0;
            neuron_ctr  = 'b0;
        end else begin
            feature_ctr <= feature_ctr + 1'b1;
            if (feature_ctr == NUM_FEATURES-1) begin
                neuron_ctr <= neuron_ctr + 1'b1;
                if (neuron_ctr == NUM_NEURONS-1)
                    neuron_ctr <= 'b0;
            end
        end
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst)
            acc = '{default: 0};
        else begin
            acc[neuron_ctr] <= biases[neuron_ctr][feature_ctr];
            if (state == MACC && i_feature_valid)
                acc[neuron_ctr] <= acc[neuron_ctr] + i_feature * weights[neuron_ctr][feature_ctr];
        end
    end
            
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst)
            done <= 1'b0;
        else
            done <= (feature_ctr == NUM_FEATURES-1) && (neuron_ctr == NUM_NEURONS-1);
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            o_neuron_valid <= 1'b0;
            o_neuron       <=  'b0;
        end else begin
            o_neuron_valid <= 1'b0;
            if (state == SEND) begin
                o_neuron_valid <= 1'b1;
                o_neuron       <= acc[neuron_ctr];
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
    
        adder1_stage1[0:29] <= mult[0:29];
        adder1_stage1[30:59] <= mult[30:59];
        adder1_stage1[60:89] <= mult[60:89];
        
        adder1_stage2[0:29] <= mult[60:89];
        for (int i = 0; i < 45; i++)
            adder1_stage2[i+30] <= adder1_stage1[i*2] + adder1_stage1[i*2+1];
        
        adder1_stage3[37] <= adder1_stage2[74];
        for (int i = 0; i < 37; i++)
            adder1_stage3[i] <= adder1_stage1[i*2] + adder1_stage1[i*2+1];
        
        for (int i = 0; i < 19; i++)
            adder1_stage4[i] <= adder1_stage3[i*2] + adder1_stage3[i*2+1];
        
        adder1_stage5[9] <= adder1_stage4[18];
        for (int i = 0; i < 9; i++)
            adder1_stage5[i] <= adder1_stage4[i*2] + adder1_stage4[i*2+1];
        
        for (int i = 0; i < 5; i++)
            adder1_stage6[i] <= adder1_stage5[i*2] + adder1_stage5[i*2+1];
        
        adder1_stage7[2] <= adder1_stage6[4];
        for (int i = 0; i < 2; i++)
            adder1_stage7[i] <= adder1_stage6[i*2] + adder1_stage6[i*2+1];
        
        adder1_stage8[1] <= adder1_stage7[2];
        adder1_stage8[0] <= adder1_stage7[0] + adder1_stage7[1];
        
        adder1_result <= adder1_stage8[0] + adder1_stage8[1];
        
        
        adder2_stage1[0:29] <= mult[0:29];
        adder2_stage1[30:59] <= mult[30:59];
        
        adder2_stage2[0:29] <= mult[30:59];
        adder2_stage2[30:59] <= mult[60:89];
        for (int i = 0; i < 30; i++)
            adder2_stage2[i+60] <= adder2_stage1[i*2] + adder2_stage1[i*2+1];
        
        for (int i = 0; i < 45; i++)
            adder2_stage3[i] <= adder2_stage2[i*2] + adder2_stage2[i*2+1];
        
        adder2_stage4[22] <= adder2_stage3[44];
        for (int i = 0; i < 22; i++)
            adder2_stage4[i] <= adder2_stage3[i*2] + adder2_stage3[i*2+1];
        
        adder2_stage5[11] <= adder2_stage4[22];
        for (int i = 0; i < 11; i++)
            adder2_stage5[i] <= adder2_stage4[i*2] + adder2_stage4[i*2+1];
            
        for (int i = 0; i < 6; i++)
            adder2_stage6[i] <= adder2_stage5[i*2] + adder2_stage5[i*2+1];
        
        for (int i = 0; i < 3; i++)
            adder2_stage7[i] <= adder2_stage6[i*2] + adder2_stage6[i*2+1];
        
        adder2_stage8[1] <= adder2_stage7[2];
        adder2_stage8[0] <= adder2_stage7[0] + adder2_stage7[1];
        
        adder2_result <= adder2_stage8[0] + adder2_stage8[1];
        
        
        adder3_stage1 <= mult[0:29];
        
        adder3_stage2[0:29] <= mult[0:29];
        adder3_stage2[30:59] <= mult[30:59];
        adder3_stage2[60:89] <= mult[60:89];
        for (int i = 0; i < 15; i++)
            adder3_stage2[i+90] <= adder3_stage1[i*2] + adder3_stage1[i*2+1];
        
        adder3_stage3[52] <= adder3_stage2[104];
        for (int i = 0; i < 52; i++)
            adder3_stage3[i] <= adder3_stage2[i*2] + adder3_stage2[i*2+1];
        
        adder3_stage4[26] <= adder3_stage3[52];
        for (int i = 0; i < 26; i++)
            adder3_stage4[i] <= adder3_stage3[i*2] + adder3_stage3[i*2+1];
        
        adder3_stage5[13] <= adder3_stage4[26];
        for (int i = 0; i < 13; i++)
            adder3_stage5[i] <= adder3_stage4[i*2] + adder3_stage4[i*2+1];
        
        for (int i = 0; i < 7; i++)
            adder3_stage6[i] <= adder3_stage5[i*2] + adder3_stage5[i*2+1];
        
        adder3_stage7[3] <= adder3_stage6[7];
        for (int i = 0; i < 3; i++)
            adder3_stage7[i] <= adder3_stage6[i*2] + adder3_stage6[i*2+1];
        
        adder3_stage8[1] <= adder3_stage7[2];
        adder3_stage8[0] <= adder3_stage7[0] + adder3_stage7[1];
        
        adder3_result <= adder3_stage8[0] + adder3_stage8[1];     
    
    end
    
endmodule
