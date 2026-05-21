// Write-Back Mux para ERV26 (RV32I).
//
// Ultimo mux del datapath: selecciona que valor se escribe en rd del banco
// de registros segun la instruccion en curso.
//
// Fuentes posibles en RV32I:
//   - alu_out   : resultado de la ALU (OP, OP-IMM, LUI)
//   - mem_data  : dato leido de memoria de datos (LOAD)
//   - link_pc   : PC+4, return address (JAL, JALR)
//   - auipc_val : PC+imm (AUIPC)
//
// La seleccion la maneja el Decode mediante la senal wb_src.
//
// Codificacion de wb_src (acordar con el Decode antes de integrar):
//   00 -> ALU       (OP, OP-IMM, LUI)
//   01 -> MEM       (LOAD)
//   10 -> PC+4      (JAL, JALR)
//   11 -> AUIPC     (AUIPC)
//
// Para instrucciones que no escriben rd (STORE, BRANCH, FENCE) el Decode
// debe poner reg_write=0 en el banco de registros; el valor que salga de
// este mux es indistinto.
//
// Nota: el alineamiento/extension de signo para LB/LH/LBU/LHU se hace
// fuera de este modulo, en un "load aligner" entre la memoria y mem_data.
// Aca asumimos que mem_data ya viene listo para escribir en rd.

module write_back_mux
(
	input  [31:0] alu_out,
	input  [31:0] mem_data,
	input  [31:0] link_pc,
	input  [31:0] auipc_val,
	input  [1:0]  wb_src,
	output reg [31:0] data_rd
);

	localparam WB_ALU   = 2'b00;
	localparam WB_MEM   = 2'b01;
	localparam WB_PC4   = 2'b10;
	localparam WB_AUIPC = 2'b11;

	always @(*) begin
		case (wb_src)
			WB_ALU  : data_rd = alu_out;
			WB_MEM  : data_rd = mem_data;
			WB_PC4  : data_rd = link_pc;
			WB_AUIPC: data_rd = auipc_val;
			default : data_rd = alu_out;
		endcase
	end

endmodule
