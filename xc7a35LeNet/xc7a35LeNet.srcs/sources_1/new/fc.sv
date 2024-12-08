`timescale 1ns / 1ps

module fc #(
    // defaults coorespond to first FC layer of LeNet-5
    parameter FEATURE_WIDTH    = 16,
    parameter NUM_FEATURES     = 16*5*5, // 400
    parameter NUM_NEURONS      = 120,
    // Could remove this count to save incremental resources
    // Keep it now for clarity
    parameter OUTPUT_DIMENSION = 84
)(
    input         i_clk,
    input         i_rst,
    input         i_feature_valid,
    input  [15:0] i_fefature,
    output        o_neuron_valid,
    // Needs to be parameterized
    output [FEATURE_WIDTH+WEIGHT_WIDTH+$clog2(NUM_FEATURES)-1:0] o_neuron
);

    localparam WEIGHT_WIDTH = 16;
    
    // Need to load in trained weights/biases
    // Time multiplexing of DSP48s?
    
    // Accumulate value for each neuron
    // Should we pass to next layer incrementally/serially to save memory?
    logic signed [FEATURE_WIDTH+WEIGHT_WIDTH+$clog2(NUM_FEATURES)-1:0] acc[NUM_NEURONS-1:0];
    
    // Control counters
    logic [$clog2(NUM_FEATURES)-1:0] feature_ctr;
    logic [$clog2(NUM_NEURONS)-1:0]  neuron_ctr;
    
    logic macc_done;
    
    typedef enum logic [1:0] {
        IDLE,
        MACC,
        SEND
    } state_t;
    state_t state, next_state;
    
    // Should check if its actually bad practice to use ternary operator for state transition
    always_ff @(posedge i_clk or nedegde i_rst) begin
        if (~i_rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always_comb begin
        case(state)
            IDLE: begin
                if (i_feature_valid)
                    next_state = MACC;
            end
            MACC: begin
                if (macc_done)
                    next_state = SEND;
            end
            SEND: begin
                next_state = IDLE;
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
        else if (state == MACC && i_feature_valid)
            acc[neuron_ctr] <= acc[neuron_ctr] + i_feature*[weight];
    end
            
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst)
            macc_done <= 1'b0;
        else
            macc_done <= (feature_ctr == NUM_FEATURES-1) && (neuron_ctr == NUM_NEURONS-1);
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            o_neuron_valid <= 1'b0;
            o_neuron       <=  'b0;
        end else begin
            o_neuron_valid <= 1'b0;
            if (state == SEND) begin
                o_neuron_valid <= 1'b1;
                o_neuron       <= acc + [bias];
            end
        end
    end
    
endmodule
