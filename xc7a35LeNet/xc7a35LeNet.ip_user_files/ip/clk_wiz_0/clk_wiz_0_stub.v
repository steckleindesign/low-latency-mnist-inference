// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Sun Nov 17 13:32:12 2024
// Host        : fpgadev running 64-bit Ubuntu 22.04.4 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk100m, reset, locked, clk)
/* synthesis syn_black_box black_box_pad_pin="reset,locked,clk" */
/* synthesis syn_force_seq_prim="clk100m" */;
  output clk100m /* synthesis syn_isclock = 1 */;
  input reset;
  output locked;
  input clk;
endmodule
