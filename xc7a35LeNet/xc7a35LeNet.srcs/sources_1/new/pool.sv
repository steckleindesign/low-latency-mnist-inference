`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module pool #(
    parameter INPUT_WIDTH  = 28,
    parameter INPUT_HEIGHT = 28,
    parameter NUM_CHANNELS = 6,
    parameter POOL_SIZE    = 2,
    parameter STRIDE       = 2
) (
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic               i_feature_valid,
    input  logic signed [15:0] i_feature,
    output logic               o_feature_valid,
    output logic signed [15:0] o_feature
);

    localparam POOL_AREA = POOL_SIZE*POOL_SIZE;

    // Building serial pooling operation
    // Will need conv layer to send feature map data in correct order
    // So, current pooling is in order, conv will need adjustment

    // Current pool in vector form
    logic signed                  [15:0] pool[POOL_AREA-1:0];
    // Count number of valid features in current pool
    logic        [$clog2(POOL_AREA)-1:0] feature_ctr;
    // Signals making cleaner HDL for computing the max in the pool
    logic                         [15:0] max_ab, max_cd;
    
    // Is this an ok shortcut or do we need an IDLE?
    typedef enum logic {
        INGEST,
        COMPUTE_MAX
    } state;
    state curr_state, next_state;
    
    always_ff @(posedge i_clk)
        curr_state <= i_rst ? INGEST : next_state;
        
    always_ff @(posedge i_clk) begin
        if (i_feature_valid) begin
            case (curr_state)
                INGEST: begin
                    next_state <= i_feature_valid & feature_ctr == (POOL_AREA-2) ? COMPUTE_MAX : INGEST;
                end
                COMPUTE_MAX: begin
                    next_state <= INGEST;
                end
                default: next_state <= INGEST;
            endcase
        end
    end
    
    always @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            // for (int i = 0; i < POOL_AREA; i++)
            //     pool[i] <= 'b0;
            pool            <= '{default: 0};
            feature_ctr     <= 'b0;
            o_feature_valid <= 1'b0;
        end else if (i_feature_valid) begin
            o_feature_valid <= 1'b0;
            feature_ctr     <= feature_ctr + 1'b1;
            case (curr_state)
                INGEST: begin
                    pool <= {pool[2:0], i_feature};
                end
                COMPUTE_MAX: begin
                    max_ab = (i_feature > pool[0]) ? i_feature : pool[0];
                    max_cd = (  pool[2] > pool[1]) ?   pool[2] : pool[1];
                    o_feature       <= (max_ab > max_cd) ? max_ab : max_cd;
                    o_feature_valid <= 1'b1;
                end
            endcase
        end
    end

    // output parallel dimensions [NUM_CHANNELS-1:0][(INPUT_HEIGHT/POOL_SIZE)-1:0][(INPUT_WIDTH/POOL_SIZE)-1:0]

    /*
    for (int i = 0; i < 14; i++)
        for (int j = 0; j < 14; j++)
            curr_max = -2^15;
            for (int k = 0; k < 2; k++)
                for (int l = 0; l < 2; l++)
                    curr_max = max(curr_max, feature_map[i*STRIDE+k][j*STRIDE+l])
                    
    integer c, i, j, k, l;
    always_ff @(posedge i_clk)
    begin
        for (c = 0; c < NUM_CHANNELS; c++)
            for (i = 0; i < INPUT_HEIGHT/POOL_SIZE; i++)
                for (j = 0; j < INPUT_WIDTH/POOL_SIZE; j++) begin
                    automatic logic signed [15:0] max_value = {16{1'b1}};
                    for (k = 0; k < POOL_SIZE; k++)
                        for (l = 0; l < POOL_SIZE; l++)
                            if (i_feature_map[c][i*STRIDE + k][j*STRIDE + l] > max_value)
                                max_value = i_feature_map[c][i*STRIDE + k][j*STRIDE + l];
                end
    end
    */
    
endmodule
