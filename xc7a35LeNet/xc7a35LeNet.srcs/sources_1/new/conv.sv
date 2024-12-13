`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module conv #(
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
    input  logic         [7:0] i_feature,
    output logic               o_feature_valid,
    output logic signed [15:0] o_feature
);

    // Computed local params from module parameters
    localparam WINDOW_AREA   = FILTER_SIZE * FILTER_SIZE;
    localparam OUTPUT_HEIGHT = INPUT_HEIGHT - FILTER_SIZE + 1;
    localparam OUTPUT_WIDTH  = INPUT_WIDTH - FILTER_SIZE + 1;
    
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
    logic        [7:0] line_buffer[FILTER_SIZE-2:0][INPUT_WIDTH-1:0];
    
    // Window is pixel block to be element-wise multiplied with filter kernel (5x5 for conv1 of LeNet-5)
    logic        [7:0] window[FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    // Indexed window, weight value to be used for * operation
    logic        [7:0] window_value;
    // Weights are signed
    logic signed [7:0] weight_value;
    
    // control counters
    logic [$clog2(INPUT_HEIGHT)-1:0] row_ctr;
    logic [$clog2(INPUT_WIDTH)-1:0]  col_ctr;
    logic [$clog2(NUM_FILTERS)-1:0]  filter_ctr;
    logic [$clog2(WINDOW_AREA)-1:0]  mac_ctr;
        
    // MACC accumulate
    logic signed [15:0] mac_accum;
    
    typedef enum logic {
        IDLE, MACC
    } state;
    state next_state, curr_state;
    
    always_ff @(posedge i_clk or negedge i_rst)
        if (~i_rst)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    
    // Next state logic
    always_comb begin
        case (curr_state)
            IDLE:
                if (i_feature_valid) next_state <= MACC;
            MACC:
                // Do we want the "-1" on the counters?
                if (filter_ctr == NUM_FILTERS-1 &&
                    row_ctr == INPUT_HEIGHT-1 &&
                    col_ctr == INPUT_WIDTH-1)
                        next_state <= IDLE;
                        
            default: next_state <= IDLE;
        endcase
    end
        
    // Wasted resources having async resets and sync resets (in IDLE)?
    // Limit to sync reset?
    
    // Data Out is probably a wasted state
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            row_ctr    <='b0;
            col_ctr    <='b0;
            filter_ctr <='b0;
            mac_ctr    <='b0;
            mac_accum  <='b0;
        end else begin
            // Biases is first added to accumulate for efficiency
            // While we are in the MACC state, the weight*feature operations are added
            mac_accum    <= biases[filter_ctr][row_ctr][col_ctr];
            window_value <= window[mac_ctr/FILTER_SIZE][mac_ctr%FILTER_SIZE];
            // Need to simplify this! Maybe weights should also be a 2D SR
            weight_value <= weights[filter_ctr]
                                   [row_ctr - FILTER_SIZE/2 + mac_ctr/FILTER_SIZE]
                                   [col_ctr - FILTER_SIZE/2 + mac_ctr%FILTER_SIZE];
            case (curr_state)
                IDLE: begin
                    if (i_feature_valid) begin
                        row_ctr         <=  'b0;
                        col_ctr         <=  'b0;
                        filter_ctr      <=  'b0;
                        mac_ctr         <=  'b0;
                        window          <= '{default: 0};
                        line_buffer     <= '{default: 0};
                        mac_accum       <= biases[0][0][0];
                        o_feature_valid <= 1'b0;
                    end
                end
                MACC: begin
                    mac_ctr <= mac_ctr == WINDOW_AREA-1 ? 'b0 : mac_ctr + 1'b1;
                    o_feature_valid <= 1'b0;
                    mac_accum <= mac_accum + window_value * weight_value;
                    if (mac_ctr == WINDOW_AREA-1) begin
                        o_feature_valid <= 1'b1;
                        filter_ctr      <= filter_ctr == NUM_FILTERS-1 ? 'b0 : filter_ctr + 1'b1;
                    end
                end
            endcase
        end
    end
    
    always_ff @(posedge i_clk) begin
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
        
        // Line buffer
        for (int i = 0; i < FILTER_SIZE-2; i++)
            line_buffer[i][col_ctr] <= line_buffer[i+1][col_ctr];
        line_buffer[FILTER_SIZE-2][col_ctr]   <= i_feature;
        line_buffer[0][col_ctr-FILTER_SIZE+1] <= window[FILTER_SIZE-1][col_ctr-FILTER_SIZE+1];
        
        // Row/Column counters
        col_ctr <= col_ctr + 1'b1;
        if (col_ctr == INPUT_WIDTH-1) begin
            col_ctr <= 'b0;
            // Can always incr row cnt because it gets reset when
            // we fall back into the IDLE state of the main FSM
            row_ctr <= row_ctr + 1'b1;
        end
    end
    
    assign o_feature = mac_accum;

endmodule