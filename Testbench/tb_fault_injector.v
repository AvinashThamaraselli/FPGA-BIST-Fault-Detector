`timescale 1ns/1ps

module tb_fault_injector;

    reg  [7:0] data_in;
    reg        fault_enable;
    reg  [1:0] fault_type;
    reg  [2:0] fault_bit;

    wire [7:0] data_out;

    fault_injector uut (
        .data_in(data_in),
        .fault_enable(fault_enable),
        .fault_type(fault_type),
        .fault_bit(fault_bit),
        .data_out(data_out)
    );

    initial begin
        data_in      = 8'b10110110;
        fault_enable = 1'b0;
        fault_type   = 2'b00;
        fault_bit    = 3'd3;

        #10;

        $display("--------------------------------");
        $display("FAULT INJECTOR TEST");
        $display("--------------------------------");

        $display("NORMAL      : IN=%b OUT=%b", data_in, data_out);

        fault_enable = 1'b1;
        fault_type   = 2'b01;
        fault_bit    = 3'd3;
        #10;
        $display("STUCK-AT-0  : IN=%b OUT=%b", data_in, data_out);

        fault_type = 2'b10;
        #10;
        $display("STUCK-AT-1  : IN=%b OUT=%b", data_in, data_out);

        fault_type = 2'b11;
        #10;
        $display("INVERSION   : IN=%b OUT=%b", data_in, data_out);

        $display("--------------------------------");
        $display("FAULT INJECTOR TEST COMPLETE");
        $display("--------------------------------");

        $finish;
    end

endmodule
