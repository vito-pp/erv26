// Addr Builder / Jump Control para ERV26 (RV32I).
//
// Version A:
//   - Este modulo calcula SIEMPRE el next_pc.
//   - La IFU solo carga next_pc en el registro PC.
//   - No hay PC+4 dentro de la IFU.
//
// Entradas de PC:
//   - pc       : PC actual del IFU/fetch.
//                Se usa para el avance normal: pc + 4.
//   - pc_instr : PC de la instruccion actual, alineado con instruction/opcode/imm.
//                Se usa para JAL, BRANCH, AUIPC y link_pc.
//
// Esto permite que, si la ROM tiene latencia, los saltos se calculen con el PC
// correcto de la instruccion, pero el avance normal siga usando el PC actual.

module addr_builder
(
    input  [31:0] pc,              // PC actual del IFU / fetch
    input  [31:0] pc_instr,        // PC de la instruccion actual
    input  [31:0] rs1,
    input  [31:0] imm,
    input  [6:0]  opcode,
    input         branch_taken,    // viene de la ALU para BRANCH

    output     [31:0] data_addr,   // LOAD/STORE
    output reg [31:0] next_pc,     // proximo PC completo
    output reg        jump,        // 1 = redireccion; util para debug/flush
    output     [31:0] link_pc,     // PC_instr + 4 para JAL/JALR
    output     [31:0] auipc_val    // PC_instr + imm para AUIPC
);

    // Opcodes RV32I
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;

    // ------------------------------------------------------------
    // Sumas
    // ------------------------------------------------------------

    // Avance secuencial normal desde el PC actual del IFU.
    wire [31:0] pc_plus_4 = pc + 32'd4;

    // Sumas relativas al PC de la instruccion actual.
    wire [31:0] pc_instr_plus_4   = pc_instr + 32'd4;
    wire [31:0] pc_instr_plus_imm = pc_instr + imm;

    // Direccion efectiva basada en registro.
    wire [31:0] rs1_plus_imm = rs1 + imm;

    // ------------------------------------------------------------
    // Salidas directas
    // ------------------------------------------------------------

    // LOAD/STORE: direccion efectiva = rs1 + imm.
    assign data_addr = rs1_plus_imm;

    // JAL/JALR escriben PC de la instruccion + 4 en rd.
    assign link_pc = pc_instr_plus_4;

    // AUIPC escribe PC de la instruccion + imm en rd.
    assign auipc_val = pc_instr_plus_imm;

    // JALR fuerza el bit 0 del target a 0.
    wire [31:0] jalr_target = {rs1_plus_imm[31:1], 1'b0};

    // ------------------------------------------------------------
    // Seleccion del proximo PC
    // ------------------------------------------------------------

    always @(*) begin
        case (opcode)

            OP_JAL: begin
                next_pc = pc_instr_plus_imm;
                jump    = 1'b1;
            end

            OP_JALR: begin
                next_pc = jalr_target;
                jump    = 1'b1;
            end

            OP_BRANCH: begin
                if (branch_taken) begin
                    next_pc = pc_instr_plus_imm;
                    jump    = 1'b1;
                end else begin
                    next_pc = pc_plus_4;
                    jump    = 1'b0;
                end
            end

            default: begin
                // Instruccion normal: el addr_builder tambien hace PC + 4.
                next_pc = pc_plus_4;
                jump    = 1'b0;
            end

        endcase
    end

endmodule