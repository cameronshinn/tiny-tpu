// tb_accumTable.v
// Cameron Shinn

`timescale 1ns/10ps

module tb_accumCol;

    parameter DATA_WIDTH = 8; // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 128; // output height of largest matrix
    parameter MAX_OUT_COLS = 128; // output width of largest possible matrix
    parameter SYS_ARR_COLS = 16; // height of the systolic array

    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);

    reg clk;
    reg reset; // clears array and sets it to 0
    reg rd_en; // reads the data at rd_addr when high
    reg wr_en; // writes (and accumulates) data to wr_addr when high
    reg [$clog2(NUM_ACCUM_ROWS)-1:0] rd_addr;
    reg [$clog2(NUM_ACCUM_ROWS)-1:0] wr_addr;
    wire [DATA_WIDTH-1:0] rd_data;
    reg [DATA_WIDTH-1:0] wr_data;

    accumCol test_column (
        .clk(clk),
        .reset(reset),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .rd_addr(rd_addr),
        .wr_addr(wr_addr),
        .rd_data(rd_data),
        .wr_data(wr_data)
    );

    integer count, i;

    initial begin
        clk = 1'b0;
        count = 0;
        rd_en = 1'b1;
        wr_en = 1'b1;
    end // initial

    always begin
        #10
        clk = ~clk;
    end // always

    always @(negedge clk) begin
        i = count - 2;

        if (count == 0) begin
            reset = 1'b1;
        end // if (count == 0)

        else if (count == 1) begin
            reset = 1'b0;
        end // else if (count == 1)

        else begin
            wr_data = i % 8;
            rd_addr = (i - 1) % 8;
            wr_addr = i % 8;
        end // else

        if (i == 64) begin
            reset = 1'b1;
            wr_en = 1'b0;
        end // if (count == 133)

        else if (count == 70) begin
            $stop;
        end // if (count == 135)

        /*if (count > 1) begin
            if (count % 2 == 1) begin
                rd_en = 1'b1;
                wr_en = 1'b1;
            end // if (count % 2 == 1)

            else begin
                rd_en = 1'b0;
                wr_en = 1'b0;
            end // else
        end // if (count > 1)*/

        count = count + 1;
    end
endmodule // tb_accumCol
