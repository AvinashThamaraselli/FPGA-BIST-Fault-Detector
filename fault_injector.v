module fault_injector (
    input  wire [7:0] data_in,
    input  wire       fault_enable,
    input  wire [1:0] fault_type,
    input  wire [2:0] fault_bit,

    output reg  [7:0] data_out
);

    always @(*) begin
        data_out = data_in;

        if (fault_enable) begin
            case (fault_type)
                2'b00: begin
                    data_out = data_in;
                end
                2'b01: begin
                    data_out[fault_bit] = 1'b0;
                end
                2'b10: begin
                    data_out[fault_bit] = 1'b1;
                end
                2'b11: begin
                    data_out[fault_bit] = ~data_in[fault_bit];
                end
                default: begin
                    data_out = data_in;
                end
            endcase
        end
    end

endmodule