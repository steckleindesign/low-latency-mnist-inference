`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Connections in the 2nd convolutional layer are not as trivial
    In the prior layer, S2, the first max pooling layer, there are 6x14x14 feature maps
    In this convolutional layer, there are 16 output feature maps. The feature maps of S2 are
    tied to each map of this convolutional layer, C3, are as follows:
    Map 0:  0, 1, 2
    Map 1:  1, 2, 3
    Map 2:  2, 3, 4
    Map 3:  3, 4, 5
    Map 4:  0, 4, 5
    Map 5:  0, 1, 5
    Map 6:  0, 1, 2, 3
    Map 7:  1, 2, 3, 4
    Map 8:  2, 3, 4, 5
    Map 9:  0, 3, 4, 5
    Map 10: 0, 1, 4, 5
    Map 11: 0, 1, 2, 5
    Map 12: 0, 1, 3, 4
    Map 13: 1, 2, 4, 5
    Map 14: 0, 2, 3, 5
    Map 15: 0, 1, 2, 3, 4, 5
    
    Each S2 map has 10 different weight kernels
    
    There are 6*(3*5*5 + 1) + 9*(4*5*5 + 1) + 6*5*5 + 1 = 1516 trainable parameters
    
    Num multiplies = 6*10*10*5*5*3 + 9*10*10*5*5*4 + 10*10*5*5*6 = 10*10*(1516-16) = 150000
    
    The Artix-7 35 device has 90 DSP48s.
    We will have all 90 DSPs available as with the current architecture, all 90 DSPs will be free for conv2.
    150000/90 = 1666.67 = 1667 clock cycles worth of full DSP48 utilization.
    
    We need to store all 6 S2 maps simultaneously. However, one S2 map
    will be used to fill the feature window at any given point in time.
    
    A similar convolution pattern will be implemented for conv2 as was implemented in conv1.
    However all 90 DSPs will be working on the same input feature map
    
    DSP mapping over 5x5 kernels (5 cycles to compute 18 kernels)
    25 25 25 15
             10 25 25 25  5
                         20 25 25 20
                                   5 25 25 25 10
                                              15 25 25 25
    
    Can we make this a 4:1 mux or is 8:1 the smallest we can do
    
    Potential mapping of the 18 DSP groups
    By cycle
    cyc 1: 
        row 1: 4
        row 2: 4
        row 3: 4
        row 4: 3
        row 5: 3
    cyc 2:
        row 1: 4
        row 2: 3
        row 3: 3
        row 4: 4
        row 5: 4
    cyc 3:
        row 1: 3
        row 2: 4
        row 3: 4
        row 4: 4
        row 5: 3
    cyc 4:
        row 1: 4
        row 2: 4
        row 3: 3
        row 4: 3
        row 5: 4
    cyc 5:
        row 1: 3
        row 2: 3
        row 3: 4
        row 4: 4
        row 5: 4
    By rows
    row 1: 4, 4, 3, 4, 3
    row 2: 4, 3, 4, 4, 3
    row 3: 4, 3, 4, 3, 4
    row 4: 3, 4, 4, 3, 4
    row 5: 3, 4, 3, 4, 4
    
    
    Total of 10x10 = 100 kernels in each S2 map
    If we only process 9x9, then there is 81 kernels.
    Then there would be 2x81 = 162 kernels in 2 S2 maps.
    So it would take 162/18 * 5 = 45 cycles to compute the *
    for 2 full feature maps, and 5x45=225 cycles to
    process all multiplies for the 10 iterations over a single
    S2 map. So 6x225=1350 cycles for all multiply operations
    in the covolution computation for conv2.
    
    ______________________________________
    Maps:         \ 1 \ 2 \ 3 \ 4 \ 5 \ 6 \
    _______________________________________
    6 DSP groups: \ 6 \   \   \   \   \   \
    6 DSP groups: \ 4 \ 2 \   \   \   \   \
    6 DSP groups: \   \ 6 \   \   \   \   \
    6 DSP groups: \   \ 2 \ 4 \   \   \   \
    6 DSP groups: \   \   \ 6 \   \   \   \
    6 DSP groups: \   \   \   \ 6 \   \   \
    6 DSP groups: \   \   \   \ 4 \ 2 \   \
    6 DSP groups: \   \   \   \   \ 6 \   \
    6 DSP groups: \   \   \   \   \ 2 \ 4 \
    6 DSP groups: \   \   \   \   \   \ 6 \
    
    Logic theory (1 always block for each component):
    Feature buffer consumption and control
    Feature window loading (muxing?)
    Feature operand muxing
    
    
*/

//////////////////////////////////////////////////////////////////////////////////

module conv2(
    input  logic               i_clk,
    input  logic               i_rst,
    input  logic               i_feature_valid,
    input  logic         [7:0] i_features,
    output logic               o_feature_valid,
    output logic signed [15:0] o_features
);

    localparam WEIGHTS_FILE     = "conv2_weights.mem";
    localparam BIASES_FILE      = "conv2_biases.mem";
    localparam INPUT_CHANNELS   = 6;
    localparam INPUT_WIDTH      = 14;
    localparam INPUT_HEIGHT     = 14;
    localparam FILTER_SIZE      = 5;
    localparam NUM_DSP          = 90;
    
    localparam WINDOW_AREA   = FILTER_SIZE * FILTER_SIZE;
    localparam OUTPUT_HEIGHT = INPUT_HEIGHT - FILTER_SIZE + 1;
    localparam OUTPUT_WIDTH  = INPUT_WIDTH - FILTER_SIZE + 1;

    logic signed [7:0] weights [0:5][0:9][0:FILTER_SIZE-1][0:FILTER_SIZE-1];
    initial $readmemb(WEIGHTS_FILE, weights);
    
    logic signed [7:0] biases [0:5][0:9];
    initial $readmemb(BIASES_FILE, biases);
    
    // Indexed features to be used for * operation
    logic        [7:0] feature_operands[0:NUM_DSP-1];
    logic signed [7:0] weight_operands[0:NUM_DSP-1];
    
    // Feature conv location
    logic [INPUT_HEIGHT-1:0] feat_row_ctr;
    logic [INPUT_WIDTH-1:0] feat_col_ctr;
    // We're just going to use BRAM? here to store features
    // Can and probably should do the same thing for conv1, and throughout design in general
    logic [$clog2(INPUT_HEIGHT)-1:0] ram_row_ctr;
    logic [$clog2(INPUT_WIDTH)-1:0]  ram_col_ctr;
    // Can use 6xRAM196 => 6*3=18 LUTs, or an 18-Kb Block RAM
    // Do we want to deepen BRAM so its easier to register out features?
    // TODO: Need to draw diagram on paper for memory design here
    logic signed [7:0] feature_ram[0:INPUT_CHANNELS-1][0:INPUT_HEIGHT-1][0:INPUT_WIDTH-1];
    
    // Feature RAM full flag
    logic feature_ram_full;
    // Enable convolution MACC operations on this layer (CONV2)
    logic layer_en;
    
    
    // MACC accumulate, 4 deep to hold at least 9 accumates during the 4-map convolutions
    // logic signed [23:0] macc_acc[0:3];
    // Register outputs of DSPs
    logic signed [23:0] mult_out[0:89];
    
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst) begin
            ram_row_ctr      <= 0;
            ram_col_ctr      <= 0;
            feature_ram_full <= 0;
            layer_en         <= 0;
        end else begin
            if (i_feature_valid) begin
                for (int i = 0; i < INPUT_CHANNELS; i++)
                    feature_ram[i][ram_row_ctr][ram_col_ctr] <= i_features[i];
                ram_col_ctr <= ram_col_ctr + 1;
                if (ram_col_ctr == INPUT_WIDTH-1)
                    ram_row_ctr <= ram_row_ctr + 1;
                if (ram_row_ctr[2] & ram_row_ctr[0])
                    macc_en <= 1;
                // What logic is going to use the RAM full flag?
                if (ram_row_ctr == INPUT_HEIGHT-1 && ram_col_ctr == INPUT_WIDTH-1)
                    ram_full <= 1;
            end
        end
    end
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst) begin
            feat_row_ctr <= ROW_START;
            feat_col_ctr <= COL_START;
        end else begin
            feat_col_ctr <= feat_col_ctr + 1;
            if (feat_col_ctr == COL_END) begin
                feat_col_ctr <= 0;
                feat_row_ctr <= feat_row_ctr == COL_END ? 0: feat_row_ctr + 1;
            end
        end
    end

endmodule