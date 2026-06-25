module slice_11_2 (
    input  wire [31:0] in,
    output wire [9:0]  out
);

    assign out = in[11:2];

endmodule
