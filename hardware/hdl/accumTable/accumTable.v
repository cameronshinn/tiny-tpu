// accumTable.v
// Cameron Shinn

// Inputs:
//
// clk -- clock signal
// reset -- sets all elements in a column to 0. One signal for each column.
// rd_addr -- address to read from
// wr_addr -- address to write and accumulate to
// wr_data -- data to be accumulated and stored in wr_addr

// Outputs:
//
// rd_data -- data read from rd_addr

module accumTable(clk, reset, rd_en, wr_en, rd_addr, wr_addr, rd_data, wr_data);

    parameter DATA_WIDTH = 8; // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);

    input clk;
    input [SYS_ARR_COLS-1:0] reset;
    input [SYS_ARR_COLS-1:0] rd_en;
    input [SYS_ARR_COLS-1:0] wr_en;
    input [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1:0] rd_addr;
    input [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1:0] wr_addr;
    output wire [DATA_WIDTH*SYS_ARR_COLS-1:0] rd_data;
    input [DATA_WIDTH*SYS_ARR_COLS-1:0] wr_data;

    accumCol colArray [0:SYS_ARR_COLS-1] (
        .clk(clk),
        .reset(reset),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .rd_addr(rd_addr),
        .wr_addr(wr_addr),
        .rd_data(rd_data),
        .wr_data(wr_data)
    );

endmodule // accumTable
