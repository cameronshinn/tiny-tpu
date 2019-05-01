// accumCol.v
// Cameron Shinn

// Inputs:
//
//

// Outputs:
//
//

module accumCol(clk, reset, rd_addr, rd_data, wr_addr, wr_data, wr_en);

    parameter DATA_WIDTH = 8; // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 128; // output height of largest matrix
    parameter MAX_OUT_COLS = 128; // output width of largest possible matrix
    parameter SYS_ARR_WIDTH = 16; // height of the systolic array

    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS * $ceil(MAX_OUT_COLS/SYS_ARR_WIDTH);

    input clk;
    input reset; // sets all entries in column to 0
    input [$clog2(NUM_ACCUM_ROWS)-1:0] rd_addr, wr_addr; // compute the necessary address space
    input [DATA_WIDTH-1:0] wr_data;
    input wr_en;
    output [DATA_WIDTH-1:0] rd_data;

    wire [NUM_ACCUM_ROWS-1:0] en;
    wire [NUM_ACCUM_ROWS*DATA_WIDTH-1:0] d, q;

    wire [DATA_WIDTH-1:0] d_array [NUM_ACCUM_ROWS-1:0];
    wire [DATA_WIDTH-1:0] q_array [NUM_ACCUM_ROWS-1:0];

    reg [DATA_WIDTH-1:0] adder_out:

    dff8 dffArray[NUM_ACCUM_ROWS-1:0] (
        .clk(clk),
        .reset(reset),
        .en(en), // need to control enable so that entries don't accumulate on themselves
        .d(d),
        .q(q)
    );

    // translate d and q signals to an array of DATA_WIDTH-bit inputs and outputs
    generate
        genvar i;
        for (i=0; i<NUM_ACCUM_ROWS; i=i+1) begin : fill_array
            assign d_array[i] = d[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH];
            assign q_array[i] = q[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH];
        end // for (i=0; i<NUM_ACCUM_ROWS; i=i+1)
    endgenerate

    always @(posedge clk) begin

        en = 0; // reset enable signals
        
        if (wr_en) begin
            en[2**wr_addr-1] = 1
            adder_out = wr_data + q_array[wr_addr];
            d_array[wr_addr] = adder_out;

        end // if (wr_en)

        rd_data = q_array[rd_addr];

    end // always @(posedge clk)

endmodule // accumCol
