// accumCol.v
// Cameron Shinn

// Inputs:
//
//

// Outputs:
//
//

module accumCol(clk, reset, rdAddr, rdData, wrAddr, wrData);

    parameter DATA_WIDTH = 8;  // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 1024;  // number of entries in the accumulator column

    input clk;
    input reset;
    input [$clog2(MAX_OUT_ROWS)-1:0] rdAddr, wrAddr;  // compute the necessary address space
    input [DATA_WIDTH-1:0] wrData;
    output [DATA_WIDTH-1:0] rdData;

    dff8 dffArray[MAX_OUT_ROWS-1:0] (
        .clk(clk),
        .reset(reset),
        .en(1'b1),  // might actually need to control the enable signal
        .d(),
        .q()
    );

endmodule  // accumCol