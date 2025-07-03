`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module s4_fifo_c5(
    input  logic       clk,
    input  logic       rst,
    input  logic       din_valid,
    input  logic [7:0] din[0:15],
    output logic       dout
);

    logic [$clog2(16*5*5)-1:0] data_cnt;
    logic [7:0] data_sr[0:15];
    
    logic fifo_wen;
    logic fifo_rden;
    
    logic fifo_full; // NC (no load)
    logic fifo_empty; // Could use this to signal data flow to downstream logic
    
    logic fifo_almost_full;
    logic fifo_almost_empty; // NC (no load)
    
    logic fifo_valid; // NC (no load)
    
    always_ff @(posedge clk) begin
        if (rst) begin
            data_cnt  <= 0;
            fifo_wen  <= 1;
            fifo_rden <= 1;
        end else begin
            fifo_wen  <= 0;
            fifo_rden <= 0;
            if (din_valid) begin
                data_sr <= din;
            end else begin
                data_sr <= {data_sr[0:14], 8'b0};
                data_cnt <= data_cnt + 1;
                if (data_cnt == 4'd15) begin
                    fifo_wen <= 1;
                    data_cnt <= 0;
                end
            end
            if (prog_full) fifo_rden <= 1;
            else if (fifo_empty) fifo_rden <= 0;
        end
    end
    
    // logic [7:0] data_mem[0:16*5*5-1];
    fifo_generator_0 c5_fifo (.clk(clk),                       // in
                              .rst(rst),                       // in
                              .din(data_sr[15]),               // in
                              .wr_en(fifo_wen),                // in
                              .rd_en(fifo_rden),               // in
                              .dout(dout),                     // out
                              .full(fifo_full),                // out
                              .empty(fifo_empty),              // out
                              .valid(fifo_valid),              // out
                              .prog_full(fifo_almost_full),    // out
                              .prog_empty(fifo_almost_empty)); // out

endmodule