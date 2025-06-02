`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
    Connections (# of * ops): 84 * 10 = 840
    
    Trainable parameters = (84 + 1) * 10 = 850
    
    @ 90 DSPs, 840 / 90 = 10 clock cycles
    
    We will have a remainder of 60 DSPs, the last cycle.
    What can we do to be more efficient with the DSPs?
    Perhaps some operations for the next conv1 layer? - minimal pipelining could help throughout slightly
    
    We could also just allocate 1 DSP per feature so 6 DSPs would just be unused
    
    Adder trees: 85 operands, $clog2(85) = 7 clock cycles, latency of layer should be 17 clock cycles
*/

//////////////////////////////////////////////////////////////////////////////////

module output_fc(
    
)(
    
);
endmodule
