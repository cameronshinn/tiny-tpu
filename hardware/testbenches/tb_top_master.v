// tb_top_master.v
// Cameron Shinn

`timescale 1ns/10ps

module tb_top_master;

    parameter WIDTH_HEIGHT = 16;
    parameter DATA_WIDTH = 8;
    parameter MAX_MAT_WH = 128;

    // TPU outputs
    reg clk;
    reg reset;
    reg start;
    reg [2:0] opcode;
    reg [$clog2(WIDTH_HEIGHT)-1:0] dim_1;
    reg [$clog2(WIDTH_HEIGHT)-1:0] dim_2;
    reg [$clog2(WIDTH_HEIGHT)-1:0] dim_3;
    reg [7:0] addr_1;
    reg [$clog2(MAX_MAT_WH/WIDTH_HEIGHT)-1:0] accum_table_submat_row_in;
    reg [$clog2(MAX_MAT_WH/WIDTH_HEIGHT)-1:0] accum_table_submat_col_in;
    reg [WIDTH_HEIGHT*DATA_WIDTH-1:0] inputMem_wr_data;
    reg [WIDTH_HEIGHT*DATA_WIDTH-1:0] weightMem_wr_data;

    wire done;
    wire fifo_ready;
    wire [WIDTH_HEIGHT*DATA_WIDTH-1:0] outputMem_rd_data;

    integer i;
    reg [7:0] data_in;

    top TPU (
        .clk                      (clk),
        .reset                    (reset),
        .start                    (start),
        .done                     (done),
        .opcode                   (opcode),
        .dim_1                    (dim_1),
        .dim_2                    (dim_2),
        .dim_3                    (dim_3),
        .addr_1                   (addr_1),
        .accum_table_submat_row_in(accum_table_submat_row_in),
        .accum_table_submat_col_in(accum_table_submat_row_in),
        .fifo_ready               (fifo_ready),
        .inputMem_wr_data         (inputMem_wr_data),
        .weightMem_wr_data        (weightMem_wr_data),
        .outputMem_rd_data        (outputMem_rd_data)
    );

    initial begin
        clk = 1'b0;
        reset = 1'b0;
        start = 1'b0;
        i = 0;
    end // initial

    always begin
        clk = ~clk;
        #10;
    end // always

    always @(*) begin
        if (i == 1) begin
            reset = 1'b1;
        end // if (i == 1)

        if (i == 2) begin
            reset = 1'b0;
            opcode = 3'b111;
            start = 1'b1;
        end // if (i == 2)

        if (i == 3) begin
            start = 1'b0;
        end // if (i == 3)

        if (i == 8) begin
            start = 1'b1;
            opcode = 3'b001;
            dim_1 = 4'hF;
            dim_2 = 4'hF;
            addr_1 = 8'h40;
        end // if (i == 4) begin

        if (i > 8 && i <= 24) begin
            data_in = i - 8;
            inputMem_wr_data = {WIDTH_HEIGHT{data_in}};
        end // if (i > 8 && i <= 24)

        if (i == 9) begin
            start = 1'b0;
        end

        if (i == 26) begin
            start = 1'b1;
            opcode = 3'b010;
            dim_1 = 4'hF;
            dim_2 = 4'hF;
            addr_1 = 8'h68;
        end // if (i == 4) begin

        if (i == 27) begin
            start = 1'b0;
        end // if (i == 27)

        if (i > 26 && i <= 42) begin
            data_in = i - 26;
            weightMem_wr_data = {WIDTH_HEIGHT{data_in}};
        end // if (i > 8 && i <= 24)

        if (i == 44) begin
            start = 1'b1;
            opcode = 3'b011;
            dim_1 = 4'hF;
            dim_2 = 4'hF;
            addr_1 = 8'h68;
        end // if (i == 44)

        if (i == 45) begin 
            start = 1'b0;
        end // if (i == 45)

        if (i == 64) begin
            start = 1'b1;
            opcode = 3'b100;
            dim_1 = 4'b1111;
            dim_2 = 4'b1111;
            dim_3 = 4'b1111;
            addr_1 = 8'h40;
            accum_table_submat_row_in = 3'b010;
            accum_table_submat_col_in = 3'b010;
        end // if (i = 63)

        if (i == 65) begin
            start = 1'b0;
        end

        if (i == 200) begin
            $stop;
        end // if (i == 10)
    end // always @(*)

    always @(posedge clk) begin
        i = i + 1;
    end // always @(posedge clk)

endmodule // tb_top_master
