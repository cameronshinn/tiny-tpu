// accumtTableRd_control.v
// Cameron Shinn

module accumTableRd_control(sub_row, submat_m, submat_n, rd_addr_out);

    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS*(MAX_OUT_COLS/SYS_ARR_COLS);
    localparam NUM_SUBMATS_M = MAX_OUT_ROWS/SYS_ARR_ROWS; // not sure if this will do ceiling like I want
    localparam NUM_SUBMATS_N = MAX_OUT_COLS/SYS_ARR_COLS; // not sure if this will do ceiling like I want

    input [$clog2(SYS_ARR_ROWS)-1:0] sub_row;
    input [$clog2(NUM_SUBMATS_M)-1:0] submat_m;
    input [$clog2(NUM_SUBMATS_N)-1:0] submat_n;
    output wire [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1:0] rd_addr_out;

    accumTableAddr_control accumtTableAddr_control [0:SYS_ARR_COLS-1] (
        .sub_row(sub_row),
        .submat_m(submat_m),
        .submat_n(submat_n),
        .addr(rd_addr_out)
    );

endmodule
