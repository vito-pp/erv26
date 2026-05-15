module fetch
(
 input[15:0] currPC,
 input clk,
 input nreset,
 output [15:0] nextPC
 );

	//reg[15:0] q;
	 
	/*always @(posedge clk, negedge nreset) begin
		if (!nreset) q <= 0;
		else q <= currPC + 1;
	end

	*/
	assign nextPC = (!nreset)? 0 : currPC + 1;
 
endmodule