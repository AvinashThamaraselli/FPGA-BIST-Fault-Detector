module signature_comparator (
    input  wire [15:0] expected_signature,
    input  wire [15:0] actual_signature,

    output wire        pass,
    output wire        fail
);

    assign pass = (expected_signature == actual_signature);
    assign fail = (expected_signature != actual_signature);

endmodule