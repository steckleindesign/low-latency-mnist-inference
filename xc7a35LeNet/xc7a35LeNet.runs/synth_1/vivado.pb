
�
Command: %s
1870*	planAhead2�
�read_checkpoint -auto_incremental -incremental /home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/utils_1/imports/synth_1/inference_top.dcpZ12-2866h px� 
�
;Read reference checkpoint from %s for incremental synthesis3154*	planAhead2{
y/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/utils_1/imports/synth_1/inference_top.dcpZ12-5825h px� 
T
-Please ensure there are no constraint changes3725*	planAheadZ12-7989h px� 
h
Command: %s
53*	vivadotcl27
5synth_design -top inference_top -part xc7a35tcpg236-1Z4-113h px� 
:
Starting synth_design
149*	vivadotclZ4-321h px� 
z
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
	Synthesis2	
xc7a35tZ17-347h px� 
j
0Got license for feature '%s' and/or device '%s'
310*common2
	Synthesis2	
xc7a35tZ17-349h px� 
D
Loading part %s157*device2
xc7a35tcpg236-1Z21-403h px� 
Z
$Part: %s does not have CEAM library.966*device2
xc7a35tcpg236-1Z21-9227h px� 

VNo compile time benefit to using incremental synthesis; A full resynthesis will be run2353*designutilsZ20-5440h px� 
�
�Flow is switching to default flow due to incremental criteria not met. If you would like to alter this behaviour and have the flow terminate instead, please set the following parameter config_implementation {autoIncr.Synth.RejectBehavior Terminate}2229*designutilsZ20-4379h px� 
o
HMultithreading enabled for synth_design using a maximum of %s processes.4828*oasys2
4Z8-7079h px� 
a
?Launching helper process for spawning children vivado processes4827*oasysZ8-7078h px� 
O
#Helper process launched with PID %s4824*oasys2
533174Z8-7075h px� 
�
%s*synth2�
�Starting RTL Elaboration : Time (s): cpu = 00:00:02 ; elapsed = 00:00:02 . Memory (MB): peak = 2127.250 ; gain = 415.621 ; free physical = 41300 ; free virtual = 49762
h px� 
�
5undeclared symbol '%s', assumed default net type '%s'7502*oasys2
	o_wr_addr2
wire2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
618@Z8-11241h px� 
�
5undeclared symbol '%s', assumed default net type '%s'7502*oasys2
	o_rd_addr2
wire2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
628@Z8-11241h px� 
�
5undeclared symbol '%s', assumed default net type '%s'7502*oasys2	
clk100m2
wire2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
1078@Z8-11241h px� 
�
synthesizing module '%s'%s4497*oasys2
inference_top2
 2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
438@Z8-6157h px� 
�
synthesizing module '%s'%s4497*oasys2
	clk_wiz_02
 2�
�/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.runs/synth_1/.Xil/Vivado-533149-fpgadev/realtime/clk_wiz_0_stub.v2
68@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
	clk_wiz_02
 2
02
12�
�/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.runs/synth_1/.Xil/Vivado-533149-fpgadev/realtime/clk_wiz_0_stub.v2
68@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
spi_interface2
 2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
118@Z8-6157h px� 
�
-case statement is not full and has no default155*oasys2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
1118@Z8-155h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
spi_interface2
 2
02
12r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
118@Z8-6155h px� 
�
Fall outputs are unconnected for this instance and logic may be removed3605*oasys2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
1078@Z8-4446h px� 
�
synthesizing module '%s'%s4497*oasys2
pixel_curation2
 2s
o/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pixel_curation.sv2
98@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
pixel_curation2
 2
02
12s
o/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pixel_curation.sv2
98@Z8-6155h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
inference_top2
 2
02
12r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
438@Z8-6155h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2
wr_addr_r_reg2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
618@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2
rd_addr_r_reg2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
628@Z8-6014h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
data_in_gated_reg2
spi_interface2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
658@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
hold_rd_data_r_reg2
spi_interface2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
1098@Z8-7137h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
o_image_vector2
pixel_curation2s
o/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pixel_curation.sv2
138@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
	w_rd_data2
inference_top2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
898@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2	
clk100m2
inference_top2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
1078@Z8-3848h px� 
m
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led[1]2
1Z8-3917h px� 
m
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led[0]2
1Z8-3917h px� 
l
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led_r2
1Z8-3917h px� 
l
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led_g2
1Z8-3917h px� 
l
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led_b2
0Z8-3917h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1023]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1022]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1021]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1020]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1019]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1018]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1017]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1016]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1015]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1014]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1013]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1012]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1011]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1010]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1009]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1008]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1007]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1006]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1005]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1004]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1003]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1002]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1001]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[1000]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[999]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[998]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[997]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[996]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[995]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[994]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[993]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[992]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[991]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[990]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[989]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[988]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[987]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[986]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[985]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[984]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[983]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[982]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[981]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[980]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[979]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[978]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[977]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[976]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[975]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[974]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[973]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[972]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[971]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[970]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[969]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[968]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[967]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[966]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[965]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[964]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[963]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[962]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[961]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[960]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[959]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[958]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[957]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[956]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[955]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[954]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[953]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[952]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[951]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[950]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[949]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[948]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[947]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[946]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[945]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[944]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[943]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[942]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[941]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[940]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[939]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[938]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[937]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[936]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[935]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[934]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[933]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[932]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[931]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[930]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[929]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[928]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[927]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[926]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[925]2
pixel_curationZ8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
o_image_vector[924]2
pixel_curationZ8-7129h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2
Synth 8-71292
100Z17-14h px� 
�
%s*synth2�
�Finished RTL Elaboration : Time (s): cpu = 00:00:03 ; elapsed = 00:00:03 . Memory (MB): peak = 2203.219 ; gain = 491.590 ; free physical = 41202 ; free virtual = 49665
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
;
%s
*synth2#
!Start Handling Custom Attributes
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Handling Custom Attributes : Time (s): cpu = 00:00:03 ; elapsed = 00:00:03 . Memory (MB): peak = 2218.062 ; gain = 506.434 ; free physical = 41202 ; free virtual = 49665
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished RTL Optimization Phase 1 : Time (s): cpu = 00:00:03 ; elapsed = 00:00:03 . Memory (MB): peak = 2218.062 ; gain = 506.434 ; free physical = 41202 ; free virtual = 49665
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
Netlist sorting complete. 2

