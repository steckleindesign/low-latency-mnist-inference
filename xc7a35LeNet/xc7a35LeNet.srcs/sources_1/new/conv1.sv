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
    (* rom_style = "block" *) logic signed [7:0]
    weights [NUM_FILTERS-1:0][OUTPUT_WIDTH-1:0][OUTPUT_HEIGHT-1:0];
    initial $readmemb(WEIGHTS_FILE, weights);
    // Biases
    (* rom_style = "block" *) logic signed [7:0]
    biases [NUM_FILTERS-1:0][OUTPUT_WIDTH-1:0][OUTPUT_HEIGHT-1:0];
    initial $readmemb(BIASES_FILE, biases);

    // For height=5 filter, we only need to store 4 rows of pixel data
    // We could reduce latency if we get creative with the fill order of the LB
    // For now we will starting MACC operations once line buffer is full
    logic         [7:0] line_buffer[FILTER_SIZE-2:0][INPUT_WIDTH-1:0];

    // 1040 is best idea so far, maybe be able to improve by reducing the 2x's
    // Uses 2*ceil(FILTER_SIZE/32)*8 SRL32s, 2*5*8 = 80 SRL32s in out case
    logic         [7:0] window[FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    // Uses 2*NUM_FILTERS*ceil(FILTER_SIZE/32)*16 SRL32s, 2*6*5*16 = 960 SRL32s in out case
    logic signed [16:0] weight_window[NUM_FILTERS-1:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    
    // Indexed window, weight value to be used for * operation
    logic        [7:0] window_value;
    logic signed [7:0] weight_value;
    
    logic [$clog2(ROW_END)-1:0]     row_ctr;
    logic [$clog2(COL_END)-1:0]     col_ctr;
    logic [$clog2(NUM_FILTERS)-1:0] filter_ctr;
    logic [$clog2(WINDOW_AREA)-1:0] mac_ctr;
    
    // Is it ok to go FSM-less and just use this MACC enable?
    logic        macc_en;
    
    logic        row_ctr_dir;
        
    logic signed [15:0] mac_accum;
    
    always_ff @(posedge i_clk) begin
        // Sync reset
        if (~i_rst)
            macc_en <= 0;
        else begin
            if (macc_en) begin
                // Generate window by shifting right by 1
                for (int i = 0; i < FILTER_SIZE; i++)
                    for (int j = 0; j < FILTER_SIZE-1; j++)
                        window[i][j] <= window[i][j+1];
                
                // Last column of pixel window assigned values from equivalent column of line buffer
                // Check synthesis here, is there simply FILTER_SIZE-1 SRLs?
                for (int i = 0; i < FILTER_SIZE-1; i++)
                    window[i][FILTER_SIZE-1] <= line_buffer[i][col_ctr];
                
                // The bottom right corner of the pixel window, will take the incoming pixel as its value
                window[FILTER_SIZE-1][FILTER_SIZE-1] <= i_feature;
                
                for (int i = 0; i < FILTER_SIZE-2; i++)
                    line_buffer[i][col_ctr] <= line_buffer[i+1][col_ctr];
                line_buffer[FILTER_SIZE-2][col_ctr]   <= i_feature;
                line_buffer[0][col_ctr-FILTER_SIZE+1] <= window[FILTER_SIZE-1][col_ctr-FILTER_SIZE+1];
                
                window_value <= window[mac_ctr/FILTER_SIZE][mac_ctr%FILTER_SIZE];
                // Need to simplify this! Maybe weights should also be a 2D SR
                // Study BRAMS/SRLs to see how to go about this
                weight_value <= weights[filter_ctr]
                                       [row_ctr - FILTER_SIZE/2 + mac_ctr/FILTER_SIZE]
                                       [col_ctr - FILTER_SIZE/2 + mac_ctr%FILTER_SIZE];
                
                mac_accum <= mac_accum + window_value * weight_value;
                
                col_ctr <= col_ctr + 1;
                if (col_ctr == COL_END) begin
                    col_ctr <= 0;
                    row_ctr <= row_ctr + 1;
                end
                
                mac_ctr <= mac_ctr == WINDOW_AREA-1 ? 0 : mac_ctr + 1;
                
                o_feature_valid <= 0;
                if (mac_ctr == WINDOW_AREA-1) begin
                    o_feature_valid <= 1;
                    filter_ctr      <= filter_ctr == NUM_FILTERS-1 ? 0 : filter_ctr + 1;
                end
                
                // Biases is first added to accumulate for efficiency
                // While we are in the MACC state, the weight*feature operations are added
                // mac_accum    <= biases[filter_ctr][row_ctr][col_ctr];
                
            end else begin
                if (i_feature_valid) begin
                    row_ctr         <= ROW_START;
                    col_ctr         <= COL_START;
                    filter_ctr      <= 0;
                    mac_ctr         <= 0;
                    // Do we actually need to reset the feature/weight buffers to 0?
                    window          <= '{default: 0};
                    line_buffer     <= '{default: 0};
                    mac_accum       <= 0; // biases[0][0][0];
                    macc_en         <= 1;
                    o_feature_valid <= 0;
                end
            end
        end
    end
    
    // How many features do we want to output in parallel?
    assign o_feature     = mac_accum;
    
    // implement
    assign o_buffer_full = 0;

endmodule