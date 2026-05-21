// IMM Builder de 32 bits para ERV26 (RV32I).
//
// Arma el valor inmediato de 32 bits con extension de signo a partir de los
// distintos formatos definidos en la seccion 2.3 de la especificacion RISC-V.
//
// La ISA dispone los bits del inmediato en posiciones "raras" dentro de la
// palabra de instruccion. El motivo es minimizar el hardware: el bit de signo
// del inmediato siempre esta en inst[31], y la mayoria de los bits aparecen
// en las mismas posiciones entre formatos. Eso permite que este modulo sea
// basicamente cableado + un mux final.
//
// Formatos (ver figura 1.2 del enunciado):
//
//   I-type  imm = {{20{inst[31]}}, inst[31:20]}
//           Ejemplos: ADDI, ANDI, ORI, XORI, SLTI[U], LOAD, JALR.
//           Tambien sirve para SLLI/SRLI/SRAI: imm[4:0] = shamt (inst[24:20]),
//           el resto no lo usa la ALU.
//
//   S-type  imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}
//           Ejemplos: STORE (SB, SH, SW).
//
//   B-type  imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}
//           Saltos condicionales (BEQ/BNE/BLT/...). El LSB siempre es 0 porque
//           las direcciones de salto son multiplos de 2 bytes.
//
//   U-type  imm = {inst[31:12], 12'b0}
//           LUI / AUIPC. Ya queda "shifteado" 12 lugares: LUI carga directamente
//           imm como rd, AUIPC suma este valor a PC.
//
//   J-type  imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}
//           JAL. LSB tambien forzado a 0.
//
// Para opcodes sin inmediato (OP, MISC-MEM, SYSTEM) la salida es 0; igual el
// decode no debe levantar la flag de "usa imm" en esos casos.

module imm_builder
(
	input  [31:0] instr,
	output reg [31:0] imm
);

	// Opcodes RV32I (los mismos que usa la ALU).
	localparam OP_LUI    = 7'b0110111;
	localparam OP_AUIPC  = 7'b0010111;
	localparam OP_JAL    = 7'b1101111;
	localparam OP_JALR   = 7'b1100111;
	localparam OP_BRANCH = 7'b1100011;
	localparam OP_LOAD   = 7'b0000011;
	localparam OP_STORE  = 7'b0100011;
	localparam OP_OPIMM  = 7'b0010011;
	localparam OP_OP     = 7'b0110011;

	wire [6:0] opcode = instr[6:0];

	// Inmediatos pre-armados para cada formato. Son todos combinacionales y
	// "gratis" en hardware: solo seleccionan bits y replican inst[31] (signo).
	wire [31:0] imm_i = { {20{instr[31]}}, instr[31:20] };

	wire [31:0] imm_s = { {20{instr[31]}}, instr[31:25], instr[11:7] };

	wire [31:0] imm_b = { {19{instr[31]}},
	                      instr[31],
	                      instr[7],
	                      instr[30:25],
	                      instr[11:8],
	                      1'b0 };

	wire [31:0] imm_u = { instr[31:12], 12'b0 };

	wire [31:0] imm_j = { {11{instr[31]}},
	                      instr[31],
	                      instr[19:12],
	                      instr[20],
	                      instr[30:21],
	                      1'b0 };

	always @(*) begin
		case (opcode)
			OP_LUI, OP_AUIPC          : imm = imm_u;
			OP_JAL                    : imm = imm_j;
			OP_JALR, OP_LOAD, OP_OPIMM: imm = imm_i;
			OP_BRANCH                 : imm = imm_b;
			OP_STORE                  : imm = imm_s;
			default                   : imm = 32'b0; // OP (R-type) y otros sin inmediato
		endcase
	end

endmodule
