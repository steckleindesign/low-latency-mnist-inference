`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Architecture:
        We have 3 feature inputs every 5 clock cycles
        There are 28 features in each row the last is hardcoded to 0
        First compute result map, then serially output NUM_CHANNELS features each clock cycle
        
    Outputs:
        Output Pool maps stored in RAM
        Pool 1: 6*14*14 = 6*196 = 1176
        Pool 2: 16*5*5  = 16*25 = 400
*/

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
    input  logic signed [15:0] i_features[NUM_CHANNELS-1:0],
    output logic               o_feature_valid,
    output logic signed [15:0] o_features[NUM_CHANNELS-1:0]
);

    localparam POOL_AREA   = POOL_SIZE*POOL_SIZE;
    localparam POOL_WIDTH  = INPUT_WIDTH/POOL_SIZE;
    localparam POOL_HEIGHT = INPUT_HEIGHT/POOL_SIZE;
    
    logic signed     [15:0] pool_res_ram[NUM_CHANNELS-1:0][POOL_HEIGHT-1:0][POOL_WIDTH-1:0];
    
    logic [POOL_HEIGHT-1:0] pool_res_row;
    
    logic            [15:0] pool_temp[NUM_CHANNELS-1:0][POOL_SIZE-1:0][INPUT_WIDTH-1:0];
    
    logic  [POOL_WIDTH-1:0] pool_temp_row;
    logic                   pool_temp_col;
    
    logic                   cmp_toggle;
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            pool_res_ram  <= '{default: 0};
            pool_res_row  <= 'b0;
            pool_temp     <= '{default: 0};
            pool_temp_row <= 'b0;
            pool_temp_col <= 0;
            cmp_toggle    <= 0;
        end else
            // o_feature_valid <= 0;
            if (i_feature_valid) begin
                cmp_toggle    <= ~cmp_toggle;
                pool_temp_col <= pool_temp_col + 1;
                if (pool_temp_col == INPUT_WIDTH-1)
                    pool_temp_row <= pool_temp_row + 1;
                // Max compare operations, complete for now, optimize in future
                for (int i = 0; i < NUM_CHANNELS; i++) begin
                    pool_temp[i][pool_temp_row][pool_temp_col] <= i_features[i];
                    if (cmp_toggle)
                        if (pool_temp_row) begin
                            pool_temp[i][0][pool_temp_col-1] <= 
                                pool_temp[i][0][pool_temp_col-1] > pool_temp[i][1][pool_temp_col] ?
                                    pool_temp[i][0][pool_temp_col-1] : pool_temp[i][1][pool_temp_col];
                            // o_feature_valid <= 1;
                        end else
                            pool_temp[i][0][pool_temp_col-1] <= 
                                pool_temp[i][0][pool_temp_col] > pool_temp[i][0][pool_temp_col-1] ?
                                    pool_temp[i][0][pool_temp_col] : pool_temp[i][0][pool_temp_col-1];
                    else
                        if (pool_temp_row)
                            pool_temp[i][0][pool_temp_col] <= 
                                pool_temp[i][0][pool_temp_col] > pool_temp[i][1][pool_temp_col] ?
                                    pool_temp[i][0][pool_temp_col] : pool_temp[i][1][pool_temp_col];
                end
            end
        
    end
    
endmodule
