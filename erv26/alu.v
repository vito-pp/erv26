// ALU de 32 bits para ERV26 (RV32I).
//
// Cubre las operaciones aritmetico-logicas del set RV32I:
//   - OP     (R-type): ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
//   - OP-IMM (I-type): ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
//   - LUI            : rd = imm
//   - BRANCH         : produce la flag branch_taken segun funct3
//
// El calculo de direcciones (PC+imm para JAL/BRANCH, rs1+imm para LOAD/STORE/JALR,
// PC+imm para AUIPC) se realiza fuera de este modulo, en el bloque Addr Builder
// segun la figura 2.1 de la especificacion. Justificacion: separar el datapath
// aritmetico del calculo de direcciones permite hacer ambas operaciones en
// paralelo en la misma etapa del pipeline, sin penalizar el camino critico
// con un mux adicional sobre la entrada de la ALU.

module alu
(
	input  [31:0] rs1,
	input  [31:0] rs2,
	input  [31:0] imm,
	input  [6:0]  opcode,
	input  [2:0]  funct3,
	input  [6:0]  funct7,
	output reg [31:0] out,
	output reg        branch_taken
);

	// Opcodes RV32I
	localparam OP_OP     = 7'b0110011;
	localparam OP_OPIMM  = 7'b0010011;
	localparam OP_LUI    = 7'b0110111;
	localparam OP_BRANCH = 7'b1100011;

	// funct3 para OP / OP-IMM
	localparam F3_ADDSUB = 3'b000;
	localparam F3_SLL    = 3'b001;
	localparam F3_SLT    = 3'b010;
	localparam F3_SLTU   = 3'b011;
	localparam F3_XOR    = 3'b100;
	localparam F3_SRX    = 3'b101; // SRL / SRA
	localparam F3_OR     = 3'b110;
	localparam F3_AND    = 3'b111;

	// funct3 para BRANCH
	localparam F3_BEQ    = 3'b000;
	localparam F3_BNE    = 3'b001;
	localparam F3_BLT    = 3'b100;
	localparam F3_BGE    = 3'b101;
	localparam F3_BLTU   = 3'b110;
	localparam F3_BGEU   = 3'b111;

	// Segundo operando: rs2 para OP/BRANCH, imm para OP-IMM.
	wire [31:0] operand_b = (opcode == OP_OP || opcode == OP_BRANCH) ? rs2 : imm;

	// Para shifts el shift amount son los 5 bits bajos del operando B
	// (tanto en R-type como en I-type, donde imm[4:0] = shamt).
	wire [4:0]  shamt = operand_b[4:0];

	// SUB se aplica en OP cuando funct7[5]=1 con funct3=000.
	// SRA se aplica en OP y OP-IMM cuando funct7[5]=1 con funct3=101.
	// Para OP-IMM funct3=000 (ADDI) siempre suma, independientemente de funct7.
	wire is_sub = (opcode == OP_OP) && (funct3 == F3_ADDSUB) && funct7[5];
	wire is_sra = (funct3 == F3_SRX) && funct7[5];

	// Comparaciones signadas/no signadas (reutilizadas por SLT[I][U] y BRANCH).
	wire signed [31:0] rs1_s = rs1;
	wire signed [31:0] opb_s = operand_b;
	wire lt_s  = (rs1_s < opb_s);
	wire lt_u  = (rs1  < operand_b);
	wire eq    = (rs1 == operand_b);

	always @(*) begin
		// Default: salida en 0 para opcodes no manejados por esta ALU
		// (LOAD/STORE/JAL/JALR/AUIPC los resuelve el Addr Builder; LUI se
		// resuelve abajo).
		out = 32'b0;
		branch_taken = 1'b0;

		case (opcode)

			OP_LUI: begin
				// rd = imm. Se asume que el IMM builder ya hizo imm = {inst[31:12], 12'b0}.
				out = imm;
			end

			OP_OP, OP_OPIMM: begin
				case (funct3)
					F3_ADDSUB: out = is_sub ? (rs1 - operand_b) : (rs1 + operand_b);
					F3_SLL   : out = rs1 << shamt;
					F3_SLT   : out = {31'b0, lt_s};
					F3_SLTU  : out = {31'b0, lt_u};
					F3_XOR   : out = rs1 ^ operand_b;
					F3_SRX   : out = is_sra ? (rs1_s >>> shamt) : (rs1 >> shamt);
					F3_OR    : out = rs1 | operand_b;
					F3_AND   : out = rs1 & operand_b;
				endcase
			end

			OP_BRANCH: begin
				case (funct3)
					F3_BEQ : branch_taken =  eq;
					F3_BNE : branch_taken = ~eq;
					F3_BLT : branch_taken =  lt_s;
					F3_BGE : branch_taken = ~lt_s;
					F3_BLTU: branch_taken =  lt_u;
					F3_BGEU: branch_taken = ~lt_u;
					default: branch_taken = 1'b0;
				endcase
			end

			default: begin
				out = 32'b0;
				branch_taken = 1'b0;
			end

		endcase
	end

endmodule
