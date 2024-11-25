`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module conv1 #(
    parameter IMAGE_WIDTH  = 32,
    parameter IMAGE_HEIGHT = 32,
    parameter FILTER_SIZE  = 5,
    parameter NUM_FILTERS  = 6
) (
    input  logic               i_clk,
    input  logic               i_ready,
    input  logic         [7:0] i_pixel, // i_image[IMAGE_HEIGHT-1:0][IMAGE_WIDTH-1:0],
    // How do we want to load in pixel data? Probably RAM in another module
    input  logic signed  [7:0] i_filters, // i_filters[NUM_FILTERS-1:0][FILTER_SIZE-1:0][FILTER_SIZE-1:0],
    // 6x28x28 output to first max pool layer
    // How can we go about a sequential output now that we have serial pixel data coming in?
    output logic signed [15:0] o_feature, // o_feature_map[NUM_FILTERS-1:0][IMAGE_HEIGHT-FILTER_SIZE:0][IMAGE_WIDTH-FILTER_SIZE:0],
    output logic               o_feature_valid
);
    
    // Focus on how we want to load the weights in
    logic signed [7:0] filter_weights[NUM_FILTERS-1:0][FILTER_SIZE*FILTER_SIZE-1];

    localparam WINDOW_AREA   = FILTER_SIZE * FILTER_SIZE;
    localparam OUTPUT_HEIGHT = IMAGE_HEIGHT - FILTER_SIZE + 1;
    localparam OUTPUT_WIDTH  = IMAGE_WIDTH - FILTER_SIZE + 1;

    // For height=5 filter, we only need to store 4 rows of pixel data
    // We could reduce latency if we get creative with the fill order of the LB
    logic [7:0] line_buffer[FILTER_SIZE-2:0][IMAGE_WIDTH-1:0];
    
    logic [7:0] window[FILTER_SIZE-1][FILTER_SIZE-1];
    
    // control counters
    logic [$clog2(IMAGE_HEIGHT)-1:0] row_ctr;
    logic [$clog2(IMAGE_WIDTH)-1:0]  col_ctr;
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
    
    logic pixel_valid;
    logic window_valid;
    logic mac_done;
    
    // Can add a reset later
    always_ff @(posedge i_clk)
        curr_state <= next_state;
    
    // Next state logic
    always_comb begin
        case (curr_state)
            IDLE: begin
                next_state = pixel_valid ? LOAD_WINDOW : IDLE;
            end
            LOAD_WINDOW: begin
                next_state = window_valid ? MACC : LOAD_WINDOW;
            end
            MACC: begin
                next_state = mac_done ? DATA_OUT : MACC;
            end
            DATA_OUT: begin
                if (filter_ctr == NUM_FILTERS-1) begin
                    if ((row_ctr == IMAGE_HEIGHT-1) & (col_ctr == IMAGE_WIDTH-1))
                        next_state <= IDLE;
                    else
                        next_state <= LOAD_WINDOW;
                end
                else
                    next_state = MACC;
            end
        endcase
    end
    
    always_ff @(posedge i_clk)
    begin
        case (curr_state)
            IDLE: begin
                if (pixel_valid) begin
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
                filter_ctr      <= filter_ctr + 1'b1;
                if (filter_ctr == NUM_FILTERS-1) begin
                    filter_ctr <= 'b0;
                    row_ctr    <= (row_ctr == OUTPUT_HEIGHT-1) ? 'b0 : row_ctr + 1'b1;
                end
            end
        endcase
    end
    
    always_ff @(posedge i_clk) begin
        if (pixel_valid) begin
            // Generate window
            integer i, j;
            for (i = 0; i < FILTER_SIZE-1; i=i+1)
                for (j = 0; j < FILTER_SIZE; j=j+1)
                    window[i][j] <= window[i][j+1];
            window[row_ctr][FILTER_SIZE] <= i_pixel;
            
            // Last column of filter kernel after top row convolutions
            if (row_ctr >= FILTER_SIZE-1) begin
                for (i = 0; i < FILTER_SIZE; i=i+1)
                    window[i][FILTER_SIZE] <= line_buffer[i][col_ctr];
                window[FILTER_SIZE][FILTER_SIZE] <= i_pixel;
            end
            
            // Line buffer
            for (int i = 0; i < FILTER_SIZE-2; i++)
                line_buffer[i][col_ctr] <= line_buffer[i+1][col_ctr];
            line_buffer[FILTER_SIZE-2][col_ctr] <= i_pixel;
            
            // Row/Column counters
            col_ctr <= col_ctr + 1'b1;
            if (col_ctr == IMAGE_WIDTH-1) begin
                col_ctr <= 'b0;
                row_ctr <= (row_ctr < IMAGE_HEIGHT-1) ? row_ctr + 1'b1 : 'b0;
            end
        end
    end
    
    // MACC operation (DSP48E1!!!)
    always_ff @(posedge i_clk) begin
        if (curr_state == MACC) begin
            integer i;
            i = mac_ctr;
            mac_accum <= mac_accum +
                $signed(window[i/FILTER_SIZE][i%FILTER_SIZE]) *
                $signed(filter_weights[filter_ctr][i]);
        end
    end
    
    // review synthesis to check if logical AND results in different RTL circuit
    always_ff @(posedge i_clk) begin
        window_valid    <= pixel_valid ? ((col_ctr >= FILTER_SIZE-1) & (row_ctr >= FILTER_SIZE-1)) : window_valid;
        o_feature_valid <= curr_state == DATA_OUT;
        mac_done        <= (curr_state == MACC) & (mac_ctr == WINDOW_AREA-1);
    end

/* Parallel implementation

    integer i, j, k, l, f;
    
    always_ff @(posedge i_clk)
    begin
        for (f = 0; f < NUM_FILTERS; f++)
        begin
            for (i = 0; i <= IMAGE_HEIGHT - FILTER_SIZE; i++)
            begin
                for (j = 0; j < IMAGE_WIDTH - FILTER_SIZE; j++)
                begin
                    o_feature_map[f][i][j] = 'b0;
                    for (k = 0; k < FILTER_SIZE; k++)
                    begin
                        for (l = 0; l < FILTER_SIZE; l++)
                        begin
                            o_feature_map[f][i][j] = o_feature_map[f][i][j] + i_image[i+k][j+l] * i_filters[f][k][l];
                        end
                    end
                    // ReLU activation
                    if (o_feature_map[f][i][j][15]) o_feature_map[f][i][j] = 'b0;
                end
            end
        end
    end
    
*/
    
endmodule
