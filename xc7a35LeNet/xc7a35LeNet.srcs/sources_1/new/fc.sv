`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
fc_tri_structure_adder_tree
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
    
    state 1:  [0-29],  [30-59],  [60-89]     State 1: d0->s0, d1->s1, d2->s2
    state 2:  [0-29],  [30-59], [90-119]     State 2: d0->s0, d1->s1, d2->s3
    state 3: [60-89], [90-119],   [0-29]     State 3: d0->s0, d1->s2, d2->s3
    state 4: [30-59],  [60-89], [90-119]     State 4: d0->s1, d1->s2, d2->s3
    
    Theory of operation: MACC 84 downstream neurons serially, 3 neurons valid every 4 cycles
    1) Buffer 120 neurons in parallel (almost - first 30 on cycle 1, last 90 on cycle 2)
    2) register 90 neurons into DSP48E1 A1 reg each cycle, in the 3-neuron 4-state pattern
    3) store valid Preg results into 90x8-bit pre-adder tree buffer. When there is 120 valid
        Preg results for an associated downstream neuron accumulate, pass them through the
         first stage combinatorial logic of the adder tree.
    3) When the final stage of the adder tree is valid, set the output feature to the result
        and pulse output valid
    
*/

//////////////////////////////////////////////////////////////////////////////////

module fc (
    input  logic       i_clk,
    input  logic       i_rst,
    input  logic       i_feature_valid,
    input  logic [7:0] i_features[0:119],
    output logic       o_neuron_valid,
    output logic [7:0] o_neuron,
    
    input logic  [7:0] weights[0:89]
);

    localparam NUM_FEATURES = 120;
    localparam NUM_NEURONS  = 84;
    localparam NUM_DSP      = 90;
    
    // Weights
    // localparam string WEIGHTS_FILE = "weights.mem";
    // logic signed [7:0] weights[0:NUM_FEATURES-1][0:NUM_NEURONS-1];
    // initial $readmemb(WEIGHTS_FILE, weights);
    
    // Biases
    localparam string BIASES_FILE  = "biases.mem";
    logic signed [7:0] biases[0:NUM_FEATURES-1];
    initial $readmemb(BIASES_FILE, biases);
    
    logic              macc_en;
 
    logic              first_upstream_neurons_latch;
    logic signed [7:0] upstream_neurons[0:NUM_FEATURES-1];
    
    // TODO: Should operands be 3x30 to match DSP pipeline unpacked dimensions?
    logic signed [7:0] feature_operands[0:89];
    logic signed [7:0] weight_operands[0:89];
    logic signed [7:0] A1reg[0:2][0:(NUM_DSP/3)-1];
    logic signed [7:0] B1reg[0:2][0:(NUM_DSP/3)-1];
    logic signed [7:0] A2reg[0:2][0:(NUM_DSP/3)-1];
    logic signed [7:0] B2reg[0:2][0:(NUM_DSP/3)-1];
    logic signed [7:0]  Mreg[0:2][0:(NUM_DSP/3)-1];
    logic signed [7:0]  Preg[0:2][0:(NUM_DSP/3)-1];
    
    logic signed [7:0] pre_adder_tree_buffer[0:89];
    
    logic        [5:0] adder_result_valid;
    logic signed [7:0] adder_stage1[0:59];
    logic signed [7:0] adder_stage2[0:29];
    logic signed [7:0] adder_stage3[0:14];
    logic signed [7:0] adder_stage4[0:7];
    logic signed [7:0] adder_stage5[0:3];
    logic signed [7:0] adder_stage6[0:1];
    logic signed [7:0] adder_result;
    
    // Control counters
    // logic          [$clog2(112)-1:0] cycle_cnt;
    logic [$clog2(NUM_FEATURES)-1:0] feature_ctr;
    logic  [$clog2(NUM_NEURONS)-1:0] neuron_ctr;
    
    typedef enum logic [1:0] {
        FC_ONE, FC_TWO, FC_THREE, FC_FOUR
    } state_t;
    state_t state;
    
    always_ff @(posedge i_clk) begin
        if (i_feature_valid) begin
            if (first_upstream_neurons_latch) begin
                for (int i = 0; i < 30; i++) begin
                    upstream_neurons[i] <= i_features[i];
                end
                first_upstream_neurons_latch <= 0;
            end else begin
                for (int i = 30; i < 120; i++) begin
                    upstream_neurons[i] <= i_features[i];
                end
                macc_en <= 1;
            end
        end
    end
    
    always_ff @(posedge i_clk) begin
        if (~macc_en) begin
            state            <= FC_ONE;
            feature_operands <= '{default: 0};
        end else
            case(state)
                FC_ONE: begin
                    state <= FC_TWO;
                    for (int i = 0; i < 30; i++) begin
                        feature_operands[i   ] <= upstream_neurons[i   ]; // d0->s0
                        feature_operands[i+30] <= upstream_neurons[i+30]; // d1->s1
                        feature_operands[i+60] <= upstream_neurons[i+90]; // d2->s3
                    end
                end
                FC_TWO: begin
                    state <= FC_THREE;
                    for (int i = 0; i < 30; i++) begin
                        feature_operands[i   ] <= upstream_neurons[i   ]; // d0->s0
                        feature_operands[i+30] <= upstream_neurons[i+60]; // d1->s2
                        feature_operands[i+60] <= upstream_neurons[i+90]; // d2->s3
                    end
                end
                FC_THREE: begin
                    state <= FC_FOUR;
                    for (int i = 0; i < 30; i++) begin
                        feature_operands[i   ] <= upstream_neurons[i+30]; // d0->s1
                        feature_operands[i+30] <= upstream_neurons[i+60]; // d1->s2
                        feature_operands[i+60] <= upstream_neurons[i+90]; // d2->s3
                    end
                end
                FC_FOUR: begin
                    state <= FC_ONE;
                    for (int i = 0; i < 30; i++) begin
                        feature_operands[i   ] <= upstream_neurons[i   ]; // d0->s0
                        feature_operands[i+30] <= upstream_neurons[i+30]; // d1->s1
                        feature_operands[i+60] <= upstream_neurons[i+60]; // d2->s2
                    end
                end
            endcase
    
    always_ff @(posedge i_clk)
        weight_operands <= weights;
    
    always_ff @(posedge i_clk) begin
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 30; j++) begin
                A1reg[i][j] <= feature_operands[(i*30)+j];
                B1reg[i][j] <= weight_operands[(i*30)+j];
                A2reg[i][j] <= A1reg;
                B2reg[i][j] <= B1reg;
                Mreg [i][j] <= A2reg * B2reg;
                Preg [i][j] <= Mreg;
            end
        end
    end
    
    /*
        ADDER TREE MAPPING
        tree[0:29]    <= buffer[0:29]
        tree[30:59]   <= buffer[30:59], Preg[0:29]
        tree[60:89]   <= buffer[60:89], Preg[30:59]
        tree[90:119]  <= Preg[60:89]
        buffer[0:29]  <= Preg[0:29]
        buffer[30:59] <= Preg[30:59]
        buffer[60:89] <= Preg[60:89]
        
        1)
        90 Preg results into pre-adder buffer
            buffer[ 0:89] <= Preg[ 0:89]
        
        2)
        60 Preg results into pre-adder buffer
        30 Preg results into adder tree
        90 pre-adder buffer values into adder tree
           tree[0:89] <= buffer[0:89]
           tree[90:119] <= Preg[60:89]
           buffer[0:59] <= Preg[0:59]
        
        3)
        30 Preg results into pre-adder buffer
        60 Preg results into adder tree
        60 pre-adder buffer values into adder tree
            tree[0:59] <= buffer[0:59]
            tree[60:119] <= Preg[30:89]
            buffer[0:29] <= Preg[0:29]
        
        4)
        90 Preg results into adder tree
        30 pre-adder buffer values into adder tree
            tree[0:29] <= buffer[0:29]
            tree[30:59] <= Preg[0:29]
            tree[60:89] <= Preg[30:59]
            tree[90:119] <= Preg[60:89]
    */
    
    always_ff @(posedge i_clk) begin
        // TODO: half of inputs come from Preg, half come from pre-adder buffer
        for (int i = 0; i < 60; i++)
            adder_stage1[i] <= 0;
        
        for (int i = 0; i < 30; i++)
            adder_stage2[i] <= adder_stage1[i*2] + adder_stage1[i*2+1];
        
        for (int i = 0; i < 15; i++)
            adder_stage3[i] <= adder_stage2[i*2] + adder_stage2[i*2+1];
        
        adder_stage4[7] <= adder1_stage3[14];
        for (int i = 0; i < 7; i++)
            adder_stage4[i] <= adder_stage3[i*2] + adder_stage3[i*2+1];
            
        for (int i = 0; i < 4; i++)
            adder_stage5[i] <= adder_stage4[i*2] + adder_stage4[i*2+1];
        
        for (int i = 0; i < 2; i++)
            adder_stage6[i] <= adder_stage5[i*2] + adder_stage5[i*2+1];
        
        adder1_result <= adder_stage6[0] + adder_stage6[1];
    end
    
    always_ff @(posedge i_clk) begin
        // TODO: Determine which states to shift in 1 on valid SR
        static state_t valid_states[3] = '{FC_ONE, FC_TWO, FC_THREE};
        for (int i = 0; i < 3; i++)
            adder_tree_valid_sr[i] <=
                {adder_tree_valid_sr[i][6:0],
                 macc_en ? state == valid_states[i]: 1'b0};
    end
    
endmodule