// accumTable_control.v
// Cameron Shinn

module accumTable_control(clk, reset, wr_en_in, sys_arr_count, submat_m, submat_n, wr_en_out, wr_addr_out);

    parameter DATA_WIDTH = 8; // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);
    localparam ADDR_WIDTH = $clog2(NUM_ACCUM_ROWS);

    input clk;
    input reset;
    input wr_en_in;
    input [$clog2(SYS_ARR_ROWS)-1:0] sys_arr_count;
    input [$clog2(NUM_SUBMATS_M)-1:0] submat_m; // sub-matrix row number (sub-matrix position in the overall matrix)
    input [$clog2(NUM_SUBMATS_N)-1:0] submat_n; // sub-matrix col number (sub-matrix position in the overall matrix)
    output reg [SYS_ARR_COLS-1:0] wr_en_out; // LSB is first column
    output reg [ADDR_WIDTH*SYS_ARR_COLS-1:0] wr_addr_out; // LSBs are first column

    reg [SYS_ARR_COLS-1:0] wr_en_out_c;
    reg [ADDR_WIDTH*SYS_ARR_COLS-1:0] wr_addr_out_c;

    accumTableAddr_control accumTableAddr_control (
        .sys_arr_count(sys_arr_count),
        .submat_m(submat_m),
        .submat_n(submat_n),
        .wr_addr(wr_addr_out[ADDR_WIDTH-1:0])
    );

    always @(clk, reset, wr_en_in, sys_arr_count, submat_m, submat_n) begin
        if (reset) begin
            wr_en_out_c = 0; // need to specify literal width
        end // if (reset)

        else begin
            wr_en_out_c[SYS_ARR_COLS-1:1] = wr_en_out[SYS_ARR_COLS-2:0];
            wr_en_out_c[0] = wr_en_in; 
        end // else

        wr_addr_out_c[ADDR_WIDTH*SYS_ARR_COLS-1:ADDR_WIDTH] = wr_addr_out[ADDR_WIDTH*(SYS_ARR_COLS-1)-1:0];
    end // always @(clk, reset, wr_en_in, sys_arr_count, submat_m, submat_n) 

    always @(posedge clk) begin
        wr_en_out <= wr_en_out_c;
        wr_addr_out <= wr_addr_out_c;
    end // always @(posedge clk)

endmodule