00:00:002

00:00:002

2218.0622
0.0002
412022
49665Z17-722h px� 
K
)Preparing netlist for logic optimization
349*projectZ1-570h px� 
>

Processing XDC Constraints
244*projectZ1-262h px� 
=
Initializing timing engine
348*projectZ1-569h px� 
�
$Parsing XDC File [%s] for cell '%s'
848*designutils2�
�/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.gen/sources_1/ip/clk_wiz_0/clk_wiz_0/clk_wiz_0_in_context.xdc2	
mmcm0	8Z20-848h px� 
�
-Finished Parsing XDC File [%s] for cell '%s'
847*designutils2�
�/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.gen/sources_1/ip/clk_wiz_0/clk_wiz_0/clk_wiz_0_in_context.xdc2	
mmcm0	8Z20-847h px� 
�
Parsing XDC File [%s]
179*designutils2l
h/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/constrs_1/new/pinout.xdc8Z20-179h px� 
�
Finished Parsing XDC File [%s]
178*designutils2l
h/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/constrs_1/new/pinout.xdc8Z20-178h px� 
�
�Implementation specific constraints were found while reading constraint file [%s]. These constraints will be ignored for synthesis but will be used in implementation. Impacted constraints are listed in the file [%s].
233*project2j
h/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/constrs_1/new/pinout.xdc2!
.Xil/inference_top_propImpl.xdcZ1-236h px� 
H
&Completed Processing XDC Constraints

245*projectZ1-263h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
Netlist sorting complete. 2

00:00:002

00:00:002

2361.8122
0.0002
411952
49658Z17-722h px� 
l
!Unisim Transformation Summary:
%s111*project2'
%No Unisim elements were transformed.
Z1-111h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2"
 Constraint Validation Runtime : 2

00:00:002

00:00:002

2361.8122
0.0002
411952
49658Z17-722h px� 

