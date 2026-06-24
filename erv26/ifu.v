// IFU - Instruction Fetch Unit para ERV26 (RV32I).
//
// Version A:
//   - La IFU NO calcula PC + 4.
//   - La IFU solo registra el PC.
//   - El addr_builder calcula siempre el next_pc completo.
//
// rst es activo en alto.

module ifu (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    always @(posedge clk) begin
        if (rst)
            pc <= 32'b0;
        else
            pc <= next_pc;
    end

endmodule