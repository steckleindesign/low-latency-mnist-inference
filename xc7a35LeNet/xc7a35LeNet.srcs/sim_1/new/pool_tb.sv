`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
module tb_pool1;

    logic               clk;
    logic               rst;
    logic               valid_in;
    logic signed [15:0] features_in[0:5];
    
    logic               valid_out;
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
    logic signed [15:0] expected_out [0:5][0:13][0:13];

    initial
    begin
        for (int f = 0; f < 6; f++)
            for (int r = 0; r < 28; r++)
                for (int c = 0; c < 28; c++)
                    feature_maps[f][r][c] = $random % 65536;

        for (int f = 0; f < 6; f++)
            for (int r = 0; r < 14; r++)
                for (int c = 0; c < 14; c++)
                    expected_out[f][r][c] = max4(
                        feature_maps[f][2*r][2*c], 
                        feature_maps[f][2*r][2*c+1], 
                        feature_maps[f][2*r+1][2*c], 
                        feature_maps[f][2*r+1][2*c+1]
                    );
    end

    function automatic logic signed [15:0] max4(input logic signed [15:0] a, b, c, d);
        return (a > b ? a : b) > (c > d ? c : d) ? (a > b ? a : b) : (c > d ? c : d);
    endfunction
    
    int row_idx = 0, col_idx = 0;
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
        while (!valid_out) #10;
        
        for (int r = 0; r < 14; r++) begin
            for (int c = 0; c < 14; c++) begin
            
                while (!valid_out) #10;
                
                for (int f = 0; f < 6; f++)
                    if (features_out[f] !== expected_out[f][r][c]) begin
                        $display("ERROR: Mismatch at pooled[%0d][%0d][%0d]: Expected %d, Got %d",
                                 f, r, c, expected_out[f][r][c], features_out[f]);
                        $stop;
                    end
                
                col_idx++;
                if (col_idx == 14)
                begin
                    col_idx = 0;
                    row_idx++;
                end
            end
        end

        $display("SUCCESS: All max-pooling outputs are correct!");
        $stop;
    end
endmodule