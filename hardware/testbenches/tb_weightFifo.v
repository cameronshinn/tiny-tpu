// tb_weightFifo.v
// Cameron Shinn

`timescale 1ns/10ps

module tb_weightFifo;

	reg clk, reset, en;
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
		en = 1'b1;
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

		if (i >= 8 && i & 1) begin
			en = 1'b0;
		end  // if (i >= 8 && i & 1)

		else begin
			en = 1'b1;
		end  // else

		if (i == 19) begin
			reset = 1'b1;
		end  // if (i = 19)

		else begin
			reset = 1'b0;
		end  // else

		if (i == 21) begin
			$stop;
		end  // if (i == 20)

		i = i + 1;
	end  // always @(negedge clk)
endmodule  // tb_weightFifo
