module misr_16bit (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,

    input  wire [7:0]  data_in,

    output reg  [15:0] signature
);

    reg [15:0] next_signature;

    always @(*) begin
        next_signature = {signature[14:0], signature[15]};
        next_signature[7:0] = next_signature[7:0] ^ data_in;
        next_signature[15] = signature[15] ^ signature[13] ^ signature[12] ^ signature[10];
    end

    always @(posedge clk) begin
        if (reset)
            signature <= 16'hFFFF;
        else if (enable)
            signature <= next_signature;
    end

endmodule