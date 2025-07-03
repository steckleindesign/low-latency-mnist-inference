`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module s2_ram_c3(
    input  logic       clk,
    input  logic       rst,
    input  logic       din_valid,
    input  logic [7:0] din[0:5],
    input  logic       dout_valid,
    output logic [7:0] dout[0:5]
);

    logic [7:0] c3_feature_ram[0:5][0:14*14-1];
    logic [$clog2(14*14)-1:0] c3_feature_ram_addr;
    
    // 6xBRAM -> RAMB18E1 2k x 9
    logic [$clog2(14*14)-1:0] c3_feature_ram_wraddr;
    logic [$clog2(14*14)-1:0] c3_feature_ram_rdaddr;
    // logic                     c3_feature_ram_en;
    logic                     c3_feature_ram_wen;
    logic                     c3_feature_ram_rden;
    logic               [7:0] c3_feature_ram_din;
    logic               [7:0] c3_feature_ram_dout;
    
    always_comb begin
        c3_feature_ram_wen <= din_valid;
        c3_feature_ram_din <= din;
        
        
        dout <= c3_feature_ram_dout;
        
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            
        end else begin
            if (c3_feature_ram_wen) begin
                c3_feature_ram[c3_feature_ram_wraddr] <= c3_feature_ram_din;
            end
            if (c3_feature_ram_dout) begin
                c3_feature_ram_dout <= c3_feature_ram[c3_feature_ram_rdaddr];
            end
        end
    end

endmodule