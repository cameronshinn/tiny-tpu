// accumTable_control.v
// Cameron Shinn

module accumTable_control(clk, reset, sys_arr_count, submat_m, submat_n, wr_en, wr_addr);

    parameter DATA_WIDTH = 8; // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);

    input clk;
    input [$clog2(SYS_ARR_ROWS)-1:0] sys_arr_count;
    input [$clog2(NUM_SUBMATS_M)-1:0] submat_m; // sub-matrix row number (sub-matrix position in the overall matrix)
    input [$clog2(NUM_SUBMATS_N)-1:0] submat_n; // sub-matrix col number (sub-matrix position in the overall matrix)
    output [SYS_ARR_COLS-1:0] wr_en;
    output [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1:0] wr_addr;

    reg [$clog2(NUM_ACCUM_ROWS)-1:0] addr_latch [0:SYS_ARR_COLS-1];
    reg en_latch [0:SYS_ARR_COLS-1];
    reg [$clog2(NUM_ACCUM_ROWS--1:0)] addr_latch_0;

    accumTableAddr_control accumTableAddr_control (
        .sys_arr_count(sys_arr_count),
        .submat_m(submat_m),
        .submat_n(submat_n),
        .wr_addr(addr_latch_0)
    );

    always @(posedge clk) begin
        if (reset) begin
            generate
                genvar i;
                for (i = 0; i < SYS_ARR_COLS; i = i + 1) begin
                    addr_latch[i] <= 0; // there is probably a better way to specify bit width 
                end // for (i = 0; i < SYS_ARR_COLS; i = i + 1)
            endgenerate
        end // if (reset)

        else begin
            generate
                genvar j;
                for (j = 0; j < SYS_ARR_COLS-1; j = j + 1) begin
                    addr_latch[j+1] <= addr_latch[j];
                end // for (j = 0; j < SYS_ARR_COLS)
            endgenerate

            addr_latch[0] <= addr_latch_0;
        end // else
    end // always @(posedge clk)

endmodule
