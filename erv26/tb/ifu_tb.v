`timescale 1ns/1ps

module ifu_tb;

    reg clk;
    wire [31:0] pc;

    ifu dut (
        .clk(clk),
        .pc(pc)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        #200;
        $stop;
    end

endmodule
