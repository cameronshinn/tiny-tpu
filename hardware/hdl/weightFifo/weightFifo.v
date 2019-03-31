// weightFifo.v
// Cameron Shinn

// Inputs:
//
// clk -- clock signal
// reset -- when high, simultaneously sets all registers to 0 on positive clock edge
// en -- when high, moves the data through FIFO
// weightIn -- input at front of FIFO

// Outputs:
//
// weightOut -- output at end of FIFO

module weightFifo (
    input clk,
    input reset,
    input en,
    input [FIFO_WIDTH-1:0] weightIn,

    output wire [FIFO_WIDTH-1:0] weightOut
);

    parameter DATA_WIDTH = 8;  // must be same as DATA_WIDTH in dff8.v
    parameter FIFO_INPUTS = 4;
    parameter FIFO_WIDTH = DATA_WIDTH*FIFO_INPUTS;  // number of output weights
    parameter FIFO_STAGES = 4;  // number of stage weights

    wire [FIFO_WIDTH*FIFO_STAGES-1:0] dffIn;  // inputs to each element of dff array
    wire [FIFO_WIDTH*FIFO_STAGES-1:0] dffOut;   // ouputs of each element of dff array
    
    dff8 dffArray[FIFO_INPUTS*FIFO_STAGES-1:0] (
        .clk(clk),
        .reset(reset),
        .en(en),
        .d(dffIn),
        .q(dffOut)
    );

    assign dffIn[FIFO_WIDTH-1:0] = weightIn;  // assign beginning of array to input
    assign weightOut = dffOut[FIFO_WIDTH*FIFO_STAGES-1:FIFO_WIDTH*(FIFO_STAGES-1)];  // assign end of array to output

    generate
        genvar i;
        for (i=1; i<FIFO_STAGES; i=i+1) begin : assignConn // use for-loop to dynamically make connections (for scalability)
            assign dffIn[FIFO_WIDTH*(i+1)-1:FIFO_WIDTH*i] = dffOut[FIFO_WIDTH*i-1:FIFO_WIDTH*(i-1)];
        end  // for (i=0; i<FIFO_STAGES; i=i+1)
    endgenerate
endmodule  // weightFifo