
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
375078Z8-7075h px� 
�
%s*synth2�
�Starting RTL Elaboration : Time (s): cpu = 00:00:02 ; elapsed = 00:00:02 . Memory (MB): peak = 2124.711 ; gain = 412.746 ; free physical = 38809 ; free virtual = 51570
h px� 
�
.identifier '%s' is used before its declaration4750*oasys2
	ACC_WIDTH2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
168@Z8-6901h px� 
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
	spi_pixel2
wire2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
1278@Z8-11241h px� 
�
5undeclared symbol '%s', assumed default net type '%s'7502*oasys2
spi_pixel_valid2
wire2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
1288@Z8-11241h px� 
�
synthesizing module '%s'%s4497*oasys2
inference_top2
 2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
618@Z8-6157h px� 
�
synthesizing module '%s'%s4497*oasys2
	clk_wiz_02
 2�
�/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.runs/synth_1/.Xil/Vivado-375042-fpgadev/realtime/clk_wiz_0_stub.v2
68@Z8-6157h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
	clk_wiz_02
 2
02
12�
�/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.runs/synth_1/.Xil/Vivado-375042-fpgadev/realtime/clk_wiz_0_stub.v2
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
1138@Z8-155h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
spi_interface2
 2
02
12r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/spi_interface.sv2
118@Z8-6155h px� 
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
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
12	
o_pixel2
82
pixel_curation2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
1278@Z8-689h px� 
�
synthesizing module '%s'%s4497*oasys2
conv2
 2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
