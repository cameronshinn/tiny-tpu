// tb_accumTable.v
// Cameron Shinn

`timescale 1ns/10ps

module tb_accumTable;

    parameter DATA_WIDTH = 8; // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);
    localparam ADDR_WIDTH = $clog2(NUM_ACCUM_ROWS);
    localparam NUM_SUBMATS_M = MAX_OUT_ROWS/SYS_ARR_ROWS; // not sure if this will do ceiling like I want
    localparam NUM_SUBMATS_N = MAX_OUT_COLS/SYS_ARR_COLS; // not sure if this will do ceiling like I want

    reg clk;
    reg reset;

    wire [DATA_WIDTH*SYS_ARR_COLS-1:0] rd_data;
    reg [DATA_WIDTH*SYS_ARR_COLS-1:0] wr_data;

    reg [SYS_ARR_COLS-1:0] rd_en_in;
    reg [$clog2(NUM_SUBMATS_M)-1:0] submat_rd_m;
    reg [$clog2(NUM_SUBMATS_N)-1:0] submat_rd_n;
    wire [$clog2(SYS_ARR_ROWS)-1:0] sub_row_rd;

    reg wr_en_in;
    reg [$clog2(NUM_SUBMATS_M)-1:0] submat_wr_m;
    reg [$clog2(NUM_SUBMATS_N)-1:0] submat_wr_n;
    wire [$clog2(SYS_ARR_ROWS)-1:0] sub_row_wr;

    wire [SYS_ARR_COLS-1:0] wr_en;

    wire [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1:0] rd_addr;
    wire [$clog2(NUM_ACCUM_ROWS)*SYS_ARR_COLS-1:0] wr_addr;

    accumTable accumTable (
        .clk(clk),
        .reset({16{reset}}),
        .rd_en(rd_en_in),
        .wr_en(wr_en),
        .rd_addr(rd_addr),
        .wr_addr(wr_addr),
        .rd_data(rd_data),
        .wr_data(wr_data)
    );

    accumTableWr_control accumTableWr_control (
        .clk(clk),
        .reset(reset),
        .wr_en_in(wr_en_in),
        .sub_row(sub_row_wr),
        .submat_m(submat_wr_m),
        .submat_n(submat_wr_n),
        .wr_en_out(wr_en),
        .wr_addr_out(wr_addr)
    );

    accumTableRd_control accumTableRd_control (
        .sub_row(sub_row_rd),
        .submat_m(submat_rd_m),
        .submat_n(submat_rd_n),
        .rd_addr_out(rd_addr)
    );

    integer count;

    initial begin
        clk = 1'b0;
        count = -1;
        reset = 16'h0000;
        wr_data = 0;
    end // initial

    always begin
        #10
        clk = ~clk;
    end // always

    assign sub_row_rd = (count % 16);
    assign sub_row_wr = (count % 16);

    always @(posedge clk) begin

        if (count == -1) begin
            reset = 16'hFFFF;
        end // if (count == -1)

        else begin
            reset = 16'h0000;
        end // else

        if (count >= 0) begin
            wr_data = (wr_data << 8) | (count % 32);
        end // if (count >= 0)

        if (count < 32) begin
            submat_wr_m = 8'd0;
            submat_wr_n = 8'd0;
            wr_en_in = 1'b1;
            rd_en_in = 16'h0000;
        end // if (count < 32)

        else if (count < 64) begin
            submat_wr_m = 8'd2;
            submat_wr_n = 8'd3;
            wr_en_in = 1'b1;
            rd_en_in = 16'h0000;
        end // else if (count < 64)

        else if (count < 96) begin
            submat_rd_m = 8'd0;
            submat_rd_n = 8'd0;
            wr_en_in = 1'b0;
            rd_en_in = 16'hFFFF;
        end // else if (count < 96)

        else if (count < 128) begin
            submat_rd_m = 8'd2;
            submat_rd_n = 8'd3;
            wr_en_in = 1'b0;
            rd_en_in = 16'hFFFF;
        end // else if (count < 128)

        else if (count == 160) begin
            reset = 16'hFFFF;
        end // else if (count == 160)

        else if (count < 160) begin
            reset = 1'b0;
            submat_rd_m = 8'd2;
            submat_rd_n = 8'd3;
            wr_en_in = 1'b0;
            rd_en_in = 16'hFFFF;
        end // else if (count < 160)

        else begin
            $stop;
        end // else

        count = count + 1;
    end // always @(negedge clk)

endmodule // module tb_accumTable