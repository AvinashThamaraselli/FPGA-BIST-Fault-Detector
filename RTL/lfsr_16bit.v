module lfsr_16bit (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,

    output reg [15:0]  lfsr
);

    wire feedback;

    assign feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];

    always @(posedge clk) begin
        if (reset) begin
            lfsr <= 16'hACE1;
        end
        else if (enable) begin
            lfsr <= {lfsr[14:0], feedback};
        end
    end

endmodule
