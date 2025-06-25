`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    S2 feature maps are connected to C3 feature maps as follows:
    Map  0: 0, 1, 2
    Map  1: 1, 2, 3
    Map  2: 2, 3, 4
    Map  3: 3, 4, 5
    Map  4: 0, 4, 5
    Map  5: 0, 1, 5
    Map  6: 0, 1, 2, 3
    Map  7: 1, 2, 3, 4
    Map  8: 2, 3, 4, 5
    Map  9: 0, 3, 4, 5
    Map 10: 0, 1, 4, 5
    Map 11: 0, 1, 2, 5
    Map 12: 0, 1, 3, 4
    Map 13: 1, 2, 4, 5
    Map 14: 0, 2, 3, 5
    Map 15: 0, 1, 2, 3, 4, 5
    
    Trainable parameters = 6*(3*5*5 + 1) + 9*(4*5*5 + 1) + 6*5*5 + 1 = 1516
    Num multiplies       = (6*3 + 9*4 + 6) * (10*10*5*5) = 10*10*(1516-16) = 150000
    
    150000/90 = 1666.67 = 1667 clock cycles worth of full DSP48 utilization.
    
    Store all 6 S2 maps in parallel, but one S2 map is being used to fill the feature window at a time.
    
    Potential mapping of the 18 DSP groups
    By cycle
    cyc 1:         cyc 2:         cyc 3:         cyc 4:         cyc 5:
        row 1: 4       row 1: 4       row 1: 3       row 1: 4       row 1: 3
        row 2: 4       row 2: 3       row 2: 4       row 2: 4       row 2: 3
        row 3: 4       row 3: 3       row 3: 4       row 3: 3       row 3: 4
        row 4: 3       row 4: 4       row 4: 4       row 4: 3       row 4: 4
        row 5: 3       row 5: 4       row 5: 3       row 5: 4       row 5: 4
    
    By rows
    row 1: 4, 4, 3, 4, 3
    row 2: 4, 3, 4, 4, 3
    row 3: 4, 3, 4, 3, 4
    row 4: 3, 4, 4, 3, 4
    row 5: 3, 4, 3, 4, 4
    
    Adder tree structure:
    Instead of having wide multiplexers on the outputs of the MACC operations,
    just store the data into a big SR and after the MACC operations finished
    processing we can shift out the processed data and we know the order
    We'll have 6 SRs, 1 for each S2 map. Each SR will be 10x9x9x8-bit = 6480 bits
    May need to store data in BRAMs
    What will the mux structure on the output datapath look like?
    
    
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
    
    
    New architecture
    
    We are only doing 9x9 convolutions
    and there are 10 weight kernals for
    each S2 map and 90 DSPs.
    
    So we divide DSPs into 10 groups of 9.
    Each DSP group has the job of working on its own row
    It will take 25 clock cycles For each of these rows
    
    16 10x10 output feature maps = 1600 8-bit values = 12,800 bits
    So there are 1600 accumulate values
    
    
    
    Another idea is to have a single DSP dedicated to each input feature map
    However, there are only 60 input features maps.
    How to utilize the other 30 DSPs
    
    While we are performing a 5x5 kernel multiply on a single DSP
    We also need to accumulate each of the 25 multiply results
    Every 5x5=25 cycles, 
    
    We want to end up with 60 intermediate maps, each are 10x10 8-bit values = 800 bits
    They will have to be stored in BRAM as SRs
    
    After we have the 60 intermediate maps, we have to add these to the output accums
    
    For now we may just use 60 DSPs for the convolution operations in this layer.
    
    
    6x196 8-bit feature RAMs of S2 feature data
    each feature RAM feeds feature operands to 10 different DSPs, no muxing involved
    
    MACC (DSP48E1) output muxing to C3 feature maps:
    There are either 3, 4, or 6 DSP outputs to be added
    The remaining 30 DSP48E1s shall be used efficiently to perform these additions
    Each of the 60 "*" DSP outputs can be directly connected to the
    appropriate "+" DSP inputs as adder operands.
    The DSP48E1 based adder tree structure may need to be instantiated or at least
    synthesis attributes shall be used to ensure the adder tree structure uses DSPs
    This architecture will seriously minimize hardware resources and specifically
    elimates large muxes introduced in this layer.
    The tradeoff is latency wont be optimal, but we can work towards lower latency
    in the future.
    
    The last thing we decide is how the output data shall be configured in HW.
    conv3 processes the feature maps sequentially from top left of S4 to
    bottom right of S4. So we need to store the output feature map data for
    this layer in a single deep shift register. Using a block RAM will suffice.
    We will have 16 new results valid to be added to this SR in a single clock
    cycle so we will need a smart way to load these results into the SR as
    there will be 1 or 2 input data ports max.
    
    Other option is to have a SR for each S4 feature map, but this will require
    muxes in conv3 and will be a worse tradeoff it seems as of now.
    
    The data from S2 comes in parallel between all 6 feature maps, and serially
    on a per feature map basis
    
    Theory of operation:
    1) Gather features into 6 14x5 8-bit feature buffers (6x70 8-bit data)
    2) When the feature buffer is full enough (4 rows and first feature of 5th row)
        MACC operations should begin
    3) MACC operation consists of 25 cycles per output feature accumulation
    4) Store output feature accumulations in their own 60 feature maps
        That's 60x10x10 8-bit values = 6000 8-bit values, or 48,000 bits (Needs 3 18kb BRAMs)
    5) Use DSPs to add appropriate output feature map values into 16 C3 feature maps
    
    Difficult part is the control logic and the mechanism for storing data between
    each data processing phase
    
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
    
    // C3 features are structured as 16 10x10 feature maps
    logic signed [7:0] c3_maps[0:15][0:9][0:9];
    
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