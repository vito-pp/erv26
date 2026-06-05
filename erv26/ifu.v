module ifu (
    input  wire        clk,
    input  wire        rst,
    output reg [31:0] pc
);

always @(posedge clk) begin
    if (rst)
        pc <= 32'b0;
    else
        pc <= pc + 32'd4;
end

endmodule