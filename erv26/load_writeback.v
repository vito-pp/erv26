// load_writeback.v  -  ERV26
//
// Maneja el write-back de los LOAD contra la latencia de 2 ciclos de la RAM.
//
// Problema: la RAM entrega el dato (q) 2 ciclos despues de presentar la
// direccion. Si el LOAD escribe en su ciclo de ejecucion, captura basura.
//
// Solucion ("load delay slot", estilo MIPS):
//   - El LOAD NO escribe en su ciclo de ejecucion (se suprime con !mem_read).
//   - Se atrasan (rd, valido) 2 ciclos para alinear con la llegada de q.
//   - 2 ciclos despues se escribe reg32[rd_atrasado] <= q.
//
// Este bloque va ENTRE la logica de write-back y el puerto de escritura del
// reg32. Reemplaza las conexiones directas:
//     decode.rd          -> reg32.address_rd
//     write_back_mux.out -> reg32.data_rd
//     decode.reg_write   -> reg32.write_enable
// por las salidas de este modulo.
//
// IMPORTANTE: requiere 2 "delay slots" (NOPs) despues de cada LOAD en el
// programa, para que ninguna instruccion real quiera escribir el mismo ciclo
// que el write-back atrasado del LOAD (este tiene prioridad y la pisaria).
//
// rst activo en alto (consistente con ifu / pc_delay / nop_inyection).

module load_writeback
(
	input  wire        clk,
	input  wire        rst,

	// De la instruccion actual en ejecucion (decode)
	input  wire        mem_read,        // 1 si es LOAD
	input  wire        reg_write,       // reg_write normal del decode
	input  wire [4:0]  rd,              // rd de la instruccion actual

	// Datos candidatos a escribir
	input  wire [31:0] wb_data_normal,  // salida del write_back_mux (no-LOAD)
	input  wire [31:0] mem_data,        // q de la RAM (dato del LOAD)

	// Al puerto de escritura del reg32
	output wire [4:0]  address_rd,
	output wire [31:0] data_rd,
	output wire        write_enable
);

	// Atrasar (rd, valido) 2 ciclos para alinear con la latencia de la RAM.
	reg [4:0] rd_d1, rd_d2;
	reg       v_d1,  v_d2;

	always @(posedge clk) begin
		if (rst) begin
			rd_d1 <= 5'b0; rd_d2 <= 5'b0;
			v_d1  <= 1'b0; v_d2  <= 1'b0;
		end else begin
			rd_d1 <= rd;        v_d1 <= mem_read;
			rd_d2 <= rd_d1;     v_d2 <= v_d1;
		end
	end

	// 1 cuando toca escribir el dato del LOAD (2 ciclos despues del fetch del LOAD).
	wire load_wb = v_d2;

	// Mux del puerto de escritura:
	//   - load_wb=1 -> escribir q (dato del LOAD) en el rd atrasado.
	//   - load_wb=0 -> write-back normal, suprimiendo el del LOAD (!mem_read)
	//                  para que el LOAD NO escriba basura en su ciclo de ejecucion.
	assign write_enable = load_wb ? 1'b1     : (reg_write && !mem_read);
	assign address_rd   = load_wb ? rd_d2    : rd;
	assign data_rd      = load_wb ? mem_data : wb_data_normal;

endmodule
