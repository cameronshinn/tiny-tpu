// store_outputs_control.v
// Cameron Shinn

module master_output_control(clk,
                             reset,
                             start,
                             done,
                             submat_row_in,
                             submat_col_in,
                             submat_row_out,
                             submat_col_out,
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
    parameter ADDR_WIDTH = 8;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS*(MAX_OUT_COLS/SYS_ARR_COLS);
    localparam NUM_SUBMATS_M = MAX_OUT_ROWS/SYS_ARR_ROWS; // not sure if this will do ceiling like I want
    localparam NUM_SUBMATS_N = MAX_OUT_COLS/SYS_ARR_COLS; // not sure if this will do ceiling like I want

    input clk; 
    input reset;
    input start; 
    output wire done; 
    input [$clog2(NUM_SUBMATS_M)-1:0] submat_row_in; 
    input [$clog2(NUM_SUBMATS_N)-1:0] submat_col_in;
    output wire [$clog2(NUM_SUBMATS_M)-1:0] submat_row_out; 
    output wire [$clog2(NUM_SUBMATS_N)-1:0] submat_col_out;
    input [$clog2(SYS_ARR_COLS)-1:0] num_cols_read; // 0-15 -> 1-16
    input [$clog2(SYS_ARR_ROWS)-1:0] num_rows_read; // 0-15 -> 1-16
    output wire [$clog2(SYS_ARR_ROWS)-1:0] row_num;
    input activate;
    output reg relu_en;
    input clear_after; 
    output reg accum_reset; 
    input [ADDR_WIDTH-1:0] wr_base_addr;
    output reg [SYS_ARR_COLS-1:0] wr_en; 
    output wire [SYS_ARR_COLS*ADDR_WIDTH-1:0] wr_addr;

    reg started; // latch to hold the start pulse
    reg started_c;

    reg [$clog2(SYS_ARR_ROWS)-1:0] count;
    reg [$clog2(SYS_ARR_ROWS)-1:0] count_c;

    assign done = ~started; // if we aren't doing anything, we're done
    
    assign submat_row_out = submat_row_in;
    assign submat_col_out = submat_col_in;
    
    assign row_num = count;

    assign wr_addr = {SYS_ARR_COLS{wr_base_addr + count}};

    always @(*) begin
        count_c = {$clog2(SYS_ARR_ROWS){1'b0}};
        started_c = started;
        accum_reset = 1'b0;
        wr_en = {SYS_ARR_COLS{1'b0}};
        relu_en = 1'b0;

        if (start) begin
            started_c = 1'b1;
        end // if (start)

        if (started) begin
            count_c = count + {{$clog2(SYS_ARR_COLS)-1{1'b0}}, 1'b1}; // maybe replace with just "1"
            wr_en = {SYS_ARR_COLS{1'b1}} >> (SYS_ARR_COLS - num_cols_read - 1);
            relu_en = activate;

            if (count == num_rows_read) begin // read up to num_rows_read since we read a row each cc
                started_c = 1'b0;
                count_c = {$clog2(SYS_ARR_COLS){1'b0}};

                if (clear_after) begin
                    accum_reset = 1'b1;
                end // if (clear_after)
            end // if (count == SYS_ARR_COLS)
        end // if (started)

        if (reset) begin
            count_c = {$clog2(SYS_ARR_COLS){1'b0}};
            started_c = 1'b0;
        end // always @(*)
    end // always @(*) 

    always @(posedge clk) begin
        count = count_c;
        started = started_c;
    end // always @(posedge clk)

endmodule // store_outputs_control
