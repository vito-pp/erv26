module decode_instruction
(
 input [31:0] instruction,
 input [5:0] instruction_type,
 output reg [4:0] rd,
 output reg [4:0] rs1,
 output reg [4:0] rs2,
 output reg [2:0] funct3,
 output reg [6:0] funct7,
 output reg [31:0] imm
);

	always @(*) begin
		rd = 5'b0;
		rs1 = 5'b0;
		rs2 = 5'b0;
		funct3 = 3'b0;
		funct7 = 7'b0;
		imm = 32'b0;

		case (instruction_type)
			6'b000001: begin // R-type
				rd = instruction[11:7];
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				funct7 = instruction[31:25];
			end

			6'b000010: begin // I-type
				rd = instruction[11:7];
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				funct7 = instruction[31:25];
				imm = {{20{instruction[31]}}, instruction[31:20]};
			end

			6'b000100: begin // S-type
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				funct7 = instruction[31:25];
				imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
			end

			6'b001000: begin // B-type
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				funct7 = instruction[31:25];
				imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
			end

			6'b010000: begin // U-type
				rd = instruction[11:7];
				imm = {instruction[31:12], 12'b0};
			end

			6'b100000: begin // J-type
				rd = instruction[11:7];
				imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
			end

			default: begin
				rd = 5'b0;
				rs1 = 5'b0;
				rs2 = 5'b0;
				funct3 = 3'b0;
				funct7 = 7'b0;
				imm = 32'b0;
			end
		endcase
	end

endmodule