VNo compile time benefit to using incremental synthesis; A full resynthesis will be run2353*designutilsZ20-5440h px� 
�
�Flow is switching to default flow due to incremental criteria not met. If you would like to alter this behaviour and have the flow terminate instead, please set the following parameter config_implementation {autoIncr.Synth.RejectBehavior Terminate}2229*designutilsZ20-4379h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Constraint Validation : Time (s): cpu = 00:00:06 ; elapsed = 00:00:06 . Memory (MB): peak = 2361.812 ; gain = 650.184 ; free physical = 41194 ; free virtual = 49656
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
D
%s
*synth2,
*Start Loading Part and Timing Information
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
8
%s
*synth2 
Loading part: xc7a35tcpg236-1
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Loading Part and Timing Information : Time (s): cpu = 00:00:06 ; elapsed = 00:00:06 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41194 ; free virtual = 49656
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
H
%s
*synth20
.Start Applying 'set_property' XDC Constraints
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished applying 'set_property' XDC Constraints : Time (s): cpu = 00:00:06 ; elapsed = 00:00:06 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41194 ; free virtual = 49656
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished RTL Optimization Phase 2 : Time (s): cpu = 00:00:06 ; elapsed = 00:00:06 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41192 ; free virtual = 49656
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
:
%s
*synth2"
 Start RTL Component Statistics 
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Detailed RTL Component Info : 
h p
x
� 
(
%s
*synth2
+---Adders : 
h p
x
� 
F
%s
*synth2.
,	   2 Input    3 Bit       Adders := 1     
h p
x
� 
+
%s
*synth2
+---Registers : 
h p
x
� 
H
%s
*synth20
.	                8 Bit    Registers := 3     
h p
x
� 
H
%s
*synth20
.	                3 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	                1 Bit    Registers := 8     
h p
x
� 
'
%s
*synth2
+---Muxes : 
h p
x
� 
F
%s
*synth2.
,	   2 Input    8 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   2 Input    7 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   4 Input    1 Bit        Muxes := 4     
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
=
%s
*synth2%
#Finished RTL Component Statistics 
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
6
%s
*synth2
Start Part Resource Summary
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
p
%s
*synth2X
VPart Resources:
DSPs: 90 (col length:60)
BRAMs: 100 (col length: RAMB18 60 RAMB36 30)
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Finished Part Resource Summary
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
E
%s
*synth2-
+Start Cross Boundary and Area Optimization
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
H
&Parallel synthesis criteria is not met4829*oasysZ8-7080h px� 
m
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led[1]2
1Z8-3917h px� 
m
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led[0]2
1Z8-3917h px� 
l
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led_r2
1Z8-3917h px� 
l
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led_g2
1Z8-3917h px� 
l
+design %s has port %s driven by constant %s3447*oasys2
inference_top2
led_b2
0Z8-3917h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
spi0/dout_sr_reg[7]/Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
spi0/dout_sr_reg[6]/Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
spi0/dout_sr_reg[5]/Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
spi0/dout_sr_reg[4]/Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
spi0/dout_sr_reg[3]/Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
spi0/dout_sr_reg[2]/Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
spi0/dout_sr_reg[1]/Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
spi0/dout_sr_reg[0]/Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
928@Z8-6858h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Cross Boundary and Area Optimization : Time (s): cpu = 00:00:07 ; elapsed = 00:00:07 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49658
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
@
%s
*synth2(
&Start Applying XDC Timing Constraints
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Applying XDC Timing Constraints : Time (s): cpu = 00:00:09 ; elapsed = 00:00:09 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41189 ; free virtual = 49656
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
4
%s
*synth2
Start Timing Optimization
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Timing Optimization : Time (s): cpu = 00:00:09 ; elapsed = 00:00:09 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41189 ; free virtual = 49656
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
3
%s
*synth2
Start Technology Mapping
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Technology Mapping : Time (s): cpu = 00:00:09 ; elapsed = 00:00:09 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41189 ; free virtual = 49656
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
-
%s
*synth2
Start IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
?
%s
*synth2'
%Start Flattening Before IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
B
%s
*synth2*
(Finished Flattening Before IO Insertion
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
6
%s
*synth2
Start Final Netlist Cleanup
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Finished Final Netlist Cleanup
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished IO Insertion : Time (s): cpu = 00:00:11 ; elapsed = 00:00:11 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49657
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
=
%s
*synth2%
#Start Renaming Generated Instances
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Instances : Time (s): cpu = 00:00:11 ; elapsed = 00:00:11 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49657
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
:
%s
*synth2"
 Start Rebuilding User Hierarchy
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Rebuilding User Hierarchy : Time (s): cpu = 00:00:11 ; elapsed = 00:00:11 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49657
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Start Renaming Generated Ports
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Ports : Time (s): cpu = 00:00:11 ; elapsed = 00:00:11 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49657
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
;
%s
*synth2#
!Start Handling Custom Attributes
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Handling Custom Attributes : Time (s): cpu = 00:00:11 ; elapsed = 00:00:11 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49657
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
8
%s
*synth2 
Start Renaming Generated Nets
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Renaming Generated Nets : Time (s): cpu = 00:00:11 ; elapsed = 00:00:11 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49657
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
9
%s
*synth2!
Start Writing Synthesis Report
h p
x
� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
/
%s
*synth2

Report BlackBoxes: 
h p
x
� 
=
%s
*synth2%
#+------+--------------+----------+
h p
x
� 
=
%s
*synth2%
#|      |BlackBox name |Instances |
h p
x
� 
=
%s
*synth2%
#+------+--------------+----------+
h p
x
� 
=
%s
*synth2%
#|1     |clk_wiz_0     |         1|
h p
x
� 
=
%s
*synth2%
#+------+--------------+----------+
h p
x
� 
/
%s*synth2

Report Cell Usage: 
h px� 
3
%s*synth2
+------+--------+------+
h px� 
3
%s*synth2
|      |Cell    |Count |
h px� 
3
%s*synth2
+------+--------+------+
h px� 
3
%s*synth2
|1     |clk_wiz |     1|
h px� 
3
%s*synth2
|2     |OBUF    |     6|
h px� 
3
%s*synth2
+------+--------+------+
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Writing Synthesis Report : Time (s): cpu = 00:00:11 ; elapsed = 00:00:11 . Memory (MB): peak = 2369.816 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49657
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
a
%s
*synth2I
GSynthesis finished with 0 errors, 24 critical warnings and 6 warnings.
h p
x
� 
�
%s
*synth2�
�Synthesis Optimization Runtime : Time (s): cpu = 00:00:10 ; elapsed = 00:00:11 . Memory (MB): peak = 2369.816 ; gain = 514.438 ; free physical = 41190 ; free virtual = 49657
h p
x
� 
�
%s
*synth2�
�Synthesis Optimization Complete : Time (s): cpu = 00:00:11 ; elapsed = 00:00:12 . Memory (MB): peak = 2369.824 ; gain = 658.188 ; free physical = 41190 ; free virtual = 49657
h p
x
� 
B
 Translating synthesized netlist
350*projectZ1-571h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
Netlist sorting complete. 2

00:00:002

00:00:002

2369.8242
0.0002
412522
49720Z17-722h px� 
K
)Preparing netlist for logic optimization
349*projectZ1-570h px� 
Q
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02
0Z31-138h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
Netlist sorting complete. 2

00:00:002

00:00:002

2369.8242
0.0002
414652
49932Z17-722h px� 
l
!Unisim Transformation Summary:
%s111*project2'
%No Unisim elements were transformed.
Z1-111h px� 
V
%Synth Design complete | Checksum: %s
562*	vivadotcl2

3064e8b7Z4-1430h px� 
C
Releasing license: %s
83*common2
	SynthesisZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
332
1192
242
0Z4-41h px� 
L
%s completed successfully
29*	vivadotcl2
synth_designZ4-42h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
synth_design: 2

00:00:152

00:00:142

2369.8242	
951.2662
414662
49933Z17-722h px� 
�
%s peak %s Memory [%s] %s12246*common2
synth_design2

Physical2
PSS2=
;(MB): overall = 1866.220; main = 1524.030; forked = 391.301Z17-2834h px� 
�
%s peak %s Memory [%s] %s12246*common2
synth_design2	
Virtual2
VSS2>
<(MB): overall = 3401.090; main = 2369.820; forked = 1031.270Z17-2834h px� 
c
%s6*runtcl2G
ESynthesis results are not added to the cache due to CRITICAL_WARNING
h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
Write ShapeDB Complete: 2

00:00:002

00:00:002

2393.8282
0.0002
414662
49933Z17-722h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2k
i/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.runs/synth_1/inference_top.dcpZ17-1381h px� 
�
Executing command : %s
56330*	planAhead2e
creport_utilization -file inference_top_utilization_synth.rpt -pb inference_top_utilization_synth.pbZ12-24828h px� 
\
Exiting %s at %s...
206*common2
Vivado2
Sun Nov 17 21:13:52 2024Z17-206h px� 


End Record