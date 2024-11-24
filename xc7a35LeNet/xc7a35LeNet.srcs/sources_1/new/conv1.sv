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
    output logic signed [15:0] o_feature_map[NUM_FILTERS-1:0][IMAGE_HEIGHT-FILTER_SIZE:0][IMAGE_WIDTH-FILTER_SIZE:0]
);

    // For height=5 filter, we only need to store 4 rows of pixel data
    // We could reduce latency if we get creative with bringing in data
    logic [7:0] line_buffer[FILTER_SIZE-2:0][IMAGE_WIDTH-1:0];
    
    logic [7:0] window[FILTER_SIZE-1][FILTER_SIZE-1];
    
    // control counters
    logic [$clog2(IMAGE_HEIGHT)-1:0] row_ctr;
    logic [$clog2(IMAGE_WIDTH)-1:0]  col_ctr;
    logic [$clog2(NUM_FILTERS)-1:0]  filter_ctr;
    
    logic signed [7:0] filter_weights[NUM_FILTERS-1:0][FILTER_SIZE*FILTER_SIZE-1];
    
    logic signed mac_accumulator;
    
    logic [$clog2(FILTER_SIZE*FILTER_SIZE)-1:0] mac_counter;
    
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
    // use proper next state practice here
    always_ff @(posedge clk)
    begin
        curr_state <= next_state;
    end
    
    always_comb begin
        case (curr_state)
            IDLE: begin
                next_state = IDLE;
            end
            LOAD_WINDOW: begin
                next_state = COMPUTE;
            end
            COMPUTE: begin
                next_state = DATA_OUT;
            end
            DATA_OUT: begin
                next_state = COMPUTE;
            end
        endcase
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
