// tb_weightFifo.v
// Cameron Shinn

`timescale 1ns/10ps

module tb_weightFifo;

	reg clk, reset;
	reg [3:0] en;
	reg [31:0] weightIn;
	wire [31:0] weightOut;
	
	weightFifo tb_weightFifo (
		.clk(clk),
		.reset(reset),
		.en(en),
		.weightIn(weightIn),
		.weightOut(weightOut)
	);

	integer i;
	integer j;

	initial begin
		clk = 1'b0;
		i = 0;
		en = 0;
		reset = 1'b0;
	end  // initial

	always begin
		#10
		clk = ~clk;
	end  // always

	always @(negedge clk) begin
		for (j = 0; j < 4; j = j + 1) begin
			weightIn[j*8 +: 8] = i*4+j; 
		end  // for (j = 0; j < 4; j = j + 1)

		/*if (i >= 8 && i & 1) begin
			en = 0;
		end  // if (i >= 8 && i & 1)*/

		if (i == 9) begin
			en = 4'b0001;
		end  // else if (i == 9)

		else if (i == 10) begin
			en = 4'b0011;
		end  // else if (i == 10)

		else if (i == 11) begin
			en = 4'b0111;
		end  // else if (i == 11)

		else if (i == 12) begin
			en = 4'b1111;
		end  // else if (i == 12)

		if (i == 24) begin
			reset = 1'b1;
		end  // if (i = 19)

		else begin
			reset = 1'b0;
		end  // else

		if (i == 26) begin
			$stop;
		end  // if (i == 20)

		i = i + 1;
	end  // always @(negedge clk)
endmodule  // tb_weightFifo
