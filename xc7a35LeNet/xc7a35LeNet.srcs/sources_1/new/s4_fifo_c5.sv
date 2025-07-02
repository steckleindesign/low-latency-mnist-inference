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
    
    always_ff @(posedge clk) begin
        if (rst) begin
            data_cnt <= 0;
        end else begin
            if (din_valid) begin
                data_sr <= din;
                data_cnt <= data_cnt + 1;
            end else begin
                data_sr <= {data_sr[0:14], 8'b0};
            end
        end
    end
    
    
    
ENTITY fifo_generator_0 IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC;
    prog_empty : OUT STD_LOGIC
  );
    
     fifo_generator_0 c5_fifo (.clk(clk),
                               .rst(),
                               .din(),
                               .wr_en(),
                               .rd_en(),
                               .dout(),
                               .full(),
                               .empty(),
                               .valid(),
                               .prog_full(),
                               .prog_empty());

    
    
    // logic [7:0] data_mem[0:16*5*5-1];


endmodule