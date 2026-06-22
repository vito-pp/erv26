module slice_9_2 (
    input  wire [31:0] in,
    output wire [7:0]  out
);

    assign out = in[9:2];

endmodule
