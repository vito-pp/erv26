// Stage Latch IF/ID para ERV26 (pipeline de 5 etapas).
//
// Registra lo que produce la etapa IF (fetch + rom) para entregarlo a ID
// (decode + imm_builder + lectura de registros).
//
// Control del latch (uniforme en los 4 stage latches):
//   nreset : reset asincrono activo en bajo -> burbuja (NOP).
//   en     : 1 = avanza normal; 0 = mantiene el valor (stall/hold).
//   flush  : 1 = inserta una burbuja (instruccion = NOP). Usado cuando se
//            toma un salto, para anular la instruccion mal-fetcheada.
//
// Prioridad: nreset > flush > en.

module if_id (
	input  wire        clk,
	input  wire        nreset,
	input  wire        en,
	input  wire        flush,

	input  wire [31:0] instr_in,
	input  wire [31:0] pc_in,
	input  wire [31:0] pc4_in,

	output reg  [31:0] instr_out,
	output reg  [31:0] pc_out,
	output reg  [31:0] pc4_out
);

	localparam NOP = 32'h00000013; // ADDI x0, x0, 0

	always @(posedge clk or negedge nreset) begin
		if (!nreset) begin
			instr_out <= NOP;
			pc_out    <= 32'b0;
			pc4_out   <= 32'b0;
		end
		else if (flush) begin
			instr_out <= NOP;
			pc_out    <= 32'b0;
			pc4_out   <= 32'b0;
		end
		else if (en) begin
			instr_out <= instr_in;
			pc_out    <= pc_in;
			pc4_out   <= pc4_in;
		end
		// !en && !flush: mantiene (hold)
	end

endmodule
