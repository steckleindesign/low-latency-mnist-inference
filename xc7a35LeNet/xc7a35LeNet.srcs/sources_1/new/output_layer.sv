`timescale 1ns / 1ps

module output_layer #(
    parameter string WEIGHTS_FILE = "weights.mem",
    parameter string BIASES_FILE  = "biases.mem",
    // Definitely need to overwrite feature width (depends on previous FC layer)
    parameter FEATURE_WIDTH       = 16,
    parameter NUM_FEATURES        = 84,
    parameter NUM_CLASSES         = 10
)(
    input               i_clk,
    input               i_rst,
    input               i_feature_valid,
    input        [15:0] i_feature,
    output logic        o_logits_valid,
    // Needs to be parameterized
    output        [3:0] o_logits
);

    // Are we sure about 16 bits for weights?
    localparam WEIGHT_WIDTH = 16;
    localparam ACC_WIDTH    = FEATURE_WIDTH+WEIGHT_WIDTH+$clog2(NUM_FEATURES);
    
    // Initialize trainable parameters
    // Weights
    (* rom_style = "block" *) logic signed [15:0]
    weights [NUM_CLASSES-1:0][NUM_FEATURES-1:0];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    (* rom_style = "block" *) logic signed [15:0]
    biases [NUM_CLASSES-1:0][NUM_FEATURES-1:0];
    initial $readmemb(BIASES_FILE, biases);
    
    logic signed [ACC_WIDTH-1:0] acc[NUM_CLASSES-1:0];
    
    // Control counters
    logic [$clog2(NUM_FEATURES)-1:0] feature_ctr;
    logic [$clog2(NUM_CLASSES)-1:0]  class_ctr;
    
    logic macc_done;
    
    logic [ACC_WIDTH-1:0] max_score;
    logic                 max_class;
    
    typedef enum logic [1:0] {
        IDLE,
        MACC,
        RESULT
    } state_t;
    state_t state, next_state;
    
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
                if (macc_done) next_state = RESULT;
            end
            RESULT: begin
                next_state = IDLE;
            end
            default: next_state = state;
        endcase
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            feature_ctr = 'b0;
            class_ctr  = 'b0;
        end else begin
            feature_ctr <= feature_ctr + 1'b1;
            if (feature_ctr == NUM_FEATURES-1) begin
                class_ctr <= class_ctr + 1'b1;
                if (class_ctr == NUM_CLASSES-1)
                    class_ctr <= 'b0;
            end
        end
    end
    
    // Add in bias
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst)
            acc = '{default: 0};
        else begin
            acc[class_ctr] <= biases[class_ctr][feature_ctr];
            if (state == MACC && i_feature_valid)
                acc[class_ctr] <= acc[class_ctr] + i_feature * weights[class_ctr][feature_ctr];
        end
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst)
            macc_done <= 1'b0;
        else
            macc_done <= state == MACC && (feature_ctr == NUM_FEATURES-1) && (class_ctr == NUM_CLASSES-1);
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            o_logits_valid <= 1'b0;
            max_score      <=  'b0;
            max_class      <= 4'b0;
        end else begin
            o_logits_valid <= 1'b0;
            if (state == RESULT) begin
                o_logits_valid <= 1'b1;
                max_score      <= acc[0];
                max_class      <= 4'b0;
                for (int i = 0; i < NUM_CLASSES; i++) begin
                    if (acc[i] > max_score) begin
                        max_score <= acc[i];
                        max_class <= i;
                    end
                end
            end
        end
    end
    
    assign o_logits = max_class;
    
endmodule
