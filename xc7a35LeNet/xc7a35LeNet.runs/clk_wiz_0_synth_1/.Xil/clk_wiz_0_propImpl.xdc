set_property SRC_FILE_INFO {cfile:/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc rfile:../../../xc7a35LeNet.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:54 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk]] 0.833
