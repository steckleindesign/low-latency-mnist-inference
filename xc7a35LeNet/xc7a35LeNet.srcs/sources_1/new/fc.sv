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
        case(state)
            FC_ONE: begin
                if (i_feature_valid | is_processing)
                    next_state = FC_TWO;
            end
            FC_TWO: begin
                next_state = FC_THREE;
            end
            FC_THREE: begin
                next_state = FC_FOUR;
            end
            FC_FOUR: begin
                next_state = FC_ONE;
            end
            default: next_state = state;
        endcase
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
    
endmodule
