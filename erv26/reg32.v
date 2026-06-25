module reg32
(
 // Read port 1: register address in address_rs1, data out in data_rs1.
 
 // 5 bits permite hacer referencia a cualquiera de los 32 registros
 input [4:0] address_rs1,
 
 // Read port 2: register address in address_rs2, data out in data_rs2.
 input [4:0] address_rs2,
 
 // Write port: register address in address_rd, data in data_rd.
 input [4:0] address_rd,
 input [31:0] data_rd,
 input write_enable,
 
 // Control signals.
 input clk,
 input reset,
 input ena,
 
 // Output signals
 output [31:0] data_rs1,
 output [31:0] data_rs2,

 // Salida mapeada a I/O: los 8 bits bajos de x31 -> 8 LEDs (DE10-Nano).
 // Ya viene sliceado, se conecta directo a los pines LED[7..0].
 output [7:0] leds_out
 );

	// Register bank: x0 to x31. Register x0 is kept fixed at zero by logic below.
	// Este es el contenido real de los registros. Todo el resto de las cosas son conexiones para manejar estos arreglos.
	reg [31:0] registers [31:0];
	integer i;

	always @(negedge clk, posedge reset) begin
		// Resetear todos los registros (misma senal para todos)
		if (reset) begin
			// Asynchronous active-low reset clears every register.
			for (i = 0; i < 32; i = i + 1) begin
				registers[i] <= 32'b0;
			end
		end
		else begin
			// x0 is hardwired to zero. Writes to x0 are ignored below.
			registers[0] <= 32'b0;

			// Synchronous write. Writes to x0 are ignored because x0 must remain zero.
			if (ena && write_enable && (address_rd != 5'b0)) begin
				registers[address_rd] <= data_rd;
			end
		end
	end

	// Asynchronous reads. Reads from x0 always return zero, regardless of stored state.
	assign data_rs1 = (address_rs1 == 5'b0) ? 32'b0 : registers[address_rs1];
	assign data_rs2 = (address_rs2 == 5'b0) ? 32'b0 : registers[address_rs2];

	// Los 8 bits bajos de x31 salen directo a los 8 LEDs de la DE10-Nano.
	assign leds_out = registers[31][7:0];

endmodule
