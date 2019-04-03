// reluArr.v
// Cameron Shinn

// Inputs:
//
// in -- input array of values

// Outputs:
//
// out -- output array of ReLU output values

module reluArr(in, out);

	parameter DATA_WIDTH = 8;
	parameter ARR_INPUTS = 4;
	localparam ARR_WIDTH = DATA_WIDTH*ARR_INPUTS;

	input [ARR_WIDTH-1:0] in;
	output wire [ARR_WIDTH-1:0] out;

	reluMux muxArr[ARR_INPUTS-1:0] (
		.in (in),
		.out(out)
	);

endmodule  // reluArr