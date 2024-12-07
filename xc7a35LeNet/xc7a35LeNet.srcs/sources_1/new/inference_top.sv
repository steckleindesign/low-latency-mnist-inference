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
    // LEDs
    output logic [1:0] led,
    output logic       led_r, led_g, led_b
);

    /* TODO  list:
        Send logits out on MISO line
        Filter weights/biases
        Fully connected layer
    */
    
    // MMCM
    logic       clk100m;
    logic       locked;
    
    // SPI
    logic       spi_wr_req;
    logic       spi_rd_req;
    logic [7:0] spi_wr_data;
    logic [7:0] spi_rd_data;
    
    // Valid pixel for input (to first convolution layer)
    logic               pixel_valid;
    logic         [7:0] w_pixel;
    logic               conv1_feature_valid, conv2_feature_valid;
    logic signed [15:0] conv1_feature,       conv2_feature;
    logic               pool1_feature_valid, pool2_feature_valid;
    logic signed [15:0] pool1_feature,       pool2_feature;
    
    // Bump 12MHz input clock line to 100MHz for internal use
    clk_wiz_0         mmcm0 (.clk    (clk),
                             .reset  (rst),
                             .locked (locked),
                             .clk100m(clk100m));
                             
    // Discontinuous SPI clock
    // How to handle reset for SPI interface? Do we need a reset?
    spi_interface     spi0  (.i_sck    (sck),
                             .i_nss    (nss),
                             .i_mosi   (mosi),
                             .o_miso   (miso),
                             .o_wr_req (spi_wr_req),
                             .o_wr_data(spi_wr_data),
                             .o_rd_req (spi_rd_req),
                             .i_rd_data(spi_rd_data));
                             
    // Grayscale pixel data
    pixel_curation    cur   (.i_clk      (clk100m),
                             .i_rst      (rst),
                             .i_wr_req   (spi_wr_req),
                             .i_spi_data (spi_wr_data),
                             .o_pixel    (spi_pixel),
                             .o_pix_valid(spi_pixel_valid));
    
    // Convolutional Layer 1
    conv1                  #(
                             .IMAGE_WIDTH (32),
                             .IMAGE_HEIGHT(32),
                             .FILTER_SIZE ( 5),
                             .NUM_FILTERS ( 6)
                            ) conv1_inst (
                             .i_clk          (clk100m),
                             .i_rst          (rst),
                             .i_feature_valid(spi_pixel_valid),
                             .i_feature      (spi_pixel),
                             .o_feature_valid(conv1_feature_valid),
                             .o_feature      (conv1_feature));
                            
    // Max Pooling Layer 1
    pool                   #(
                             .INPUT_WIDTH (28),
                             .INPUT_HEIGHT(28),
                             .NUM_CHANNELS(6),
                             .POOL_SIZE   (2),
                             .STRIDE      (2)
                            ) maxpool1 (
                             .i_clk          (clk100m),
                             .i_rst          (rst),
                             .i_feature_valid(conv1_feature_valid),
                             .i_feature      (conv1_feature),
                             .o_feature_valid(pool1_feature_valid),
                             .o_feature      (pool1_feature));
                            
    // Convolutional Layer 2
    conv2                  #(
                             .FEATURE_WIDTH (14),
                             .FEATURE_HEIGHT(14),
                             .FILTER_SIZE   ( 5),
                             .NUM_FILTERS   (16)
                            ) conv2_inst (
                             .i_clk          (clk100m),
                             .i_rst          (rst),
                             .i_feature_valid(pool1_feature_valid),
                             .i_feature      (pool1_feature),
                             .o_feature_valid(conv2_feature_valid),
                             .o_feature      (conv2_feature));
                            
    // Max Pooling Layer 2
    pool                   #(
                             .INPUT_WIDTH (28),
                             .INPUT_HEIGHT(28),
                             .NUM_CHANNELS(6),
                             .POOL_SIZE   (2),
                             .STRIDE      (2)
                            ) maxpool2 (
                             .i_clk          (clk100m),
                             .i_rst          (rst),
                             .i_feature_valid(conv2_feature_valid),
                             .i_feature      (conv2_feature),
                             .o_feature_valid(pool2_feature_valid),
                             .o_feature      (pool2_feature));
    
    // Can FC layers be collapsed?
    
    assign led   = 2'b11;
    assign led_r = 1'b1;
    assign led_g = 1'b1;
    assign led_b = 1'b0;
    
endmodule
