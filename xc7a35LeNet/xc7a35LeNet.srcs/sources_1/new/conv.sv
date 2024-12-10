`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Need to account for number of cycles between pixel valid pulses (roughly 16 clk100m cycs)
*/
//////////////////////////////////////////////////////////////////////////////////

module conv #(
    parameter string WEIGHTS_FILE = "weights.mem",
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
    
    // Focus on how we want to load the weights in
    (* rom_style = "block" *) logic signed [7:0]
    filter_weights [NUM_FILTERS-1:0][OUTPUT_WIDTH-1:0][OUTPUT_HEIGHT-1:0];
    initial $readmemb(WEIGHTS_FILE, filter_weights);

    // For height=5 filter, we only need to store 4 rows of pixel data
    // We could reduce latency if we get creative with the fill order of the LB
    logic        [7:0] line_buffer[FILTER_SIZE-2:0][INPUT_WIDTH-1:0];
    
    // Window is pixel block to be element-wise multiplied with filter kernel (5x5 for conv1 of LeNet-5)
    logic signed [7:0] window[FILTER_SIZE-1:0][FILTER_SIZE-1:0];
    // Indexed window, weight value to be used for * operation
    logic signed [7:0] window_value, weight_value;
    
    // control counters
    logic [$clog2(INPUT_HEIGHT)-1:0] row_ctr;
    logic [$clog2(INPUT_WIDTH)-1:0]  col_ctr;
    logic [$clog2(NUM_FILTERS)-1:0]  filter_ctr;
    logic [$clog2(WINDOW_AREA)-1:0]  mac_ctr;
        
    // MACC accumulate
    logic signed mac_accum;
    
    typedef enum logic [1:0] {
        IDLE,
        LOAD_WINDOW,
        MACC,
        DATA_OUT
    } state;
    state next_state, curr_state;
    
    logic window_valid;
    logic mac_done;
    
    // Handle reset for FSM
    always_ff @(posedge i_clk or negedge i_rst)
        curr_state <= ~i_rst ? IDLE : next_state;
    
    // Next state logic
    always_comb begin
        case (curr_state)
            IDLE: begin
                next_state <= i_feature_valid ? LOAD_WINDOW : IDLE;
            end
            LOAD_WINDOW: begin
                next_state <= window_valid ? MACC : LOAD_WINDOW;
            end
            MACC: begin
                next_state <= mac_done ? DATA_OUT : MACC;
            end
            DATA_OUT: begin
                if (filter_ctr == NUM_FILTERS-1)
                    next_state <= (row_ctr == INPUT_HEIGHT-1 & col_ctr == INPUT_WIDTH-1) ? IDLE : LOAD_WINDOW;
                else
                    next_state <= MACC;
            end
            default: next_state <= IDLE;
        endcase
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            row_ctr    <='b0;
            col_ctr    <='b0;
            filter_ctr <='b0;
            mac_ctr    <='b0;
            mac_accum  <='b0;
        end else begin
            case (curr_state)
                IDLE: begin
                    if (i_feature_valid) begin
                        row_ctr         <=  'b0;
                        col_ctr         <=  'b0;
                        filter_ctr      <=  'b0;
                        mac_ctr         <=  'b0;
                        mac_accum       <=  'b0;
                        o_feature_valid <= 1'b0;
                    end
                end
                // LOAD_WINDOW: Window is loaded with data from buffers...
                MACC: begin
                    mac_ctr <= mac_ctr + 1'b1;
                    if (mac_ctr == WINDOW_AREA-1) begin
                        mac_ctr   <= 'b0;
                        mac_accum <= 'b0;
                    end
                end
                DATA_OUT: begin
                    o_feature_valid <= 1'b1;
                    o_feature       <= mac_accum;
                    filter_ctr      <= filter_ctr == NUM_FILTERS-1 ? 'b0 : filter_ctr + 1'b1;
                end
            endcase
        end
    end
    
    /*
        colummn counter counts from 0 to INPUT_WIDTH-1
        row counter counts from 0 to INPUT_WIDTH-1
        TODO: Can optimize this later, may only need to cnt from 0 to OUTPUT SIZE
    */
    
    always_ff @(posedge i_clk) begin
        if (i_feature_valid) begin
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
    end
    
    // MACC operation (DSP48E1)
    always_ff @(posedge i_clk) begin
        window_value <= window[mac_ctr/FILTER_SIZE][mac_ctr%FILTER_SIZE];
        // Need to simplify this!
        weight_value <= filter_weights[filter_ctr][row_ctr - FILTER_SIZE/2 + mac_ctr/FILTER_SIZE][col_ctr - FILTER_SIZE/2 + mac_ctr%FILTER_SIZE];
        if (curr_state == MACC)
            mac_accum <= mac_accum + window_value * weight_value;
    end
    
    // review synthesis to check if logical AND results in different RTL circuit
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            window_valid    <= 1'b0;
            o_feature_valid <= 1'b0;
            mac_done        <= 1'b0;
        end else begin
            // How wide should each valid signal be?
            window_valid    <= i_feature_valid ? (col_ctr >= FILTER_SIZE-1 & row_ctr >= FILTER_SIZE-1) : window_valid;
            o_feature_valid <= curr_state == DATA_OUT;
            mac_done        <= curr_state == MACC & mac_ctr == WINDOW_AREA-1;
        end
    end

endmodule
