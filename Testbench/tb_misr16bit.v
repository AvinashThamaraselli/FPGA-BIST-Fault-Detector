`timescale 1ns/1ps

module tb_misr_16bit;

    reg clk;
    reg reset;
    reg enable;

    reg [7:0] data_in;

    wire [15:0] signature;

    misr_16bit uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .data_in(data_in),
        .signature(signature)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        reset   = 1;
        enable  = 0;
        data_in = 8'h00;

        #20;
        reset  = 0;
        enable = 1;

        $display("--------------------------------");
        $display("MISR TEST");
        $display("--------------------------------");

        data_in = 8'hA5;
        #10;
        $display("DATA = %h | SIGNATURE = %h", data_in, signature);

        data_in = 8'h3C;
        #10;
        $display("DATA = %h | SIGNATURE = %h", data_in, signature);

        data_in = 8'hF0;
        #10;
        $display("DATA = %h | SIGNATURE = %h", data_in, signature);

        data_in = 8'h55;
        #10;
        $display("DATA = %h | SIGNATURE = %h", data_in, signature);

        data_in = 8'hAA;
        #10;
        $display("DATA = %h | SIGNATURE = %h", data_in, signature);

        $display("--------------------------------");
        $display("MISR TEST COMPLETE");
        $display("--------------------------------");

        $finish;
    end

endmodule
