// nop_inyection.v
//
// Si branch_taken = 1:
//   flanco actual: inst_out <= NOP
//   flanco siguiente: inst_out <= NOP
//
// O sea, inyecta 2 NOPs consecutivos.

module nop_inyection (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] inst_in,
    input  wire        branch_taken,
    output reg  [31:0] inst_out
);

    localparam [31:0] NOP = 32'h00000013;

    reg flush_pending;

    always @(posedge clk) begin
        if (rst) begin
            inst_out      <= NOP;
            flush_pending <= 1'b0;
        end
        else begin
            if (branch_taken) begin
                // Primer NOP inmediatamente después de detectar branch_taken.
                inst_out      <= NOP;

                // Deja preparado un segundo NOP para el próximo ciclo.
                flush_pending <= 1'b1;
            end
            else if (flush_pending) begin
                // Segundo NOP.
                inst_out      <= NOP;
                flush_pending <= 1'b0;
            end
            else begin
                inst_out      <= inst_in;
                flush_pending <= 1'b0;
            end
        end
    end

endmodule