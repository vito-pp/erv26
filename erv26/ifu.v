// IFU - Instruction Fetch Unit para ERV26 (RV32I).
//
// Contiene el Program Counter. En cada flanco de clock actualiza el PC:
//   - jump = 0 : avance secuencial, PC <- PC + 4
//   - jump = 1 : redireccion, PC <- next_pc (target calculado por addr_builder)
//
// El target de salto (next_pc) y la decision (jump) vienen del addr_builder,
// que ya resuelve JAL/JALR/BRANCH. La IFU solo elige entre el incremento
// secuencial propio (PC+4) y ese target.
//
// Notas:
//   - rst es activo en alto: lleva el PC a 0.
//   - El PC+4 se calcula aqui adentro para que la IFU sea autosuficiente en
//     el caso comun (no depende del addr_builder cuando no hay salto).

module ifu (
    input  wire        clk,
    input  wire        rst,
    input  wire        jump,        // 1 = cargar next_pc en vez de PC+4
    input  wire [31:0] next_pc,     // target de salto (desde addr_builder)
    output reg  [31:0] pc           // PC actual
);

    // Proximo valor del PC: salto o avance secuencial.
    wire [31:0] pc_next = jump ? next_pc : (pc + 32'd4);

    always @(posedge clk) begin
        if (rst)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

endmodule