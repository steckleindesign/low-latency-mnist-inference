`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
Implementation of an ultra low-latency LeNet-5 model for 28x28 MNIST inference

Referenced the original paper for LeNet-5 for the model architecture:
Utilized the architecture from Gradient Based Learning Applied to Document Recognition

Referenced Papers with code for pytorch implementation to train model:
https://github.com/Elman295/Paper_with_code/blob/main/LeNet_5_Pytorch.ipynb

With the model architecture from the paper, and the parameters after training,
using the pytorch model, I implemented the inference ready model on an Artix 7.

This design targets the xc7a35tcpg236-1 device.
I have the physical chip embedded on a breadboardable PCB,
on the same breadboard, I have an STM32L4 MCU, on its own PCB.
The flow of the system is such that the MCU send image pixels to the FPGA
via the SPI interface, hence the MCU is the controller and the FPGA the peripheral.

The FPGA performs model inference on the input image,
and outputs the image classification on the MISO line.

I developed 2 designs, which differ in how the image data on the MOSI line is processed.

Low-latency system:
All 32x32 = 1024 pixels are first recieved from the MCU,
then the model propagates the inputs at once.

Ultra low-latency system:
As the pixel data comes in on the MOSI line,
the model propagates the inputs through the model.
The inference process doesn't wait for all pixel data to be ready
at the start of inference, rather it propagates pixel data on the fly.

This source code is for the ultra low-latency system.

If you have questions or comments, I can be reached at steckleindesign@gmail.com
Thank you!

(Latency is limited first by input data rate, second by DSP48s)

Consider SW techniques to improve the HW design process for conv and fc layers

Structure - pytorch
self.conv1 = nn.Conv2d    (1,      6,  5 )
self.pool1 = nn.MaxPool2d (2,      2     )
self.conv2 = nn.Conv2d    (6,      16, 5 )
self.pool2 = nn.MaxPool2d (2,      2     )
self.fc1   = nn.Linear    (16*4*4, 120   )
self.fc2   = nn.Linear    (120,    84    )
self.fc3   = nn.Linear    (84,     10    )

Forward prop - pytorch
x      = self.pool1(F.relu(self.conv1(x)))
x      = self.pool2(F.relu(self.conv2(x)))
x      = torch.flatten    (x, 1)
x      = F.relu(self.fc1  (x)  )
x      = F.relu(self.fc2  (x)  )
logits =        self.fc3  (x)

weights RAMs
    conv1 does not use global weights rams
    conv2, conv3, fc, output layers uses global weights RAM
    conv2 + conv3 + fc + output weights RAM depth = 2300-2800?
    With 90x18Kb RAM we can only store 2250 8-bit values.
    This is close to the requirement so the extra weights coefficients
    could be stored in fabric FFs upon the GSR, and wrote into the
    weights BRAMs once conv2 begins reading weight data from the RAMs

Once we understand
1) DSP input data paths
2) DSP output data paths
3) Adder tree / MACC architecture
We will be able to better determine feasability of placement


Resource mapping

100 RAMB18Es?
How many ports?

90 18kb Block RAMs dedicated to DSP weights operands

Memory resources (10 free 18kb Block RAMs):
    Store image input data (8,192 bits)          -> BRAM_0

    Store feature RAM data in conv1 (1,280 bits) -> BRAM_1

    Store S2 feature maps (9,408 bits)           -> BRAM_2-6
    
    Where to store 60 intermediate feature maps for conv2 operation (48,000 bits) ???
        With each intermediate map as 10x10 8-bit values, we could use Distributed RAMs
        Each RAM is 100 Deep x 8 Wide
        Effectively 60 x 128 x 8-bit Distributed RAMs
        We will use RAM32M => 32x8-bit LUTRAM uses 4 LUT6 per RAM32M
        128x8-bit Distributed RAM will use 16 LUTRAMs (2 CLBs)
        60 of these will utilize 120 CLBs
    
    Store S4 feature maps as large SR (FIFO??) in BRAM (3,200 bits) -> BRAM_7
    
    Store C5 120 neurons 8-bit data (960 bits)                      -> Fabric FFs
    
    Store F6 84 neurons 8-bit data (672 bits)                       -> Fabric FFs
    

PLAN:
    develop data paths into BRAMs for s2 feature maps
    develop conv2 datapaths, focus on DSP mapping and intermediate results storage
    develop max pool 2 layer which quickly processes data out of conv2 and stores results in BRAM
    
    
    
TODO:
    conv 2: FSM, DSP feature muxing, coefficient flow
    conv 3: control logic
    fc:     feature buffering, control logic
    output: control logic

Future:
    conv 1: re-architect
    Send output out on MISO line
    Floorplanning
    Synthesis attributes
    Synthesis and implementation strategies
    Transceiver for IO data

*/
//////////////////////////////////////////////////////////////////////////////////

module inference_top(
    // 12MHz clock from on-board oscillator
    input  logic       clk,
    input  logic       rst,
    // SPI interface
    input  logic       sck,
    input  logic       nss,
    input  logic       mosi,
    output logic       miso,
    // Logits ready signal MCU interrupt
    output logic       logits_valid,
    // LEDs
    output logic [1:0] led,
    output logic       led_r, led_g, led_b
);
    
    localparam CONV1_CHANNELS = 6;
    localparam CONV2_CHANNELS = 16;
    
    // MMCM
    logic       clk100m;
    logic       locked;
    
    // SPI
    logic       spi_wr_req;
    logic       spi_rd_req;
    logic [7:0] spi_wr_data;
    logic [7:0] logit; // spi_rd_data
    
    // Valid signals, features
    logic               pixel_valid;
    logic         [7:0] w_pixel;
    logic         [7:0] img_ram_data;
    logic               img_ram_data_valid;
    logic               conv1_feature_valid, conv2_feature_valid;
    logic signed [15:0] conv1_features[0:CONV1_CHANNELS-1], conv2_features[0:CONV2_CHANNELS-1];
    logic               pool1_feature_valid, pool2_feature_valid;
    logic signed [15:0] pool1_feature,       pool2_feature;
    
    logic               conv1_take_feature, conv2_take_feature, conv3_take_feature;
    
    logic               fc1_neuron_valid, fc2_neuron_valid, fc3_neuron_valid;
    // FEATURE_WIDTH+WEIGHT_WIDTH+$clog2(NUM_FEATURES)-1
    logic signed [16+16+$clog2(16*5*5):0] fc1_neuron, fc2_neuron, fc3_neuron;
    
    // Bump 12MHz input clock line to 100MHz for internal use
    clk_wiz_0 mmcm0 (.clk(clk),
                     .reset(rst),
                     .locked(locked),
                     .clk100m(clk100m));
                             
    // Discontinuous SPI clock
    // How to handle reset for SPI interface? Do we need a reset?
    spi_interface spi0 (.i_sck(sck),
                        .i_nss(nss),
                        .i_mosi(mosi),
                        .o_miso(miso),
                        .o_wr_req(spi_wr_req),
                        .o_wr_data(spi_wr_data),
                        .o_rd_req(spi_rd_req),
                        .i_rd_data(logit));
                             
    // Grayscale pixel data
    pixel_curation cur (.i_clk(clk100m),
                        .i_rst(rst),
                        .i_wr_req(spi_wr_req),
                        .i_spi_data(spi_wr_data),
                        .o_pixel(spi_pixel),
                        .o_pix_valid(spi_pixel_valid));

    image_buffer_ram
        img_buf_ram (.clk(clk100m),
                     .rst(rst),
                     .pixel_in(spi_pixel),
                     .pixel_in_valid(spi_pixel_valid),
                     .hold(~conv1_take_feature),
                     .pixel_out(img_ram_data));
    
    // Convolutional Layer 1
    conv1 #(.NUM_FILTERS(CONV1_CHANNELS))
          conv_1 (.i_clk(clk100m),
                  .i_rst(rst),
                  .i_feature_valid(),
                  .i_feature(img_ram_data),
                  .o_feature_valid(conv1_feature_valid),
                  .o_features(conv1_features),
                  .o_ready_feature(conv1_take_feature),
                  .o_last_feature());
          
    // Max Pooling Layer 1
    pool #(.INPUT_WIDTH (28),
           .INPUT_HEIGHT(28),
           .NUM_CHANNELS(6))
         max_pool_1 (.i_clk(clk100m),
                     .i_rst(rst),
                     .i_feature_valid(conv1_feature_valid),
                     .i_features(conv1_features),
                     .o_feature_valid(pool1_feature_valid),
                     .o_features(pool1_features));
                            
    // Convolutional Layer 2
    conv2 #()
          conv_2 (.i_clk(clk100m),
                  .i_rst(rst),
                  .i_feature_valid(pool1_feature_valid),
                  .i_feature(pool1_feature),
                  .o_feature_valid(conv2_feature_valid),
                  .o_features(conv2_features));
                            
    // Max Pooling Layer 2
    pool #(.INPUT_WIDTH (10),
           .INPUT_HEIGHT(10),
           .NUM_CHANNELS(16))
         max_pool_2 (.i_clk(clk100m),
                     .i_rst(rst),
                     .i_feature_valid(conv2_feature_valid),
                     .i_features(conv2_features),
                     .o_feature_valid(pool2_feature_valid),
                     .o_features(pool2_features));
    
    // Convolutional Layer 3
    conv3 #()
          conv_3 (.i_clk(clk100m),
                  .i_rst(rst),
                  .i_feature_valid(spi_pixel_valid),
                  .i_feature(spi_pixel),
                  .o_feature_valid(conv1_feature_valid),
                  .o_features(conv1_features),
                  .o_buffer_full(conv1_lb_full));
                             
    // Fully Connected Layer 1
    fc #(
         .WEIGHTS_FILE("fc1_weights.mem"),
         .BIASES_FILE("fc1_biases.mem"),
         .FEATURE_WIDTH(16),
         .NUM_FEATURES(16*5*5),
         .NUM_NEURONS(84)
        ) fc_inst (
         .i_clk(clk100m),
         .i_rst(rst),
         .i_feature_valid(pool2_feature_valid),
         .i_features(pool2_features),
         .o_neuron_valid(fc1_neuron_valid),
         .o_neuron(fc1_neuron));
                             
                             
    // Fully Connected Layer 2 (Output Layer)
    output_fc #(
               .WEIGHTS_FILE("output_fc_weights.mem"),
               .BIASES_FILE ("output_fc_biases.mem"),
               .FEATURE_WIDTH(16+16+$clog2(16*5*5)+$clog2(120)),
               .NUM_FEATURES (84),
               .NUM_CLASSES  (10)
              ) output_fc_inst (
               .i_clk(clk100m),
               .i_rst(rst),
               .i_feature_valid(fc2_neuron_valid),
               .i_feature(fc2_neuron),
               // class valid signal will connect to output pad
               // this valid signal will be traced to the MCU
               // the MCU will configure an interrupt pin for the incoming valid line
               // upon the interrupt, the MCU will execute a SPI read
               // directly after the class is valid, the FPGA should send the logits to the SPI controller
               .o_logits_valid(logits_valid),
               .o_logits(logit));
    
    // LEDs as constant hue for now, save all resources for CNN
    assign led   = 2'b11;
    assign led_r = 1'b1;
    assign led_g = 1'b1;
    assign led_b = 1'b0;
    
endmodule
