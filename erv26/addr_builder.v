// Addr Builder / Jump Control para ERV26 (RV32I).
//
// Sumador dedicado al calculo de direcciones de memoria y de saltos,
// independiente de la ALU. Esto permite que en la misma etapa del pipeline
// la ALU resuelva la operacion aritmetica/comparacion y este modulo arme la
// direccion en paralelo, sin alargar el camino critico de la ALU con muxes
// extra ni serializar el calculo.
//
// Calcula tres sumas en paralelo:
//   - rs1 + imm   -> direccion para LOAD/STORE y target de JALR
//   - PC  + imm   -> target de JAL/BRANCH y resultado de AUIPC
//   - PC  + 4     -> return address (rd para JAL/JALR) y next_pc por default
//
// Luego, segun el opcode (y branch_taken para los BRANCH), selecciona:
//   - data_addr : direccion para el bus de memoria de datos
//   - next_pc   : direccion de la proxima instruccion
//   - jump      : flag de redireccion (para que el control de pipeline
//                 flushee las instrucciones que ya entraron al pipe)
//   - link_pc   : valor PC+4 a guardar en rd cuando JAL/JALR
//   - auipc_val : valor PC+imm a guardar en rd cuando AUIPC
//
// Notas RISC-V:
//   - El LSB del target de JALR se fuerza a 0 (spec seccion 2.5).
//   - JAL y BRANCH ya tienen el LSB del inmediato puesto a 0 por el
//     IMM Builder (formatos J y B), no hace falta forzarlo aca.
//   - Errores de alineamiento (target no multiplo de 4) son una excepcion
//     opcional descripta en la parte III del enunciado; no se manejan aca.

module addr_builder
(
	input  [31:0] pc,
	input  [31:0] rs1,
	input  [31:0] imm,
	input  [6:0]  opcode,
	input         branch_taken,    // viene de la ALU para BRANCH

	output     [31:0] data_addr,   // LOAD/STORE
	output reg [31:0] next_pc,     // proxima instruccion
	output reg        jump,        // 1 = hay que redirigir el fetch
	output     [31:0] link_pc,     // PC+4 para guardar en rd (JAL/JALR)
	output     [31:0] auipc_val    // PC+imm para guardar en rd (AUIPC)
);

	// Opcodes RV32I
	localparam OP_LUI    = 7'b0110111;
	localparam OP_AUIPC  = 7'b0010111;
	localparam OP_JAL    = 7'b1101111;
	localparam OP_JALR   = 7'b1100111;
	localparam OP_BRANCH = 7'b1100011;
	localparam OP_LOAD   = 7'b0000011;
	localparam OP_STORE  = 7'b0100011;

	// --- Sumadores en paralelo (puro combinacional) -----------------------
	wire [31:0] pc_plus_4   = pc  + 32'd4;
	wire [31:0] pc_plus_imm = pc  + imm;
	wire [31:0] rs1_plus_imm = rs1 + imm;

	// --- Salidas con asignacion directa ----------------------------------
	// Direccion para LOAD/STORE: siempre rs1+imm.
	assign data_addr = rs1_plus_imm;

	// Return address para JAL/JALR: el PC siguiente lineal.
	assign link_pc   = pc_plus_4;

	// Resultado de AUIPC: PC+imm (el IMM Builder ya armo imm como U-type).
	assign auipc_val = pc_plus_imm;

	// --- Jump control ----------------------------------------------------
	// JALR fuerza el LSB del target a 0.
	wire [31:0] jalr_target = {rs1_plus_imm[31:1], 1'b0};

	always @(*) begin
		case (opcode)
			OP_JAL: begin
				next_pc = pc_plus_imm;
				jump    = 1'b1;
			end

			OP_JALR: begin
				next_pc = jalr_target;
				jump    = 1'b1;
			end

			OP_BRANCH: begin
				// Solo salta si la ALU dice que la condicion se cumple.
				next_pc = branch_taken ? pc_plus_imm : pc_plus_4;
				jump    = branch_taken;
			end

			default: begin
				// Toda otra instruccion avanza linealmente. El control de
				// pipeline puede ignorar 'jump' en este caso.
				next_pc = pc_plus_4;
				jump    = 1'b0;
			end
		endcase
	end

endmodule
