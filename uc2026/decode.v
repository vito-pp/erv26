module decoder
(
 input[15:0] opcode,
 output reg [1:0] selA,
 output reg [1:0] selB,
 output reg [3:0] alu, 
 output reg save0,
 output reg save1,
 output reg save2
 );

	 
	always @(*)
	begin
		case (opcode)
			0:  begin selA=1'bX; selB=1'bX; alu=4'bXXXX; save0=0; save1=0; save2=0; end //NOP
			1:  begin selA=0; selB=1; alu=4'b0010; save0=0; save1=0; save2=1; end //REG2 = REG0 + REG1
			2:  begin selA=0; selB=1; alu=4'b0011; save0=0; save1=0; save2=1; end //REG2 = REG0 - REG1
			3:  begin selA=0; selB=0; alu=4'b0100; save0=1; save1=0; save2=0; end //REG0 = REG0 + 1
			4:  begin selA=1; selB=0; alu=4'b0100; save0=0; save1=1; save2=0; end //REG1 = REG1 + 1
			5:  begin selA=1'bX; selB=1'bX; alu=4'b0000; save0=1; save1=0; save2=0; end //REG0 = 0
			6:  begin selA=1'bX; selB=1'bX; alu=4'b0000; save0=0; save1=1; save2=0; end //REG1 = 0
			7:  begin selA=1'bX; selB=1'bX; alu=4'b0000; save0=0; save1=0; save2=1; end //REG2 = 0
			
		endcase 
	end


 
endmodule