// store_outputs_control.v
// Cameron Shinn

module store_outputs_control(clk,
                             reset,
                             start,
                             done,
                             submat_row,
                             submat_col,
                             num_cols_read,
                             num_rows_read,
                             row_num,
                             accum_reset,
                             activate,
                             relu_en,
                             clear_after,
                             wr_base_addr,
                             wr_en,
                             wr_addr);

    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS*(MAX_OUT_COLS/SYS_ARR_COLS);
    localparam NUM_SUBMATS_M = MAX_OUT_ROWS/SYS_ARR_ROWS; // not sure if this will do ceiling like I want
    localparam NUM_SUBMATS_N = MAX_OUT_COLS/SYS_ARR_COLS; // not sure if this will do ceiling like I want

    input clk;
    input reset;
    input start;
    output reg done;
    output reg [$clog2(NUM_SUBMATS_M)-1:0] submat_row;
    output reg [$clog2(NUM_SUBMATS_N)-1:0] submat_col;
    input [$clog2(SYS_ARR_COLS)-1:0] num_cols_read;
    input [$clog2(SYS_ARR_ROWS)-1:0] num_rows_read;
    output reg [$clog2(SYS_ARR_ROWS)-1:0] row_num;
    output reg accum_reset;
    input activate;
    output relu_en;
    input clear_after;
    input [-1:0] wr_base_addr;
    output reg wr_en;
    output reg [] wr_addr; // TODO: determine address width

endmodule // store_outputs_control
