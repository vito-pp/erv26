// Stage Latch MEM/WB para ERV26 (pipeline de 5 etapas).
//
// Registra lo que produce la etapa MEM (memoria + aligner) para entregarlo
// a WB (write_back_mux + escritura en reg32).
//
// Lleva las cuatro fuentes posibles de write-back + el selector wb_src, mas
// rd y reg_write. El write_back_mux en WB elige cual escribir.
//
// flush/reset -> burbuja (reg_write = 0): la escritura en el banco se anula.

module mem_wb (
	input  wire        clk,
	input  wire        nreset,
	input  wire        en,
	input  wire        flush,

	// --- Fuentes de write-back ---
	input  wire [31:0] alu_out_in,
	input  wire [31:0] mem_data_in,
	input  wire [31:0] link_pc_in,
	input  wire [31:0] auipc_val_in,
	input  wire [4:0]  rd_in,

	// --- Control ---
	input  wire        reg_write_in,
	input  wire [1:0]  wb_src_in,

	// === Salidas registradas ===
	output reg  [31:0] alu_out_out,
	output reg  [31:0] mem_data_out,
	output reg  [31:0] link_pc_out,
	output reg  [31:0] auipc_val_out,
	output reg  [4:0]  rd_out,

	output reg         reg_write_out,
	output reg  [1:0]  wb_src_out
);

	task set_bubble;
		begin
			alu_out_out   <= 32'b0;
			mem_data_out  <= 32'b0;
			link_pc_out   <= 32'b0;
			auipc_val_out <= 32'b0;
			rd_out        <= 5'b0;
			reg_write_out <= 1'b0;
			wb_src_out    <= 2'b0;
		end
	endtask

	always @(posedge clk or negedge nreset) begin
		if (!nreset)     set_bubble;
		else if (flush)  set_bubble;
		else if (en) begin
			alu_out_out   <= alu_out_in;
			mem_data_out  <= mem_data_in;
			link_pc_out   <= link_pc_in;
			auipc_val_out <= auipc_val_in;
			rd_out        <= rd_in;
			reg_write_out <= reg_write_in;
			wb_src_out    <= wb_src_in;
		end
		// !en && !flush: mantiene (hold)
	end

endmodule
