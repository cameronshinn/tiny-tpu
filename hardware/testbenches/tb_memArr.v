`timescale 1 ps / 1 ps

module tb_memArr();
    parameter width_height = 4;
    localparam data_width = width_height * 8;
    localparam en_bits = width_height;

    reg clk;
    reg [en_bits - 1:0] rd_en;
    reg [en_bits - 1:0] wr_en;
    reg [data_width - 1:0] wr_data;
    reg [data_width - 1:0] rd_addr;
    reg [data_width - 1:0] wr_addr;
    wire [data_width -1:0] rd_data;

    memArr DUT (
        .clk    (clk),
        .rd_en  (rd_en),
        .wr_en  (wr_en),
        .wr_data(wr_data),
        .rd_addr(rd_addr),
        .wr_addr(wr_addr),
        .rd_data(rd_data)
    );

    always begin
        #5;
        clk = ~clk;
    end // always

    initial begin
        clk = 1'b0;
        rd_en = 4'b0000;
        wr_en = 4'b0000;
        wr_data = 32'h0000_0000;
        wr_addr = 32'h0000_0000;
        rd_addr = 32'h0000_0000;

        #10;

        wr_en = 4'b1111;
        wr_addr = 32'h0000_0000;
        wr_data = 32'h0C08_0400;

        #10;

        wr_addr = 32'h0101_0101;
        wr_data = 32'h0D09_0501;

        #10;

        wr_addr = 32'h0202_0202;
        wr_data = 32'h0E0A_0602;

        #10;

        wr_addr = 32'h0303_0303;
        wr_data = 32'h0F0B_0703;

        #10;

        wr_en = 4'b0000;
        rd_en = 4'b1111;
        rd_addr = 323'h0000_0000;

        #10;

        rd_addr = 32'h0101_0101;

        #10;

        rd_addr = 32'h0202_0202;

        #10;

        rd_addr = 32'h0303_0303;

        #30;

        $stop;
    end // initial
endmodule // tb_memArr