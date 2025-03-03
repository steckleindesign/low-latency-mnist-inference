`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module tb_pool1;

    logic clk;
    logic rst;
    logic valid_in;
    logic signed [15:0] features_in[0:5];
    logic valid_out;
    logic signed [15:0] features_out[0:5];
    
    pool uut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .features_in(features_in),
        .valid_out(valid_out),
        .features_out(features_out)
    );

    always #5 clk = ~clk;

    logic signed [15:0] feature_maps [0:5][0:27][0:27];

    initial
        for (int f = 0; f < 6; f++)
            for (int r = 0; r < 28; r++)
                for (int c = 0; c < 28; c++)
                    feature_maps[f][r][c] = $random % 65536;

    // Simulation process
    initial begin
        clk = 0;
        rst = 1;
        valid_in = 0;
        features_in = '{default: 0};
        
        #20;
        
        rst = 0;
        
        #10;
        
        for (int r = 0; r < 28; r++) begin
            for (int c = 0; c < 28; c++) begin
                valid_in = 1;
                for (int f = 0; f < 6; f++)
                    features_in[f] = feature_maps[f][r][c];
                #10;
            end
        end

        valid_in = 0;
        #100;

        $stop;
    end
endmodule