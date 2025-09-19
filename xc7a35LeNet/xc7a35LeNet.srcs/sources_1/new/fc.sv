`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Connections (# of * ops): 120 * 84 = 10080
    Trainable parameters = (120 + 1) * 84 = 10164
    @ 90 DSPs, 10164 / 90 = 112 clock cycles
    
    Adder trees: 120 operands, $clog2(120) = 7 clock cycles, layer latency = 119 clock cycles
    
    FSM has 4 states:
    DSP48E1 usage by state:         4 neuron groups     3 DSP groups, each DSP group gets mapped to 2 neuron groups
    State:      1,  2,  3,  4       s0 [ 0 -  29]       d0 -> [s0, s1]                                           
    Neuron n+1: 90, 30              s1 [30 -  59]       d1 -> [s1, s2]                                           
    Neuron n+2:     60, 60          s2 [60 -  89]       d2 -> [s2, s3]                                           
    Neuron n+3:         30, 90      s3 [90 - 119]       d2 -> [s2, s3]                                           
    
    state 1: [0-29], [30-59], [60-89]       State 1: d0->s0, d1->s1, d2->s2
    state 2: [0-29], [30-59], [90-119]      State 2: d0->s0, d1->s1, d2->s3
    state 3: [60-89], [90-119], [0-29]      State 3: d0->s0, d1->s2, d2->s3
    state 4: [30-59], [60-89], [90-119]     State 4: d0->s1, d1->s2, d2->s3
    
*/

//////////////////////////////////////////////////////////////////////////////////

module fc (
    input  logic        i_clk,
    input  logic        i_rst,
    input  logic        i_feature_valid,
    input  logic [15:0] i_feature,
    output logic        o_neuron_valid,
    output logic [15:0] o_neuron,
    
    input logic  [7:0] weights[0:89]
);

    localparam NUM_FEATURES = 120;
    localparam NUM_NEURONS  = 84;
    
    // Weights
    // localparam string WEIGHTS_FILE = "weights.mem";
    // logic signed [7:0] weights[0:NUM_FEATURES-1][0:NUM_NEURONS-1];
    // initial $readmemb(WEIGHTS_FILE, weights);
    
    // Biases
    localparam string BIASES_FILE  = "biases.mem";
    logic signed [7:0] biases[0:NUM_FEATURES-1];
    initial $readmemb(BIASES_FILE, biases);
    
    logic              macc_en;
    
    logic signed [7:0] upstream_neurons[0:NUM_FEATURES-1];
    
    logic [8:0] mult[0:2][0:29];
    
    logic [7:0] feature_operands[0:89];
    logic [7:0] weight_operands[0:89];
    
    // One-hot encoding adder tree valid SR
    logic [8:0] adder_result_valid[0:2];
    
    // Control counters
    // logic          [$clog2(112)-1:0] cycle_cnt;
    logic [$clog2(NUM_FEATURES)-1:0] feature_ctr;
    logic  [$clog2(NUM_NEURONS)-1:0] neuron_ctr;
    
    
    /*
    [1+2] 3
    
    */
    
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
    
    // 4 cycles to compute * operations for 3 neurons. 4 * 84/3 = 4 * 28 = 112 clock cycles.
    always_comb
        if (~is_processing) begin
            next_state = FC_ONE;
            feature_operands <= '{default: 0};
        end else
            case(state)
                FC_ONE: begin
                    next_state = FC_TWO;
                    for (int i = 0; i < 30; i++) begin
                        feature_operands[i   ] <= upstream_neurons[i   ]; // d0->s0
                        feature_operands[i+30] <= upstream_neurons[i+30]; // d1->s1
                        feature_operands[i+60] <= upstream_neurons[i+90]; // d2->s3
                    end
                end
                FC_TWO: begin
                    next_state = FC_THREE;
                    for (int i = 0; i < 30; i++) begin
                        feature_operands[i   ] <= upstream_neurons[i   ]; // d0->s0
                        feature_operands[i+30] <= upstream_neurons[i+60]; // d1->s2
                        feature_operands[i+60] <= upstream_neurons[i+90]; // d2->s3
                    end
                end
                FC_THREE: begin
                    next_state = FC_FOUR;
                    for (int i = 0; i < 30; i++) begin
                        feature_operands[i   ] <= upstream_neurons[i+30]; // d0->s1
                        feature_operands[i+30] <= upstream_neurons[i+60]; // d1->s2
                        feature_operands[i+60] <= upstream_neurons[i+90]; // d2->s3
                    end
                end
                FC_FOUR: begin
                    next_state = FC_ONE;
                    for (int i = 0; i < 30; i++) begin
                        feature_operands[i   ] <= upstream_neurons[i   ]; // d0->s0
                        feature_operands[i+30] <= upstream_neurons[i+30]; // d1->s1
                        feature_operands[i+60] <= upstream_neurons[i+60]; // d2->s2
                    end
                end
                // Not reachable
                default: next_state = FC_ONE;
            endcase
    
    always_ff @(posedge i_clk)
        weight_operands <= weights;
    
    always_ff @(posedge i_clk)
        for (int i = 0; i < 30; i++) begin
            mult[0][i   ] <= $signed(feature_operands[i   ]) * $signed(weight_operands[i   ]);
            mult[1][i+30] <= $signed(feature_operands[i+30]) * $signed(weight_operands[i+30]);
            mult[2][i+60] <= $signed(feature_operands[i+60]) * $signed(weight_operands[i+60]);
        end
    
    always_ff @(posedge i_clk)
        if (i_feature_valid) begin
            upstream_neurons[feature_ctr] <= i_feature;
            feature_ctr <= feature_ctr + 1;
            if (feature_ctr == NUM_FEATURES-2)
                is_processing <= 1;
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
    
        adder1_stage1[ 0:29] <= mult[ 0:29];
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
    
    always_ff @(posedge i_clk) begin
        // TODO: Determine which states to shift in 1 on valid SR
        static state_t valid_states[3] = '{FC_ONE, FC_TWO, FC_THREE};
        for (int i = 0; i < 3; i++)
            adder_tree_valid_sr[i] <=
                {adder_tree_valid_sr[i][6:0],
                 is_processing ? state == valid_states[i]: 1'b0};
    end
    
endmodule