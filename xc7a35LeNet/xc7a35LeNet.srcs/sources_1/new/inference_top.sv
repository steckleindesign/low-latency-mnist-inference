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

This source code is for the low-latency system.

If you have questions or comments, I can be reached at steckleindesign@gmail.com
Thank you!
*/
//////////////////////////////////////////////////////////////////////////////////

module inference_top(
    // 12MHz clock from on-board oscillator
    input  wire       clk,
    // SPI interface
    input  wire       sck,
    input  wire       nss,
    input  wire       mosi,
    output wire       miso,
    // LEDs
    output wire [1:0] led,
    output wire       led_r, led_g, led_b
);

    /* TODO  list:
        SPI interface - placing pixel data in RAM
        
        Structure
        self.conv1 = nn.Conv2d    (1,      6,  5 )
        self.pool1 = nn.MaxPool2d (2,      2     )
        self.conv2 = nn.Conv2d    (6,      16, 5 )
        self.pool2 = nn.MaxPool2d (2,      2     )
        self.fc1   = nn.Linear    (16*4*4, 120   )
        self.fc2   = nn.Linear    (120,    84    )
        self.fc3   = nn.Linear    (84,     10    )
    
        Forward prop
        x      = self.pool1(F.relu(self.conv1(x)))
        x      = self.pool2(F.relu(self.conv2(x)))
        x      = torch.flatten    (x, 1)
        x      = F.relu(self.fc1  (x)  )
        x      = F.relu(self.fc2  (x)  )
        logits =        self.fc3  (x)
        
        Send logits out on MISO line
        
        LEDs (green/red for correct/incorrect?)
    */
    
    // MMCM
    wire        w_clk100m;
    wire        w_locked;
    
    // SPI
    wire        w_wr_req;
    wire        w_rd_req;
    wire  [7:0] w_wr_data;
    wire  [7:0] w_rd_data;
    
    // Bump 12MHz input clock line to 100MHz for internal use
    clk_wiz_0         mmcm0 (.clk    (clk),
                             .reset  (1'b0),
                             .locked (w_locked),
                             .clk100m(w_clk100m));
                             
    // Discontinuous SPI clock
    spi_interface     spi0  (.i_sck    (sck),
                             .i_nss    (nss),
                             .i_mosi   (mosi),
                             .o_miso   (miso),
                             .o_wr_req (w_wr_req),
                             .o_wr_data(w_wr_data),
                             .o_rd_req (w_rd_req),
                             .i_rd_data(w_rd_data));
    
    pixel_curation    cur   (.i_clk         (clk100m),
                             .i_wr_req      (w_wr_req),
                             .i_pixel_data  (w_wr_data),
                             .o_image_vector());
    
    assign led   = 2'b11;
    assign led_r = 1'b1;
    assign led_g = 1'b1;
    assign led_b = 1'b0;
    
endmodule
