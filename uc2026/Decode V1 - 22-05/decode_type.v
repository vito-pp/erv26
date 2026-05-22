module decode_type
(
 input [31:0] instruction,
 output [6:0] opcode,
 output reg [5:0] instruction_type
);

	assign opcode = instruction[6:0];

	always @(*) begin
		instruction_type = 6'b000000;

		case (opcode)
			7'b0110011: instruction_type = 6'b000001; // R-type: OP

			7'b0010011,                              // I-type: OP-IMM
			7'b0000011,                              // I-type: LOAD
			7'b1100111,                              // I-type: JALR
			7'b0001111,                              // I-type: MISC-MEM
			7'b1110011: instruction_type = 6'b000010; // I-type: SYSTEM

			7'b0100011: instruction_type = 6'b000100; // S-type: STORE
			7'b1100011: instruction_type = 6'b001000; // B-type: BRANCH

			7'b0110111,                              // U-type: LUI
			7'b0010111: instruction_type = 6'b010000; // U-type: AUIPC

			7'b1101111: instruction_type = 6'b100000; // J-type: JAL

			default: instruction_type = 6'b000000;
		endcase
	end

endmodule
