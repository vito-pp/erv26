module pc_delay (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_in,
    output wire [31:0] pc_out
);

    reg [31:0] pc_d1;
    reg [31:0] pc_d2;
	 reg [31:0] pc_d3;

    always @(posedge clk) begin
        if (rst) begin
            pc_d1 <= 32'b0;
            pc_d2 <= 32'b0;
				pc_d3 <= 32'b0;
        end else begin
            pc_d1 <= pc_in;
            pc_d2 <= pc_d1;
				pc_d3 <= pc_d2;
        end
    end

    assign pc_out = pc_d3;

endmodule