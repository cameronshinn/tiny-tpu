// reluArr.v
// Cameron Shinn

// Inputs:
//
// in -- input array of values

// Outputs:
//
// out -- output array of ReLU output values

module reluArr(en, in, out);

	parameter DATA_WIDTH = 16;
	parameter ARR_INPUTS = 16;
	
	localparam ARR_WIDTH = DATA_WIDTH*ARR_INPUTS;

	input en;
	input [ARR_WIDTH-1:0] in;
	output wire [ARR_WIDTH-1:0] out;

	reluMux muxArr[ARR_INPUTS-1:0] (
        .en (en),
		.in (in),
		.out(out)
	);

endmodule  // reluArr