88@Z8-6157h px� 
^
%s
*synth2F
D	Parameter WEIGHTS_FILE bound to: conv1_weights.mem - type: string 
h p
x
� 
\
%s
*synth2D
B	Parameter BIASES_FILE bound to: conv1_biases.mem - type: string 
h p
x
� 
O
%s
*synth27
5	Parameter INPUT_WIDTH bound to: 32 - type: integer 
h p
x
� 
P
%s
*synth28
6	Parameter INPUT_HEIGHT bound to: 32 - type: integer 
h p
x
� 
N
%s
*synth26
4	Parameter FILTER_SIZE bound to: 5 - type: integer 
h p
x
� 
N
%s
*synth26
4	Parameter NUM_FILTERS bound to: 6 - type: integer 
h p
x
� 
�
%s, ignoring3604*oasys2~
|could not open $readmem data file 'conv1_weights.mem'; please make sure the file is added to project and has read permission2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
338@Z8-4445h px� 
�
%s, ignoring3604*oasys2}
{could not open $readmem data file 'conv1_biases.mem'; please make sure the file is added to project and has read permission2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
378@Z8-4445h px� 
�
default block is never used226*oasys2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
748@Z8-226h px� 
�
-case statement is not full and has no default155*oasys2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1028@Z8-155h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
conv2
 2
02
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
88@Z8-6155h px� 
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
12
	i_feature2
82
conv2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
1448@Z8-689h px� 
�
synthesizing module '%s'%s4497*oasys2
pool2
 2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
68@Z8-6157h px� 
O
%s
*synth27
5	Parameter INPUT_WIDTH bound to: 28 - type: integer 
h p
x
� 
P
%s
*synth28
6	Parameter INPUT_HEIGHT bound to: 28 - type: integer 
h p
x
� 
O
%s
*synth27
5	Parameter NUM_CHANNELS bound to: 6 - type: integer 
h p
x
� 
L
%s
*synth24
2	Parameter POOL_SIZE bound to: 2 - type: integer 
h p
x
� 
I
%s
*synth21
/	Parameter STRIDE bound to: 2 - type: integer 
h p
x
� 
�
default block is never used226*oasys2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
458@Z8-226h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
pool2
 2
02
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
68@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
conv__parameterized02
 2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
88@Z8-6157h px� 
^
%s
*synth2F
D	Parameter WEIGHTS_FILE bound to: conv2_weights.mem - type: string 
h p
x
� 
\
%s
*synth2D
B	Parameter BIASES_FILE bound to: conv2_biases.mem - type: string 
h p
x
� 
O
%s
*synth27
5	Parameter INPUT_WIDTH bound to: 14 - type: integer 
h p
x
� 
P
%s
*synth28
6	Parameter INPUT_HEIGHT bound to: 14 - type: integer 
h p
x
� 
N
%s
*synth26
4	Parameter FILTER_SIZE bound to: 5 - type: integer 
h p
x
� 
O
%s
*synth27
5	Parameter NUM_FILTERS bound to: 16 - type: integer 
h p
x
� 
�
%s, ignoring3604*oasys2~
|could not open $readmem data file 'conv2_weights.mem'; please make sure the file is added to project and has read permission2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
338@Z8-4445h px� 
�
%s, ignoring3604*oasys2}
{could not open $readmem data file 'conv2_biases.mem'; please make sure the file is added to project and has read permission2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
378@Z8-4445h px� 
�
default block is never used226*oasys2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
748@Z8-226h px� 
�
-case statement is not full and has no default155*oasys2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1028@Z8-155h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
conv__parameterized02
 2
02
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
88@Z8-6155h px� 
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
162
	i_feature2
82
conv__parameterized02r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
1758@Z8-689h px� 
�
synthesizing module '%s'%s4497*oasys2
pool__parameterized02
 2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
68@Z8-6157h px� 
O
%s
*synth27
5	Parameter INPUT_WIDTH bound to: 28 - type: integer 
h p
x
� 
P
%s
*synth28
6	Parameter INPUT_HEIGHT bound to: 28 - type: integer 
h p
x
� 
P
%s
*synth28
6	Parameter NUM_CHANNELS bound to: 16 - type: integer 
h p
x
� 
L
%s
*synth24
2	Parameter POOL_SIZE bound to: 2 - type: integer 
h p
x
� 
I
%s
*synth21
/	Parameter STRIDE bound to: 2 - type: integer 
h p
x
� 
�
default block is never used226*oasys2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
458@Z8-226h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
pool__parameterized02
 2
02
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
68@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
fc2
 2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
38@Z8-6157h px� 
\
%s
*synth2D
B	Parameter WEIGHTS_FILE bound to: fc1_weights.mem - type: string 
h p
x
� 
Z
%s
*synth2B
@	Parameter BIASES_FILE bound to: fc1_biases.mem - type: string 
h p
x
� 
Q
%s
*synth29
7	Parameter FEATURE_WIDTH bound to: 16 - type: integer 
h p
x
� 
Q
%s
*synth29
7	Parameter NUM_FEATURES bound to: 400 - type: integer 
h p
x
� 
P
%s
*synth28
6	Parameter NUM_NEURONS bound to: 120 - type: integer 
h p
x
� 
�
%s, ignoring3604*oasys2|
zcould not open $readmem data file 'fc1_weights.mem'; please make sure the file is added to project and has read permission2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
268@Z8-4445h px� 
�
%s, ignoring3604*oasys2{
ycould not open $readmem data file 'fc1_biases.mem'; please make sure the file is added to project and has read permission2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
308@Z8-4445h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
fc2
 2
02
12g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
38@Z8-6155h px� 
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
422

o_neuron2
412
fc2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
2078@Z8-689h px� 
�
synthesizing module '%s'%s4497*oasys2
fc__parameterized02
 2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
38@Z8-6157h px� 
X
%s
*synth2@
>	Parameter WEIGHTS_FILE bound to: fc2_weights - type: string 
h p
x
� 
Z
%s
*synth2B
@	Parameter BIASES_FILE bound to: fc2_biases.mem - type: string 
h p
x
� 
Q
%s
*synth29
7	Parameter FEATURE_WIDTH bound to: 41 - type: integer 
h p
x
� 
Q
%s
*synth29
7	Parameter NUM_FEATURES bound to: 120 - type: integer 
h p
x
� 
O
%s
*synth27
5	Parameter NUM_NEURONS bound to: 84 - type: integer 
h p
x
� 
�
%s, ignoring3604*oasys2x
vcould not open $readmem data file 'fc2_weights'; please make sure the file is added to project and has read permission2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
268@Z8-4445h px� 
�
%s, ignoring3604*oasys2{
ycould not open $readmem data file 'fc2_biases.mem'; please make sure the file is added to project and has read permission2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
308@Z8-4445h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
fc__parameterized02
 2
02
12g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
38@Z8-6155h px� 
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
422
	i_feature2
162
fc__parameterized02r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
2208@Z8-689h px� 
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
422

o_neuron2
642
fc__parameterized02r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
2228@Z8-689h px� 
�
synthesizing module '%s'%s4497*oasys2
output_layer2
 2q
m/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/output_layer.sv2
38@Z8-6157h px� 
\
%s
*synth2D
B	Parameter WEIGHTS_FILE bound to: fc3_weights.mem - type: string 
h p
x
� 
Z
%s
*synth2B
@	Parameter BIASES_FILE bound to: fc3_biases.mem - type: string 
h p
x
� 
Q
%s
*synth29
7	Parameter FEATURE_WIDTH bound to: 48 - type: integer 
h p
x
� 
P
%s
*synth28
6	Parameter NUM_FEATURES bound to: 84 - type: integer 
h p
x
� 
O
%s
*synth27
5	Parameter NUM_CLASSES bound to: 10 - type: integer 
h p
x
� 
�
%s, ignoring3604*oasys2|
zcould not open $readmem data file 'fc3_weights.mem'; please make sure the file is added to project and has read permission2q
m/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/output_layer.sv2
288@Z8-4445h px� 
�
%s, ignoring3604*oasys2{
ycould not open $readmem data file 'fc3_biases.mem'; please make sure the file is added to project and has read permission2q
m/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/output_layer.sv2
328@Z8-4445h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
output_layer2
 2
02
12q
m/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/output_layer.sv2
38@Z8-6155h px� 
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
422
	i_feature2
162
output_layer2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
2358@Z8-689h px� 
�
Pwidth (%s) of port connection '%s' does not match port width (%s) of module '%s'689*oasys2
82

o_logits2
42
output_layer2r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
2428@Z8-689h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
inference_top2
 2
02
12r
n/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/inference_top.sv2
618@Z8-6155h px� 
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
1118@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
o_pix_valid_reg2
pixel_curation2s
o/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pixel_curation.sv2
348@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
o_pixel_reg2
pixel_curation2s
o/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pixel_curation.sv2
428@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
o_feature_reg2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1198@Z8-7137h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][27][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][27][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][27][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][27][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][27][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][27][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][26][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][26][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][26][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][26][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][26][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][26][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][25][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][25][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][25][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][25][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][25][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][25][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][24][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][24][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][24][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][24][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][24][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][24][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][23][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][23][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][23][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][23][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][23][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][23][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][22][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][22][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][22][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][22][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][22][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][22][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][21][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][21][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][21][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][21][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][21][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][21][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][20][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][20][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][20][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][20][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][20][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][20][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][19][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][19][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][19][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][19][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][19][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][19][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][18][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][18][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][18][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][18][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][18][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][18][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][17][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][17][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][17][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][17][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][17][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][17][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][16][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][16][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][16][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][16][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][16][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][16][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][15][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][15][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][15][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][15][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][15][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][15][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][14][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][14][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][14][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][14][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][14][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][14][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][13][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][13][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][13][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][13][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][13][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][13][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][12][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][12][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][12][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][12][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[1][12][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[0][12][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[5][11][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[4][11][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[3][11][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
0Net %s in module/entity %s does not have driver.3422*oasys2
weights[2][11][27]2
conv2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
328@Z8-3848h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2
Synth 8-38482
100Z17-14h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2
pool_reg[3]2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
598@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2

max_ab_reg2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
708@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2

max_cd_reg2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
718@Z8-6014h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
o_feature_reg2
pool2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/pool.sv2
728@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
o_feature_reg2
conv__parameterized02i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1198@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
feature_ctr_reg2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
768@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
neuron_ctr_reg2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
778@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[119]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[118]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[117]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[116]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[115]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[114]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[113]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[112]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[111]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[110]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[109]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[108]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[107]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[106]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[105]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[104]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[103]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[102]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[101]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[100]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[99]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[98]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[97]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[96]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[95]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[94]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[93]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[92]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[91]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[90]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[89]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[88]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[87]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[86]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[85]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[84]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[83]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[82]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[81]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[80]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[79]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[78]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[77]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[76]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[75]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[74]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[73]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[72]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[71]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[70]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[69]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[68]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[67]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[66]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[65]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[64]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[63]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[62]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[61]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[60]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[59]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[58]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[57]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[56]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[55]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[54]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[53]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[52]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[51]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[50]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[49]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[48]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[47]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[46]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[45]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[44]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[43]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[42]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[41]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[40]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[39]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[38]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[37]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[36]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[35]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[34]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[33]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[32]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[31]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[30]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Register %s in module %s has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code 
4878*oasys2
acc_reg[29]2
fc2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
908@Z8-7137h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2
Synth 8-71372
100Z17-14h px� 
�
9always_comb on '%s' did not result in combinational logic87*oasys2
next_state_reg2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
628@Z8-87h px� 
�
9always_comb on '%s' did not result in combinational logic87*oasys2
next_state_reg2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
628@Z8-87h px� 
�
9always_comb on '%s' did not result in combinational logic87*oasys2
next_state_reg2q
m/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/output_layer.sv2
628@Z8-87h px� 
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
%s*synth2�
�Finished RTL Elaboration : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 3092.344 ; gain = 1380.379 ; free physical = 37796 ; free virtual = 50569
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
�Finished Handling Custom Attributes : Time (s): cpu = 00:00:29 ; elapsed = 00:00:32 . Memory (MB): peak = 3092.344 ; gain = 1380.379 ; free physical = 37834 ; free virtual = 50607
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
�Finished RTL Optimization Phase 1 : Time (s): cpu = 00:00:29 ; elapsed = 00:00:32 . Memory (MB): peak = 3092.344 ; gain = 1380.379 ; free physical = 37834 ; free virtual = 50607
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

00:00:00.22
00:00:00.212

3092.3442
0.0002
378342
50607Z17-722h px� 
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

3349.1882
0.0002
377032
50476Z17-722h px� 
l
!Unisim Transformation Summary:
%s111*project2'
%No Unisim elements were transformed.
Z1-111h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2"
 Constraint Validation Runtime : 2
00:00:00.052
00:00:00.052

3361.1092
0.0082
377032
50476Z17-722h px� 
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
�Finished Constraint Validation : Time (s): cpu = 00:00:41 ; elapsed = 00:00:42 . Memory (MB): peak = 3361.109 ; gain = 1649.145 ; free physical = 36029 ; free virtual = 48802
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
�Finished Loading Part and Timing Information : Time (s): cpu = 00:00:41 ; elapsed = 00:00:42 . Memory (MB): peak = 3369.113 ; gain = 1657.148 ; free physical = 36021 ; free virtual = 48795
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
�Finished applying 'set_property' XDC Constraints : Time (s): cpu = 00:00:41 ; elapsed = 00:00:42 . Memory (MB): peak = 3369.113 ; gain = 1657.148 ; free physical = 36043 ; free virtual = 48817
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_value_reg2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1698@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
weight_value_reg2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1718@Z8-3936h px� 
m
3inferred FSM for state register '%s' in module '%s'802*oasys2
curr_state_reg2
convZ8-802h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_value_reg2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1698@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
weight_value_reg2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1718@Z8-3936h px� 
}
3inferred FSM for state register '%s' in module '%s'802*oasys2
curr_state_reg2
conv__parameterized0Z8-802h px� 
f
3inferred FSM for state register '%s' in module '%s'802*oasys2
	state_reg2
fcZ8-802h px� 
v
3inferred FSM for state register '%s' in module '%s'802*oasys2
	state_reg2
fc__parameterized0Z8-802h px� 
p
3inferred FSM for state register '%s' in module '%s'802*oasys2
	state_reg2
output_layerZ8-802h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_                    IDLE |                             0001 |                               00
h p
x
� 
y
%s
*synth2a
_             LOAD_WINDOW |                             0010 |                               01
h p
x
� 
y
%s
*synth2a
_                    MACC |                             0100 |                               10
h p
x
� 
y
%s
*synth2a
_                DATA_OUT |                             1000 |                               11
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
curr_state_reg2	
one-hot2
convZ8-3354h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_                    IDLE |                             0001 |                               00
h p
x
� 
y
%s
*synth2a
_             LOAD_WINDOW |                             0010 |                               01
h p
x
� 
y
%s
*synth2a
_                    MACC |                             0100 |                               10
h p
x
� 
y
%s
*synth2a
_                DATA_OUT |                             1000 |                               11
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
curr_state_reg2	
one-hot2
conv__parameterized0Z8-3354h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_sequential_next_state_reg2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
628@Z8-327h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_onehot_next_state_reg2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
628@Z8-327h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_                    IDLE |                              001 |                               00
h p
x
� 
y
%s
*synth2a
_                    MACC |                              010 |                               01
h p
x
� 
y
%s
*synth2a
_                    SEND |                              100 |                               10
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
	state_reg2	
one-hot2
fcZ8-3354h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_onehot_next_state_reg2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
628@Z8-327h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_sequential_next_state_reg2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
628@Z8-327h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_onehot_next_state_reg2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
628@Z8-327h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_                    IDLE |                              001 |                               00
h p
x
� 
y
%s
*synth2a
_                    MACC |                              010 |                               01
h p
x
� 
y
%s
*synth2a
_                    SEND |                              100 |                               10
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
	state_reg2	
one-hot2
fc__parameterized0Z8-3354h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_onehot_next_state_reg2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
628@Z8-327h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_sequential_next_state_reg2q
m/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/output_layer.sv2
628@Z8-327h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_onehot_next_state_reg2q
m/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/output_layer.sv2
628@Z8-327h px� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
z
%s
*synth2b
`                   State |                     New Encoding |                Previous Encoding 
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
y
%s
*synth2a
_                    IDLE |                              001 |                               00
h p
x
� 
y
%s
*synth2a
_                    MACC |                              010 |                               01
h p
x
� 
y
%s
*synth2a
_                  RESULT |                              100 |                               10
h p
x
� 
~
%s
*synth2f
d---------------------------------------------------------------------------------------------------
h p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
	state_reg2	
one-hot2
output_layerZ8-3354h px� 
�
!inferring latch for variable '%s'327*oasys2
FSM_onehot_next_state_reg2q
m/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/output_layer.sv2
628@Z8-327h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished RTL Optimization Phase 2 : Time (s): cpu = 00:01:14 ; elapsed = 00:01:16 . Memory (MB): peak = 3373.199 ; gain = 1661.234 ; free physical = 33079 ; free virtual = 45865
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
,	   2 Input   71 Bit       Adders := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input   64 Bit       Adders := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input   32 Bit       Adders := 2     
h p
x
� 
F
%s
*synth2.
,	   2 Input    9 Bit       Adders := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input    7 Bit       Adders := 4     
h p
x
� 
F
%s
*synth2.
,	   2 Input    5 Bit       Adders := 4     
h p
x
� 
F
%s
*synth2.
,	   3 Input    5 Bit       Adders := 2     
h p
x
� 
F
%s
*synth2.
,	   2 Input    4 Bit       Adders := 4     
h p
x
� 
F
%s
*synth2.
,	   3 Input    4 Bit       Adders := 2     
h p
x
� 
F
%s
*synth2.
,	   2 Input    3 Bit       Adders := 4     
h p
x
� 
F
%s
*synth2.
,	   2 Input    2 Bit       Adders := 2     
h p
x
� 
F
%s
*synth2.
,	   2 Input    1 Bit       Adders := 2     
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
.	               71 Bit    Registers := 11    
h p
x
� 
H
%s
*synth20
.	               64 Bit    Registers := 85    
h p
x
� 
H
%s
*synth20
.	               41 Bit    Registers := 121   
h p
x
� 
H
%s
*synth20
.	               16 Bit    Registers := 10    
h p
x
� 
H
%s
*synth20
.	                9 Bit    Registers := 1     
h p
x
� 
H
%s
*synth20
.	                8 Bit    Registers := 239   
h p
x
� 
H
%s
*synth20
.	                7 Bit    Registers := 2     
h p
x
� 
H
%s
*synth20
.	                5 Bit    Registers := 2     
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
.	                2 Bit    Registers := 2     
h p
x
� 
H
%s
*synth20
.	                1 Bit    Registers := 31    
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
,	   2 Input   71 Bit        Muxes := 30    
h p
x
� 
F
%s
*synth2.
,	   2 Input   64 Bit        Muxes := 84    
h p
x
� 
F
%s
*synth2.
,	   2 Input   41 Bit        Muxes := 120   
h p
x
� 
F
%s
*synth2.
,	   2 Input   16 Bit        Muxes := 6     
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
,	   2 Input    5 Bit        Muxes := 3     
h p
x
� 
F
%s
*synth2.
,	   4 Input    5 Bit        Muxes := 2     
h p
x
� 
F
%s
*synth2.
,	   4 Input    4 Bit        Muxes := 3     
h p
x
� 
F
%s
*synth2.
,	   2 Input    4 Bit        Muxes := 13    
h p
x
� 
F
%s
*synth2.
,	   2 Input    3 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   4 Input    3 Bit        Muxes := 1     
h p
x
� 
F
%s
*synth2.
,	   2 Input    1 Bit        Muxes := 76    
h p
x
� 
F
%s
*synth2.
,	   4 Input    1 Bit        Muxes := 14    
h p
x
� 
F
%s
*synth2.
,	   3 Input    1 Bit        Muxes := 8     
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
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[0][0]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[1][0]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[2][0]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[3][0]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[0][1]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[1][1]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[2][1]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[3][1]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[0][2]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[1][2]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[2][2]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[3][2]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[0][3]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[1][3]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[2][3]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[3][3]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[0][4]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][0]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][1]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][2]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][3]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][4]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][5]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][6]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][7]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][8]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][9]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][10]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][11]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][12]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][13]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][14]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][15]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][16]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][17]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][18]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][19]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][20]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][21]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][22]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][23]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][24]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][25]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][26]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][27]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[4][0]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[4][1]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[4][2]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[4][3]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[1][4]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[2][4]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[3][4]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
window_reg[4][4]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1378@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][28]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][29]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][30]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[0][31]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][0]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][1]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][2]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][3]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][4]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][5]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][6]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][7]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][8]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][9]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][10]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][11]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][12]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][13]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][14]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][15]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][16]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][17]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][18]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][19]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][20]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][21]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][22]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][23]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][24]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][25]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][26]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][27]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][28]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][29]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][30]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[1][31]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[2][0]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[2][1]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[2][2]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[2][3]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[2][4]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[2][5]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
RFound unconnected internal register '%s' and it is trimmed from '%s' to '%s' bits.3455*oasys2
line_buffer_reg[2][6]2
82
12i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1428@Z8-3936h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2
Synth 8-39362
100Z17-14h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2
Synth 8-39362
100Z17-14h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][31][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][30][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][29][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][28][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][27][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][26][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][25][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][24][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][23][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][22][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][21][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][20][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][19][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][18][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][17][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][16][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][15][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][14][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][13][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][12][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][11][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][10][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][9][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][8][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][7][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][6][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][5][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][4][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][3][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][2][0]2
FDE2
line_buffer_reg[3][1][0]Z8-3886h px� 
{
6propagating constant %s across sequential element (%s)3333*oasys2
02
\line_buffer_reg[3][1][0] Z8-3333h px� 
~
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[3][0][0]2
FDE2
window_reg[4][4][0]Z8-3886h px� 
~
"merging instance '%s' (%s) to '%s'3436*oasys2
window_reg[3][4][0]2
FDE2
line_buffer_reg[2][0][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][31][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][30][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][29][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][28][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][27][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][26][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][25][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][24][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][23][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][22][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][21][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][20][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][19][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][18][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][17][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][16][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][15][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][14][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][13][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][12][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][11][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][10][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][9][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][8][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][7][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][6][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][5][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][4][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][3][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][2][0]2
FDE2
line_buffer_reg[2][1][0]Z8-3886h px� 
{
6propagating constant %s across sequential element (%s)3333*oasys2
02
\line_buffer_reg[2][1][0] Z8-3333h px� 
~
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[2][0][0]2
FDE2
window_reg[4][3][0]Z8-3886h px� 
y
"merging instance '%s' (%s) to '%s'3436*oasys2
window_reg[3][3][0]2
FDE2
window_reg[2][4][0]Z8-3886h px� 
~
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][0][0]2
FDE2
window_reg[2][4][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][2][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][4][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][6][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][8][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][10][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][12][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][14][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][16][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][18][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][20][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][22][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][24][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][26][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][28][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][30][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
y
"merging instance '%s' (%s) to '%s'3436*oasys2
window_reg[2][4][0]2
FDE2
window_reg[4][2][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][31][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][29][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][27][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][25][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][23][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][21][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][19][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][17][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][15][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][13][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][11][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][9][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][7][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][5][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[1][3][0]2
FDE2
line_buffer_reg[1][1][0]Z8-3886h px� 
{
6propagating constant %s across sequential element (%s)3333*oasys2
02
\line_buffer_reg[1][1][0] Z8-3333h px� 
y
"merging instance '%s' (%s) to '%s'3436*oasys2
window_reg[3][2][0]2
FDE2
window_reg[2][3][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[0][27][0]2
FDE2
line_buffer_reg[0][26][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[0][26][0]2
FDE2
line_buffer_reg[0][25][0]Z8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2
line_buffer_reg[0][25][0]2
FDE2
line_buffer_reg[0][24][0]Z8-3886h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2
Synth 8-38862
100Z17-14h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2
Synth 8-38862
100Z17-14h px� 
|
6propagating constant %s across sequential element (%s)3333*oasys2
02
\line_buffer_reg[0][29][0] Z8-3333h px� 
q
6propagating constant %s across sequential element (%s)3333*oasys2
02
window_valid_regZ8-3333h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
row_ctr_reg[4]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
row_ctr_reg[3]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
row_ctr_reg[2]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
row_ctr_reg[1]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
row_ctr_reg[0]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
col_ctr_reg[4]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
col_ctr_reg[3]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
col_ctr_reg[2]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
col_ctr_reg[1]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
col_ctr_reg[0]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
v
6propagating constant %s across sequential element (%s)3333*oasys2
02
\weight_value_reg[0] Z8-3333h px� 
s
6propagating constant %s across sequential element (%s)3333*oasys2
02
\o_feature_reg[0] Z8-3333h px� 
X
%s
*synth2@
>DSP Report: Generating DSP p_1_out, operation Mode is: C+A*B.
h p
x
� 
U
%s
*synth2=
;DSP Report: operator p_1_out is absorbed into DSP p_1_out.
h p
x
� 
U
%s
*synth2=
;DSP Report: operator p_0_out is absorbed into DSP p_1_out.
h p
x
� 
V
%s
*synth2>
<DSP Report: Generating DSP p_0_out, operation Mode is: A*B.
h p
x
� 
U
%s
*synth2=
;DSP Report: operator p_0_out is absorbed into DSP p_0_out.
h p
x
� 
V
%s
*synth2>
<DSP Report: Generating DSP p_0_out, operation Mode is: A*B.
h p
x
� 
U
%s
*synth2=
;DSP Report: operator p_0_out is absorbed into DSP p_0_out.
h p
x
� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
i_feature[7]2
conv__parameterized0Z8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
i_feature[6]2
conv__parameterized0Z8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
i_feature[5]2
conv__parameterized0Z8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
i_feature[4]2
conv__parameterized0Z8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
i_feature[3]2
conv__parameterized0Z8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
i_feature[2]2
conv__parameterized0Z8-7129h px� 
�
9Port %s in module %s is either unconnected or has no load4866*oasys2
i_feature[1]2
conv__parameterized0Z8-7129h px� 
}
6propagating constant %s across sequential element (%s)3333*oasys2
02
conv_2/\weight_value_reg[0] Z8-3333h px� 
x
6propagating constant %s across sequential element (%s)3333*oasys2
02
conv_2/window_valid_regZ8-3333h px� 
{
6propagating constant %s across sequential element (%s)3333*oasys2
02
conv_2/\o_feature_reg[15] Z8-3333h px� 

6propagating constant %s across sequential element (%s)3333*oasys2
02 
\max_pool_2/o_feature_reg[15] Z8-3333h px� 
�
ESequential element (%s) is unused and will be removed from module %s.3332*oasys2
FSM_onehot_curr_state_reg[1]2
conv__parameterized0Z8-3332h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/col_ctr_reg[3]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/col_ctr_reg[2]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/col_ctr_reg[1]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/col_ctr_reg[0]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
978@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/row_ctr_reg[3]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/row_ctr_reg[2]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/row_ctr_reg[1]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/row_ctr_reg[0]__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
968@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
conv_2/mac_accum_reg__0/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1008@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1008@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1008@Z8-6858h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Cross Boundary and Area Optimization : Time (s): cpu = 00:02:05 ; elapsed = 00:02:08 . Memory (MB): peak = 3385.125 ; gain = 1673.160 ; free physical = 31912 ; free virtual = 45027
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
]
%s
*synth2E
C Sort Area is fc__GB31 p_1_out_0 : 0 0 : 2068 2068 : Used 1 time 0
h p
x
� 
m
%s
*synth2U
S Sort Area is fc__parameterized0__GB14 p_0_out_0 : 0 0 : 1946 1946 : Used 1 time 0
h p
x
� 
f
%s
*synth2N
L Sort Area is output_layer__GB1 p_0_out_0 : 0 0 : 1946 1946 : Used 1 time 0
h p
x
� 
�
%s*synth2�
�---------------------------------------------------------------------------------
Start ROM, RAM, DSP, Shift Register and Retiming Reporting
h px� 
l
%s*synth2T
R---------------------------------------------------------------------------------
h px� 
v
%s*synth2^
\
DSP: Preliminary Mapping Report (see note below. The ' indicates corresponding REG is set)
h px� 
�
%s*synth2
}+-------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
h px� 
�
%s*synth2�
~|Module Name  | DSP Mapping | A Size | B Size | C Size | D Size | P Size | AREG | BREG | CREG | DREG | ADREG | MREG | PREG | 
h px� 
�
%s*synth2
}+-------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
h px� 
�
%s*synth2�
~|fc           | C+A*B       | 16     | 16     | 41     | -      | 41     | 0    | 0    | 0    | -    | -     | 0    | 0    | 
h px� 
�
%s*synth2�
~|fc           | A*B         | 16     | 16     | -      | -      | 32     | 0    | 0    | -    | -    | -     | 0    | 0    | 
h px� 
�
%s*synth2�
~|output_layer | A*B         | 16     | 16     | -      | -      | 32     | 0    | 0    | -    | -    | -     | 0    | 0    | 
h px� 
�
%s*synth2�
~+-------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+

h px� 
�
%s*synth2�
�Note: The table above is a preliminary report that shows the DSPs inferred at the current stage of the synthesis flow. Some DSP may be reimplemented as non DSP primitives later in the synthesis flow. Multiple instantiated DSPs are reported only once.
h px� 
�
%s*synth2�
�---------------------------------------------------------------------------------
Finished ROM, RAM, DSP, Shift Register and Retiming Reporting
h px� 
l
%s*synth2T
R---------------------------------------------------------------------------------
h px� 
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
�Finished Applying XDC Timing Constraints : Time (s): cpu = 00:02:09 ; elapsed = 00:02:12 . Memory (MB): peak = 3391.109 ; gain = 1679.145 ; free physical = 31860 ; free virtual = 45024
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
�Finished Timing Optimization : Time (s): cpu = 00:02:32 ; elapsed = 00:02:36 . Memory (MB): peak = 3439.141 ; gain = 1727.176 ; free physical = 31837 ; free virtual = 45008
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
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2
i_1/o_feature_valid_reg/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1808@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1808@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1808@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
1st2"
 i_0/conv_2/o_feature_valid_reg/Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1808@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2
2nd2
GND2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1808@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2i
e/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/conv.sv2
1808@Z8-6858h px� 
�
{Detected registers with asynchronous reset at DSP/BRAM block boundary. Consider using synchronous reset for optimal packing4266*oasys2g
c/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.srcs/sources_1/new/fc.sv2
1088@Z8-5844h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
�
%s*synth2�
�Finished Technology Mapping : Time (s): cpu = 00:02:34 ; elapsed = 00:02:41 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 31640 ; free virtual = 44810
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
�Finished IO Insertion : Time (s): cpu = 00:02:37 ; elapsed = 00:02:45 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 31608 ; free virtual = 44815
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
�Finished Renaming Generated Instances : Time (s): cpu = 00:02:37 ; elapsed = 00:02:45 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 31608 ; free virtual = 44815
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
�Finished Rebuilding User Hierarchy : Time (s): cpu = 00:02:37 ; elapsed = 00:02:45 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 31608 ; free virtual = 44815
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
�Finished Renaming Generated Ports : Time (s): cpu = 00:02:37 ; elapsed = 00:02:45 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 31608 ; free virtual = 44815
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
�Finished Handling Custom Attributes : Time (s): cpu = 00:02:37 ; elapsed = 00:02:45 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 31607 ; free virtual = 44814
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
�Finished Renaming Generated Nets : Time (s): cpu = 00:02:37 ; elapsed = 00:02:45 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 31607 ; free virtual = 44814
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
W
%s
*synth2?
=
DSP Final Report (the ' indicates corresponding REG is set)
h p
x
� 
�
%s
*synth2
}+-------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
h p
x
� 
�
%s
*synth2�
~|Module Name  | DSP Mapping | A Size | B Size | C Size | D Size | P Size | AREG | BREG | CREG | DREG | ADREG | MREG | PREG | 
h p
x
� 
�
%s
*synth2
}+-------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
h p
x
� 
�
%s
*synth2�
~|output_layer | A*B         | 16     | 0      | -      | -      | 32     | 0    | 0    | -    | -    | -     | 0    | 0    | 
h p
x
� 
�
%s
*synth2�
~+-------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+

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
|2     |BUFG    |     1|
h px� 
3
%s*synth2
|3     |CARRY4  |   103|
h px� 
3
%s*synth2
|4     |DSP48E1 |     1|
h px� 
3
%s*synth2
|5     |LUT1    |    17|
h px� 
3
%s*synth2
|6     |LUT2    |    98|
h px� 
3
%s*synth2
|7     |LUT3    |   450|
h px� 
3
%s*synth2
|8     |LUT4    |  1042|
h px� 
3
%s*synth2
|9     |LUT5    |    81|
h px� 
3
%s*synth2
|10    |LUT6    |  1284|
h px� 
3
%s*synth2
|11    |MUXF7   |   208|
h px� 
3
%s*synth2
|12    |MUXF8   |    64|
h px� 
3
%s*synth2
|13    |FDCE    |  2237|
h px� 
3
%s*synth2
|14    |FDPE    |     7|
h px� 
3
%s*synth2
|15    |FDRE    |     1|
h px� 
3
%s*synth2
|16    |LD      |     9|
h px� 
3
%s*synth2
|17    |IBUF    |     4|
h px� 
3
%s*synth2
|18    |OBUF    |     7|
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
�Finished Writing Synthesis Report : Time (s): cpu = 00:02:37 ; elapsed = 00:02:45 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 31607 ; free virtual = 44814
h px� 
l
%s
*synth2T
R---------------------------------------------------------------------------------
h p
x
� 
c
%s
*synth2K
ISynthesis finished with 0 errors, 63 critical warnings and 207 warnings.
h p
x
� 
�
%s
*synth2�
�Synthesis Optimization Runtime : Time (s): cpu = 00:02:32 ; elapsed = 00:02:42 . Memory (MB): peak = 3451.066 ; gain = 1470.336 ; free physical = 37426 ; free virtual = 50634
h p
x
� 
�
%s
*synth2�
�Synthesis Optimization Complete : Time (s): cpu = 00:02:39 ; elapsed = 00:02:48 . Memory (MB): peak = 3451.066 ; gain = 1739.102 ; free physical = 37443 ; free virtual = 50638
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
00:00:00.022
00:00:00.022

3451.0662
0.0002
374442
50638Z17-722h px� 
U
-Analyzing %s Unisim elements for replacement
17*netlist2
385Z29-17h px� 
X
2Unisim Transformation completed in %s CPU seconds
28*netlist2
0Z29-28h px� 
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

3495.1682
0.0002
374432
50637Z17-722h px� 
�
!Unisim Transformation Summary:
%s111*project2G
E  A total of 9 instances were transformed.
  LD => LDCE: 9 instances
Z1-111h px� 
V
%Synth Design complete | Checksum: %s
562*	vivadotcl2

fbcb6120Z4-1430h px� 
C
Releasing license: %s
83*common2
	SynthesisZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
1832
3442
732
0Z4-41h px� 
L
%s completed successfully
29*	vivadotcl2
synth_designZ4-42h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
synth_design: 2

00:02:422

00:02:512

3495.1682

2119.2112
374432
50637Z17-722h px� 
�
%s peak %s Memory [%s] %s12246*common2
synth_design2

Physical2
PSS2>
<(MB): overall = 8598.988; main = 2640.472; forked = 6132.012Z17-2834h px� 
�
%s peak %s Memory [%s] %s12246*common2
synth_design2	
Virtual2
VSS2@
>(MB): overall = 13910.672; main = 3495.172; forked = 10463.520Z17-2834h px� 
c
%s6*runtcl2G
ESynthesis results are not added to the cache due to CRITICAL_WARNING
h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
Write ShapeDB Complete: 2
00:00:00.012
00:00:00.012

3519.1802
0.0002
374432
50637Z17-722h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2k
i/home/pstecklein/repos/low-latency-mnist-inference/xc7a35LeNet/xc7a35LeNet.runs/synth_1/inference_top.dcpZ17-1381h px� 
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2
write_checkpoint: 2

00:00:052

00:00:062

3519.1802
24.0122
373272
50581Z17-722h px� 
�
Executing command : %s
56330*	planAhead2e
creport_utilization -file inference_top_utilization_synth.rpt -pb inference_top_utilization_synth.pbZ12-24828h px� 
\
Exiting %s at %s...
206*common2
Vivado2
Tue Dec 10 21:44:30 2024Z17-206h px� 


End Record