// Stage Latch EX/MEM para ERV26 (pipeline de 5 etapas).
//
// Registra lo que produce la etapa EX (alu + addr_builder) para entregarlo
// a MEM (memoria de datos + load/store aligner).
//
// Lleva:
//   - alu_out    : resultado de la ALU (fuente WB para OP/OP-IMM/LUI).
//   - data_addr  : direccion de memoria para LOAD/STORE (de addr_builder).
//   - store_data : dato a escribir en STORE (= data_rs2).
//   - link_pc    : PC+4 (fuente WB para JAL/JALR).
//   - auipc_val  : PC+imm (fuente WB para AUIPC).
//   - rd         : registro destino.
//   - control de MEM (mem_read/mem_write) y de WB (reg_write/wb_src).
//
// flush/reset -> burbuja: se limpian los flags de control.

module ex_mem (
	input  wire        clk,
	input  wire        nreset,
	input  wire        en,
	input  wire        flush,

	// --- Datos ---
	input  wire [31:0] alu_out_in,
	input  wire [31:0] data_addr_in,
	input  wire [31:0] store_data_in,
	input  wire [31:0] link_pc_in,
	input  wire [31:0] auipc_val_in,
	input  wire [4:0]  rd_in,

	// --- Control ---
	input  wire        reg_write_in,
	input  wire        mem_read_in,
	input  wire        mem_write_in,
	input  wire [1:0]  wb_src_in,
	input  wire [2:0]  funct3_in,    // para el load/store aligner en MEM

	// === Salidas registradas ===
	output reg  [31:0] alu_out_out,
	output reg  [31:0] data_addr_out,
	output reg  [31:0] store_data_out,
	output reg  [31:0] link_pc_out,
	output reg  [31:0] auipc_val_out,
	output reg  [4:0]  rd_out,

	output reg         reg_write_out,
	output reg         mem_read_out,
	output reg         mem_write_out,
	output reg  [1:0]  wb_src_out,
	output reg  [2:0]  funct3_out
);

	task set_bubble;
		begin
			alu_out_out    <= 32'b0;
			data_addr_out  <= 32'b0;
			store_data_out <= 32'b0;
			link_pc_out    <= 32'b0;
			auipc_val_out  <= 32'b0;
			rd_out         <= 5'b0;
			reg_write_out  <= 1'b0;
			mem_read_out   <= 1'b0;
			mem_write_out  <= 1'b0;
			wb_src_out     <= 2'b0;
			funct3_out     <= 3'b0;
		end
	endtask

	always @(posedge clk or negedge nreset) begin
		if (!nreset)     set_bubble;
		else if (flush)  set_bubble;
		else if (en) begin
			alu_out_out    <= alu_out_in;
			data_addr_out  <= data_addr_in;
			store_data_out <= store_data_in;
			link_pc_out    <= link_pc_in;
			auipc_val_out  <= auipc_val_in;
			rd_out         <= rd_in;
			reg_write_out  <= reg_write_in;
			mem_read_out   <= mem_read_in;
			mem_write_out  <= mem_write_in;
			wb_src_out     <= wb_src_in;
			funct3_out     <= funct3_in;
		end
		// !en && !flush: mantiene (hold)
	end

endmodule
