// Decode Control para ERV26 (RV32I).
//
// Genera las senales de control que configuran el datapath segun el opcode
// de la instruccion. Es la pieza que "le dice al hardware que hacer" con
// cada instruccion.
//
// Senales generadas:
//
//   reg_write : habilita la escritura en el banco de registros.
//               1 -> la instruccion escribe en rd
//               0 -> la instruccion NO modifica el banco (STORE, BRANCH, FENCE,
//                    SYSTEM no implementadas)
//
//   mem_read  : 1 para LOAD, 0 para el resto. Va al chip de memoria de datos.
//
//   mem_write : 1 para STORE, 0 para el resto. Va al chip de memoria de datos.
//
//   wb_src    : selector del Write-Back Mux. Codificacion (debe coincidir
//               con write_back_mux.v):
//                  00 -> ALU       (OP, OP-IMM, LUI)
//                  01 -> MEM       (LOAD)
//                  10 -> PC+4      (JAL, JALR -- return address)
//                  11 -> AUIPC     (PC+imm)
//
//   is_branch : 1 para BRANCH. Lo usa el control de pipeline para saber que
//               la decision de saltar depende de la salida branch_taken de
//               la ALU.
//
//   is_jump   : 1 para JAL/JALR. Salto incondicional, el control de pipeline
//               flushea sin esperar a la ALU.
//
// Comportamiento por opcode:
//
//   Opcode      reg_write mem_read mem_write wb_src   is_branch is_jump
//   OP, OP-IMM     1         0         0       ALU       0         0
//   LUI            1         0         0       ALU       0         0
//   AUIPC          1         0         0       AUIPC     0         0
//   LOAD           1         1         0       MEM       0         0
//   STORE          0         0         1        -        0         0
//   BRANCH         0         0         0        -        1         0
//   JAL, JALR      1         0         0       PC+4      0         1
//   MISC-MEM       0         0         0        -        0         0   (FENCE = NOP)
//   SYSTEM         0         0         0        -        0         0   (no implementado)

module decode_control
(
	input  [6:0]  opcode,
	output reg        reg_write,
	output reg        mem_read,
	output reg        mem_write,
	output reg [1:0]  wb_src,
	output reg        is_branch,
	output reg        is_jump
);

	// Opcodes RV32I
	localparam OP_LUI     = 7'b0110111;
	localparam OP_AUIPC   = 7'b0010111;
	localparam OP_JAL     = 7'b1101111;
	localparam OP_JALR    = 7'b1100111;
	localparam OP_BRANCH  = 7'b1100011;
	localparam OP_LOAD    = 7'b0000011;
	localparam OP_STORE   = 7'b0100011;
	localparam OP_OPIMM   = 7'b0010011;
	localparam OP_OP      = 7'b0110011;
	localparam OP_MISCMEM = 7'b0001111; // FENCE -> NOP
	localparam OP_SYSTEM  = 7'b1110011; // ECALL/EBREAK/CSR -> no implementado

	// Codificacion de wb_src (igual que en write_back_mux.v)
	localparam WB_ALU   = 2'b00;
	localparam WB_MEM   = 2'b01;
	localparam WB_PC4   = 2'b10;
	localparam WB_AUIPC = 2'b11;

	always @(*) begin
		// Defaults: instruccion "inerte" (no modifica estado).
		// Cubre tambien MISC-MEM, SYSTEM y opcodes no reconocidos.
		reg_write = 1'b0;
		mem_read  = 1'b0;
		mem_write = 1'b0;
		wb_src    = WB_ALU;
		is_branch = 1'b0;
		is_jump   = 1'b0;

		case (opcode)

			OP_OP, OP_OPIMM, OP_LUI: begin
				reg_write = 1'b1;
				wb_src    = WB_ALU;
			end

			OP_AUIPC: begin
				reg_write = 1'b1;
				wb_src    = WB_AUIPC;
			end

			OP_LOAD: begin
				reg_write = 1'b1;
				mem_read  = 1'b1;
				wb_src    = WB_MEM;
			end

			OP_STORE: begin
				mem_write = 1'b1;
			end

			OP_BRANCH: begin
				is_branch = 1'b1;
			end

			OP_JAL, OP_JALR: begin
				reg_write = 1'b1;
				wb_src    = WB_PC4;
				is_jump   = 1'b1;
			end

			// OP_MISCMEM, OP_SYSTEM y default usan los valores por defecto.
			default: ;

		endcase
	end

endmodule
