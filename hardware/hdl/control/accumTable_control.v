// accumTable_control.v
// Cameron Shinn

/*
 * This control module outputs the proper addressing for an accumulator table
 * column. The inputs are what number output the systolic array is outputting
 * and which sub-matrix of the divide and conquer matrix multiply is currently
 * being output by the systolic array. Since each column of the systolic array
 * needs to store its outputs at the same address in successive clock cycles,
 * the output of this module can be latched into a pipeline that moves between
 * the columns of the accumulator (as opposed to calculating all of the columns
 * addresses at once).
 */

module accumTable_control(sys_arr_count, submat_m, submat_n, wr_addr);

    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS*(MAX_OUT_COLS/SYS_ARR_COLS);
    localparam NUM_SUBMATS_M = MAX_OUT_ROWS/SYS_ARR_ROWS; // not sure if this will do ceiling like I want
    localparam NUM_SUBMATS_N = MAX_OUT_COLS/SYS_ARR_COLS; // not sure if this will do ceiling like I want

    input [$clog2(SYS_ARR_ROWS)-1:0] sys_arr_count;
    input [$clog2(NUM_SUBMATS_M)-1:0] submat_m; // sub-matrix row number (sub-matrix position in the overall matrix)
    input [$clog2(NUM_SUBMATS_N)-1:0] submat_n; // sub-matrix col number (sub-matrix position in the overall matrix)
    output wire [$clog2(NUM_ACCUM_ROWS)-1:0] wr_addr; // write addresses for all columns concatenated

    assign wr_addr = (submat_n*MAX_OUT_ROWS) + (submat_m*SYS_ARR_ROWS) + (SYS_ARR_ROWS-1-sys_arr_count);

endmodule // accumTable_control