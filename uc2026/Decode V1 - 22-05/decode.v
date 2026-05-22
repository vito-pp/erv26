// Decode (top) para ERV26 (RV32I).
//
// Wrapper que envuelve los tres sub-modulos de decodificacion para que el
// top del procesador instancie un solo bloque "decode" y obtenga toda la
// informacion estatica de la instruccion (campos + senales de control).
//
// Componentes internos:
//   - decode_type        : opcode -> instruction_type (formato R/I/S/B/U/J)
//   - decode_instruction : instruction + type -> rd, rs1, rs2, funct3, funct7
//   - decode_control     : opcode -> flags de control del datapath
//
// Nota: el inmediato (imm) NO se genera aqui. Lo arma imm_builder.v como
// modulo independiente, instanciado en paralelo a este decode en el top.
// Razon: separar la logica de "armar el valor inmediato" (datapath) de la
// logica de "decidir que hacer" (control).

module decode
(
	input  [31:0] instruction,

	// Salidas combinacionales de los sub-modulos
	output [6:0]  opcode,
	output [5:0]  instruction_type,
	output [4:0]  rd,
	output [4:0]  rs1,
	output [4:0]  rs2,
	output [2:0]  funct3,
	output [6:0]  funct7,

	// Flags de control para el datapath
	output        reg_write,
	output        mem_read,
	output        mem_write,
	output [1:0]  wb_src,
	output        is_branch,
	output        is_jump
);

	// Cables internos entre sub-modulos
	wire [6:0] opcode_w;
	wire [5:0] inst_type_w;

	// Tipo de instruccion + opcode
	decode_type u_decode_type (
		.instruction      (instruction),
		.opcode           (opcode_w),
		.instruction_type (inst_type_w)
	);

	// Campos de la instruccion (rd, rs1, rs2, funct3, funct7)
	decode_instruction u_decode_instruction (
		.instruction      (instruction),
		.instruction_type (inst_type_w),
		.rd               (rd),
		.rs1              (rs1),
		.rs2              (rs2),
		.funct3           (funct3),
		.funct7           (funct7)
	);

	// Flags de control del datapath
	decode_control u_decode_control (
		.opcode    (opcode_w),
		.reg_write (reg_write),
		.mem_read  (mem_read),
		.mem_write (mem_write),
		.wb_src    (wb_src),
		.is_branch (is_branch),
		.is_jump   (is_jump)
	);

	// Re-exposicion de opcode e instruction_type para el resto del procesador
	assign opcode           = opcode_w;
	assign instruction_type = inst_type_w;

endmodule
