// accumTable.v
// Cameron Shinn

// Inputs:
//
// clk -- 
// reset -- 
// rdAddr -- 
// wrAddr -- 
// wrData -- 

// Outputs:
//
// rdData -- 

module accumTable(clk, reset, rdAddr, rdDatam, wrAddr, wrData);

    parameter DATA_WIDTH = 8;  // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 1024;  // output number of rows in 
    parameter MAX_OUT_COLS = 1024;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    localparam IN_WIDTH

    input clk;
    input reset;
    input [$clog2(MAX_OUT_ROWS):0] rdAddr, wrAddr;
    input [] wrData;
    output [] rdData;