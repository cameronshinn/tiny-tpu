// master_fill_fifo_control.v
// Cameron Shinn

module master_fill_fifo_control(clk,
                                reset,
                                start,
                                done,
                                num_row,
                                num_col,
                                base_addr,
                                weightMem_rd_en,
                                weightMem_rd_addr,
                                fifo_active);
    
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    parameter ADDR_WIDTH = 8;

    input clk;
    input reset;
    input start;
    output wire done;
    input [$clog2(SYS_ARR_ROWS)-1:0] num_row; // 0-15 -> 1-16
    input [$clog2(SYS_ARR_COLS)-1:0] num_col; // 0-15 -> 1-16
    input [ADDR_WIDTH-1:0] base_addr;
    output reg [SYS_ARR_COLS-1:0] weightMem_rd_en;
    output wire [SYS_ARR_COLS*ADDR_WIDTH-1:0] weightMem_rd_addr;
    output reg fifo_active;

    reg started;
    reg started_c;

    reg [$clog2(SYS_ARR_ROWS):0] count; // need +1 more bits cause of read delay
    reg [$clog2(SYS_ARR_ROWS):0] count_c; // need +1 more bits cause of read delay

    assign done = ~started;
    assign weightMem_rd_addr = {SYS_ARR_COLS{base_addr + count}};

    always @(*) begin
        started_c = started;
        count_c = count;
        weightMem_rd_en = {SYS_ARR_COLS{1'b0}};
        fifo_active = 1'b0;

        if (start) begin
            started_c = 1'b1;
        end // if (start)

        if (started) begin
            count_c = count + 1;

            if (count < num_col + 1) begin
                weightMem_rd_en = {SYS_ARR_COLS{1'b1}} >> (SYS_ARR_COLS - num_row - 1);
            end // if (count < num_col + 1) begin

            if (count == 1) begin
                fifo_active = 1'b1;
            end // if (count >= 1)

            if (count == SYS_ARR_ROWS + 1) begin
                started_c = 1'b0;
                count_c = {(SYS_ARR_ROWS + 1){1'b0}};
            end // TODO
        end // if (started)

        if (reset) begin
            started_c = 1'b0;
            count_c = {($clog2(SYS_ARR_ROWS) + 1){1'b0}};
        end // if (reset)
    end // always @(*)

    always @(posedge clk) begin
        started = started_c;
        count = count_c;
    end // always @(posedge clk)


endmodule // master_fill_fifo_control