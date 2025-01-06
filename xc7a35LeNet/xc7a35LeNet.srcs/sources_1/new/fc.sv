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
    
*/

//////////////////////////////////////////////////////////////////////////////////

module fc (
    input               i_clk,
    input               i_rst,
    input               i_feature_valid,
    input        [15:0] i_feature,
    output              o_neuron_valid,
    output       [15:0] o_neuron
);

    localparam string WEIGHTS_FILE = "weights.mem";
    localparam string BIASES_FILE  = "biases.mem";

    localparam NUM_INPUT_FEATURES = 120;
    localparam NUM_NEURONS        = 84;
    
    // Initialize trainable parameters
    // Weights
    (* rom_style = "block" *) logic signed [15:0]
    weights [NUM_INPUT_FEATURES-1:0][NUM_NEURONS-1:0];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    (* rom_style = "block" *) logic signed [15:0]
    biases [NUM_INPUT_FEATURES-1:0];
    initial $readmemb(BIASES_FILE, biases);
    
    // Time multiplexing of DSP48s?
    
    // Accumulate value for each neuron
    // Should we pass to next layer incrementally/serially to save memory?
    logic signed [ACC_WIDTH-1:0] acc[NUM_NEURONS-1:0];
    
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
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always_comb begin
        case(state)
            IDLE: begin
                if (i_feature_valid) next_state = MACC;
            end
            MACC: begin
                if (macc_done) next_state = SEND;
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
        else begin
            acc[neuron_ctr] <= biases[neuron_ctr][feature_ctr];
            if (state == MACC && i_feature_valid)
                acc[neuron_ctr] <= acc[neuron_ctr] + i_feature * weights[neuron_ctr][feature_ctr];
        end
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
                o_neuron       <= acc[neuron_ctr];
            end
        end
    end
    
endmodule
