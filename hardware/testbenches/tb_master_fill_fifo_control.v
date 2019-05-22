// tb_master_fill_fifo_control.v
// Cameron Shinn

`timescale 1ns/10ps

module tb_master_fill_fifo_control;

    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    parameter ADDR_WIDTH = 8;

    reg clk;
    reg reset;
    reg start;
    wire done_master_out;
    wire [$clog2(SYS_ARR_ROWS)-1:0] num_row;
    wire [$clog2(SYS_ARR_ROWS)-1:0] num_col;
    wire [ADDR_WIDTH-1:0] base_addr;
    wire [SYS_ARR_COLS-1:0] weightMem_rd_en;
    wire [SYS_ARR_COLS*ADDR_WIDTH-1:0] weightMem_rd_addr;
    wire fifo_active;

    wire [SYS_ARR_COLS-1:0] fifo_en;
    wire done_fifo_out;

    master_fill_fifo_control master_fill_fifo_control (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done_master_out),
        .num_row(num_row),
        .num_col(num_col),
        .base_addr(base_addr),
        .weightMem_rd_en(weightMem_rd_en),
        .weightMem_rd_addr(weightMem_rd_addr),
        .fifo_active(fifo_active)
    );

    fifo_control fifo_control (
        .clk(clk),
        .reset(reset),
        .active(fifo_active),
        .stagger_load(1'b0),
        .fifo_en(fifo_en),
        .done(done_fifo_out)
    );

    assign num_row = 15;
    assign num_col = 15;
    assign base_addr = 12;

    initial begin
        clk = 1'b0;
    end // initial

    always begin
        #10;
        clk = ~clk;
    end // always

    integer count = 0;

    always @(posedge clk) begin
        if (count == 25) begin
            $stop;
        end // if (count == 20)

        if (count == 1) begin
            reset = 1'b1;
        end // if (count == 1)

        else begin
            reset = 1'b0;
        end // else

        if (count == 2) begin
            start = 1'b1;
        end // if (count == 2)

        else begin
            start = 1'b0;
        end // else

        count = count + 1;
    end // always @(posedge clk)

endmodule // tb_master_fill_fifo_control
