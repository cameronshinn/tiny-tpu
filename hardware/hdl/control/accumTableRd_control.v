// accumtTableRd_control.v
// Cameron Shinn

module accumtTableRd_control(sub_row, submat_m, submat_n, rd_addr_out);

    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS*(MAX_OUT_COLS/SYS_ARR_COLS);
    localparam NUM_SUBMATS_M = MAX_OUT_ROWS/SYS_ARR_ROWS; // not sure if this will do ceiling like I want
    localparam NUM_SUBMATS_N = MAX_OUT_COLS/SYS_ARR_COLS; // not sure if this will do ceiling like I want

    input [$clog2(SYS_ARR_ROWS)*SYS_ARR_COLS-1:0] sub_rows;
    input [$clog2(NUM_SUBMATS_M*SYS_ARR_COLS)-1:0] submats_m;
    input [$clog2(NUM_SUBMATS_N)*SYS_ARR_COLS-1:0] submats_n;
    output wire [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1:0] rd_addrs_out;

    accumtTableAddr_control accumtTableAddr_control [0:SYS_ARR_COLS-1] (
        .sub_row(sub_rows),
        .submat_m(submats_m),
        .submat_n(submats_n),
        .addr(rd_addrs_out)
    );

endmodule;
