// accumTable_control.v
// Cameron Shinn

/*
This module is a latch-based control system for addressing within the
accumulator table. Since The addressing for each column of the accumulator table
is the same in successive clock cycles (column M writes to address A in clock
cycle N, and column M+1 writes to address A in clock cycle N+1), it is only
necessary to control the addressing of the first column. The addressing of the
first column is passed along the pipeline, where a column receives the address
from the column to its left in the following clock cycle.
*/

module accumTableWr_control(clk, reset, wr_en_in, sub_row, submat_m, submat_n, wr_en_out, wr_addr_out);

    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);
    localparam ADDR_WIDTH = $clog2(NUM_ACCUM_ROWS);
    localparam NUM_SUBMATS_M = MAX_OUT_ROWS/SYS_ARR_ROWS; // not sure if this will do ceiling like I want
    localparam NUM_SUBMATS_N = MAX_OUT_COLS/SYS_ARR_COLS; // not sure if this will do ceiling like I want

    input clk;
    input reset;
    input wr_en_in;
    input [$clog2(SYS_ARR_ROWS)-1:0] sub_row;
    input [$clog2(NUM_SUBMATS_M)-1:0] submat_m; // sub-matrix row number (sub-matrix position in the overall matrix)
    input [$clog2(NUM_SUBMATS_N)-1:0] submat_n; // sub-matrix col number (sub-matrix position in the overall matrix)
    output reg [SYS_ARR_COLS-1:0] wr_en_out; // LSB is first column
    output reg [ADDR_WIDTH*SYS_ARR_COLS-1:0] wr_addr_out; // LSBs are first column

    wire [ADDR_WIDTH-1:0] addr_1;
    reg [SYS_ARR_COLS-1:0] wr_en_out_c;
    reg [ADDR_WIDTH*SYS_ARR_COLS-1:0] wr_addr_out_c;

    accumTableAddr_control accumTableAddr_control (
        .sub_row(sub_row),
        .submat_m(submat_m),
        .submat_n(submat_n),
        .addr(addr_1)
    );

    always @(clk, reset, wr_en_in, sub_row, submat_m, submat_n) begin
        if (reset) begin
            wr_en_out_c = 0; // need to specify literal width
        end // if (reset)

        else begin
            wr_en_out_c[SYS_ARR_COLS-1:1] = wr_en_out[SYS_ARR_COLS-2:0];
            wr_en_out_c[0] = wr_en_in; 
        end // else

        wr_addr_out_c[ADDR_WIDTH*SYS_ARR_COLS-1:ADDR_WIDTH] = wr_addr_out[ADDR_WIDTH*(SYS_ARR_COLS-1)-1:0];
        wr_addr_out_c[ADDR_WIDTH-1:0] = addr_1;
    end // always @(clk, reset, wr_en_in, sub_row, submat_m, submat_n) 

    always @(posedge clk) begin
        wr_en_out <= wr_en_out_c;
        wr_addr_out <= wr_addr_out_c;
    end // always @(posedge clk)

endmodule
