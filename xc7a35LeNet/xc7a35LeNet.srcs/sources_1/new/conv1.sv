`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    TODO: Determine how to fit in the +bias operation
            -See if we can do it in DSP48 without hurting max clock frequency
            -See the max clock frequency penalty when implemented in fabric
          
          90 DSPS, 50 BRAMS (36Kb each)
          6 filters for conv1, 5x5 filter (25 * ops), 28x28 conv ops (784)
          = 6*(5*5)*(28*28) = 117600 * ops / 90 DSPs = 1306.6 = 1307 cycs theoretically
          
          Shift register functionality for 5x5 weight matrix should synthesize as array of SRLs
          
          At end of each row, we'll have to "tag in" complementary Shift register unit,
          because throughout the row, the shift register will shift horizontally, but
          at the end of each row, then shift register will need to shift down. So we will
          have to multiply our shift register resources by 2 until a better solution is found.
          
          Going to skip the last 2 columns (which are all 0's) so we can efficiently complete
          each row's * operations without a remainder of DSPs
          Will take us 46 clock cycles per row this way => (6*28*5*5 - 6*5*2) / 90 = 46
          Note that there are still improvements to be made, still many static 0's on
          the edges that we waste MACC (DSP) operations on
          
*/
//////////////////////////////////////////////////////////////////////////////////

module conv1 #(
    parameter string WEIGHTS_FILE = "weights.mem",
    parameter string BIASES_FILE  = "biases.mem",
    parameter        INPUT_WIDTH  = 32,
    parameter        INPUT_HEIGHT = 32,
    parameter        FILTER_SIZE  = 5,
    parameter        NUM_FILTERS  = 6
) (
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic               i_feature_valid,
    // For now we are just preloading pixels from RAM,
    // So i_feature will be reading from a full RAM of pixels,
    // No CDC needed, a new feature is available each clock cycle
    input  logic         [7:0] i_feature,
    output logic               o_feature_valid,
    output logic signed [15:0] o_feature,
    // Letting pixel RAM know we can't take in any data
    output logic               o_buffer_full
);

    // Need to determine how to share DSPs with RAMs,
    // Currently thinking 5 pixel RAMs (internal to conv1)
    // 18 DSPs * 5 RAMs = 90 DSPs
    // How to integrate this with shift register logic?

    // row cnt, col cnt range 2-30
    // outer 2 rings of 32x32 are all 0, and are stored in ram this way
    // so from first pixel input, we are fully ready for first convolution
    // we don't want to waste cycles on multiplying with 0s (whether 0 pixel/feature or outer rings)
    // ^ is it worth it to compare and skip features in single clock cycle to avoid *0 ?
    // The muxing implemented in fabric will probably take too much space, so will need to use DSP48 mux

    // Computed local params from module parameters
    localparam WINDOW_AREA   = FILTER_SIZE * FILTER_SIZE;
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

    // For height=5 filter, we only need to store 4 rows of pixel data
    // We could reduce latency if we get creative with the fill order of the LB
    
    // For now we will starting MACC operations once line buffer is full
    // Also we will use a line buffer with FILTER_SIZE rows, 5 rows in our case
    // Again, we are not using the last 2 columns in this iteration (all 0's so its viable)
    logic         [7:0] line_buffer[FILTER_SIZE-1:0][COL_END:0];

    // 1040 is best idea so far, maybe be able to improve by reducing the 2x's
    // Uses 2*ceil(FILTER_SIZE/32)*8 SRL32s, 2*5*8 = 80 SRL32s in out case
    // Currently don't use a shift register for the pixels/features
    // logic         [7:0] window_sr[FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    
    // Indexed window, weight value to be used for * operation
    logic         [7:0] feature_operands[4:0][2:0];
    // logic signed [15:0] weight_operand;
    
    // Line buffer counters
    logic [$clog2(ROW_END)-1:0] lb_row_ctr;
    logic [$clog2(COL_END)-1:0] lb_col_ctr;
    // Pixel window counters (generalize to feature)
    logic [$clog2(ROW_END)-1:0] feat_row_ctr;
    logic [$clog2(COL_END)-1:0] feat_col_ctr;
    // Do not need filter/MACC counter for this iteration
    // logic [$clog2(NUM_FILTERS)-1:0] filter_ctr;
    // logic [$clog2(WINDOW_AREA)-1:0] mac_ctr;
    
    // Line buffer full flag
    logic               lb_full;
    // Is it ok to go FSM-less and just use this MACC enable?
    logic               macc_en;
    // Keep track of row count direction, we zig zag rows (Do we actually gain any efficiency this way?)
    logic               row_cnt_direction;
    // Is 16-wide ok?
    logic signed [15:0] macc_accum;
    
    typedef enum logic [2:0] {
        ONE, TWO, THREE, FOUR, FIVE
    } state_t;
    state_t state, next_state;
    
    always_ff @(posedge i_clk) begin
        if (i_rst)
            state <= ONE;
        else
            state <= next_state;
    end
    
    // Maybe just use a counter here instead of a FSM
    always_comb begin
        if (macc_en || i_feature_valid) begin
            case(state)
                ONE:
                    next_state = TWO;
                TWO:
                    next_state = THREE;
                THREE:
                    next_state = FOUR;
                FOUR:
                    next_state = FIVE;
                FIVE:
                    next_state = ONE;
            endcase
        end
    end
    
    // Mapping feature operands
    always_comb begin
        case(state)
            ONE: begin
                feature_operands[0] = line_buffer[feat_col_ctr-2];
                feature_operands[1] = line_buffer[feat_col_ctr-1];
                feature_operands[2] = line_buffer[feat_col_ctr  ];
            end
            TWO: begin
                feature_operands[0] = line_buffer[feat_col_ctr+1];
                feature_operands[1] = line_buffer[feat_col_ctr+2];
                feature_operands[2] = line_buffer[feat_col_ctr-1];
            end
            THREE: begin
                feature_operands[0] = line_buffer[feat_col_ctr-1];
                feature_operands[1] = line_buffer[feat_col_ctr  ];
                feature_operands[2] = line_buffer[feat_col_ctr+1];
            end
            FOUR: begin
                feature_operands[0] = line_buffer[feat_col_ctr+2];
                feature_operands[1] = line_buffer[feat_col_ctr-1];
                feature_operands[2] = line_buffer[feat_col_ctr  ];
            end
            FIVE: begin
                feature_operands[0] = line_buffer[feat_col_ctr  ];
                feature_operands[1] = line_buffer[feat_col_ctr+1];
                feature_operands[2] = line_buffer[feat_col_ctr+2];
            end
        endcase
    end
    
    always_ff @(posedge i_clk) begin
        if (macc_en) begin
            case(state)
                ONE: begin
                    
                end
                TWO: begin
                    feat_col_ctr <= feat_col_ctr + 1;
                    
                end
                THREE: begin
                    
                    
                end
                FOUR: begin
                    feat_col_ctr <= feat_col_ctr + 1;
                    // At state 4, we need to check if we are at the end of the row
                    // and move down if so
                    
                end
                FIVE: begin
                    feat_col_ctr <= feat_col_ctr + 1;
                    
                end
            endcase
        end
    end
    
    always_ff @(posedge i_clk) begin
        // Active high sync reset
        if (i_rst)
            macc_en <= 0;
        else begin
            if (macc_en) begin
                
                lb_full <= lb_row_ctr == 3'd4 && lb_col_ctr == COL_END;
                
                if (feat_col_ctr == COL_END) begin
                    if (lb_row_ctr == ROW_END) begin
                        lb_col_ctr <= COL_START;
                        for (int i = 0; i < FILTER_SIZE-2; i++)
                            line_buffer[i] <= line_buffer[i+1];
                    end
                end else if (~lb_full) begin
                    line_buffer[lb_row_ctr][lb_col_ctr] <= i_feature;
                    if (lb_col_ctr == COL_END) begin
                        if (lb_row_ctr == 3'd4)
                            lb_full <= 1;
                        else begin
                            lb_col_ctr <= COL_START;
                            lb_row_ctr <= lb_row_ctr + 1;
                        end
                    end
                end
                                
                // Biases is first added to accumulate for efficiency
                // While we are in the MACC state, the weight*feature operations are added
                // mac_accum    <= biases[filter_ctr][row_ctr][col_ctr];
                
            end else begin
                if (i_feature_valid) begin
                    lb_row_ctr      <= ROW_START;
                    lb_col_ctr      <= COL_START;
                    feat_row_ctr    <= ROW_START;
                    feat_col_ctr    <= COL_START;
                    // filter_ctr      <= 0;
                    // mac_ctr         <= 0;
                    // Do we actually need to reset the line buffer to 0?
                    line_buffer     <= '{default: 0};
                    // mac_accum       <= 0; // biases[0][0][0];
                    macc_en         <= 1;
                    o_feature_valid <= 0;
                end
            end
        end
    end
    
    // How many features do we want to output in parallel?
    assign o_feature     = mac_accum;
    
    // o_feature_valid
    
    // implement
    assign o_buffer_full = lb_full;

endmodule