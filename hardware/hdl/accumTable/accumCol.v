// accumCol.v
// Cameron Shinn

module accumCol(clk, clear, rd_en, wr_en, rd_addr, wr_addr, rd_data, wr_data);

    parameter DATA_WIDTH = 8; // number of bits for one piece of data
    parameter MAX_OUT_ROWS = 128; // output height of largest matrix
    parameter MAX_OUT_COLS = 128; // output width of largest possible matrix
    parameter SYS_ARR_COLS = 16; // height of the systolic array

    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS * (MAX_OUT_COLS/SYS_ARR_COLS);

    input clk;
    input clear; // clears array and sets it to 0
    input rd_en; // reads the data at rd_addr when high
    input wr_en; // writes (and accumulates) data to wr_addr when high
    input [$clog2(NUM_ACCUM_ROWS)-1:0] rd_addr;
    input [$clog2(NUM_ACCUM_ROWS)-1:0] wr_addr;
    output reg signed [DATA_WIDTH-1:0] rd_data;
    input signed [DATA_WIDTH-1:0] wr_data;

    reg [DATA_WIDTH-1:0] mem [NUM_ACCUM_ROWS-1:0];

    integer i; // used for indexing

    always @(posedge clk) begin
        if (wr_en) begin
            mem[wr_addr] <= mem[wr_addr] + wr_data;
        end // if (wr_en)

        if (rd_en) begin
            rd_data <= mem[rd_addr];
        end // if (rd_en)

        if (clear) begin
            for (i = 0; i < NUM_ACCUM_ROWS; i = i + 1) begin // clear all entries to 0
                mem[i] <= 0; // not sure if there is a good way to define literal width
            end // for (i = 0; i < NUM_ACCUM_ROWS; i = i + 1)
        end // if (clear)

    end // always @(posedge clk)
endmodule // accumCol
