// Stage Latch ID/EX para ERV26 (pipeline de 5 etapas).
//
// Registra lo que produce la etapa ID (decode + imm_builder + lectura de
// registros) para entregarlo a EX (alu + addr_builder).
//
// Lleva tres grupos de senales:
//   - Datos      : operandos y valores que usan EX/MEM/WB.
//   - Direcciones: rd (destino) y rs1/rs2 (para el forwarding de Fase 3).
//   - Control    : flags del decode que viajan hasta su etapa de uso.
//
// En flush o reset se limpian SOLO los flags de control (se vuelve una
// burbuja: no escribe registros ni memoria). Los datos se ponen en 0 por
// prolijidad, pero lo que hace inofensiva a la burbuja es el control en 0.

module id_ex (
	input  wire        clk,
	input  wire        nreset,
	input  wire        en,
	input  wire        flush,

	// --- Datos ---
	input  wire [31:0] data_rs1_in,
	input  wire [31:0] data_rs2_in,
	input  wire [31:0] imm_in,
	input  wire [31:0] pc_in,
	input  wire [31:0] pc4_in,

	// --- Direcciones de registro ---
	input  wire [4:0]  rd_in,
	input  wire [4:0]  rs1_addr_in,
	input  wire [4:0]  rs2_addr_in,

	// --- Campos para la ALU ---
	input  wire [6:0]  opcode_in,
	input  wire [2:0]  funct3_in,
	input  wire [6:0]  funct7_in,

	// --- Control ---
	input  wire        reg_write_in,
	input  wire        mem_read_in,
	input  wire        mem_write_in,
	input  wire [1:0]  wb_src_in,
	input  wire        is_branch_in,
	input  wire        is_jump_in,

	// === Salidas registradas ===
	output reg  [31:0] data_rs1_out,
	output reg  [31:0] data_rs2_out,
	output reg  [31:0] imm_out,
	output reg  [31:0] pc_out,
	output reg  [31:0] pc4_out,

	output reg  [4:0]  rd_out,
	output reg  [4:0]  rs1_addr_out,
	output reg  [4:0]  rs2_addr_out,

	output reg  [6:0]  opcode_out,
	output reg  [2:0]  funct3_out,
	output reg  [6:0]  funct7_out,

	output reg         reg_write_out,
	output reg         mem_read_out,
	output reg         mem_write_out,
	output reg  [1:0]  wb_src_out,
	output reg         is_branch_out,
	output reg         is_jump_out
);

	// Tarea para dejar el latch en estado de burbuja (NOP).
	task set_bubble;
		begin
			data_rs1_out  <= 32'b0;
			data_rs2_out  <= 32'b0;
			imm_out       <= 32'b0;
			pc_out        <= 32'b0;
			pc4_out       <= 32'b0;
			rd_out        <= 5'b0;
			rs1_addr_out  <= 5'b0;
			rs2_addr_out  <= 5'b0;
			opcode_out    <= 7'b0;
			funct3_out    <= 3'b0;
			funct7_out    <= 7'b0;
			reg_write_out <= 1'b0;
			mem_read_out  <= 1'b0;
			mem_write_out <= 1'b0;
			wb_src_out    <= 2'b0;
			is_branch_out <= 1'b0;
			is_jump_out   <= 1'b0;
		end
	endtask

	always @(posedge clk or negedge nreset) begin
		if (!nreset)      set_bubble;
		else if (flush)   set_bubble;
		else if (en) begin
			data_rs1_out  <= data_rs1_in;
			data_rs2_out  <= data_rs2_in;
			imm_out       <= imm_in;
			pc_out        <= pc_in;
			pc4_out       <= pc4_in;
			rd_out        <= rd_in;
			rs1_addr_out  <= rs1_addr_in;
			rs2_addr_out  <= rs2_addr_in;
			opcode_out    <= opcode_in;
			funct3_out    <= funct3_in;
			funct7_out    <= funct7_in;
			reg_write_out <= reg_write_in;
			mem_read_out  <= mem_read_in;
			mem_write_out <= mem_write_in;
			wb_src_out    <= wb_src_in;
			is_branch_out <= is_branch_in;
			is_jump_out   <= is_jump_in;
		end
		// !en && !flush: mantiene (hold)
	end

endmodule
