// Decode Instruction para ERV26 (RV32I).
//
// Separa la palabra de instruccion en sus campos (rd, rs1, rs2, funct3,
// funct7) segun el formato indicado por instruction_type.
//
// Cambios respecto de V0:
//   - Ya NO se genera el inmediato aqui. Esa logica vive en imm_builder.v,
//     que actua como unico "armador de inmediato". Mantiene el principio
//     de un solo source of truth para el imm.
//   - funct7 ahora se asigna solo cuando es semanticamente correcto:
//       * R-type: funct7 = inst[31:25] (siempre)
//       * I-type con shifts (SLLI/SRLI/SRAI, funct3 = 001 o 101):
//         funct7 = inst[31:25], que distingue SRA de SRL.
//       * resto: funct7 = 0. En esos casos esos bits son parte del imm
//         y no tienen significado de funct7.

module decode_instruction
(
	input  [31:0] instruction,
	input  [5:0]  instruction_type,
	output reg [4:0] rd,
	output reg [4:0] rs1,
	output reg [4:0] rs2,
	output reg [2:0] funct3,
	output reg [6:0] funct7
);

	// Codificacion one-hot generada por decode_type
	localparam R_TYPE = 6'b000001;
	localparam I_TYPE = 6'b000010;
	localparam S_TYPE = 6'b000100;
	localparam B_TYPE = 6'b001000;
	localparam U_TYPE = 6'b010000;
	localparam J_TYPE = 6'b100000;

	// Para distinguir shifts dentro de I-type (donde inst[31:25] sirve
	// como funct7 efectivo).
	wire [2:0] f3 = instruction[14:12];
	wire is_shift_imm = (f3 == 3'b001) || (f3 == 3'b101);

	always @(*) begin
		rd     = 5'b0;
		rs1    = 5'b0;
		rs2    = 5'b0;
		funct3 = 3'b0;
		funct7 = 7'b0;

		case (instruction_type)

			R_TYPE: begin
				rd     = instruction[11:7];
				funct3 = instruction[14:12];
				rs1    = instruction[19:15];
				rs2    = instruction[24:20];
				funct7 = instruction[31:25];
			end

			I_TYPE: begin
				rd     = instruction[11:7];
				funct3 = instruction[14:12];
				rs1    = instruction[19:15];
				// Solo en shifts I-type funct7 es semanticamente significativo.
				funct7 = is_shift_imm ? instruction[31:25] : 7'b0;
			end

			S_TYPE: begin
				funct3 = instruction[14:12];
				rs1    = instruction[19:15];
				rs2    = instruction[24:20];
				// funct7 = 0: en S-type inst[31:25] son bits del imm.
			end

			B_TYPE: begin
				funct3 = instruction[14:12];
				rs1    = instruction[19:15];
				rs2    = instruction[24:20];
				// funct7 = 0: en B-type inst[31:25] son bits del imm.
			end

			U_TYPE: begin
				rd     = instruction[11:7];
				// funct3, funct7, rs1, rs2 no aplican.
			end

			J_TYPE: begin
				rd     = instruction[11:7];
				// idem U-type.
			end

			default: begin
				rd     = 5'b0;
				rs1    = 5'b0;
				rs2    = 5'b0;
				funct3 = 3'b0;
				funct7 = 7'b0;
			end

		endcase
	end

endmodule
