`timescale 1 ps / 1 ps

module tb_sysArr();
    parameter width_height = 4;
    localparam weight_width = 8 * width_height;
    localparam sum_width = 16 * width_height;
    localparam data_width = 8 * width_height;

    // inputs to DUT
    reg clk;
    reg active;
    reg [data_width-1:0] datain;
    reg [weight_width-1:0] win;
    reg [sum_width-1:0] sumin;
    reg [width_height-1:0] wwrite;

    // outputs from DUT
    wire [sum_width-1:0] maccout;
    wire [weight_width-1:0] wout;
    wire [width_height-1:0] wwriteout;
    wire [width_height-1:0] activeout;
    wire [data_width-1:0] dataout;

    // instantiation of DUT
    sysArr DUT (
        .clk      (clk),
        .active   (active),
        .datain   (datain),
        .win      (win),
        .sumin    (sumin),
        .wwrite   (wwrite),
        .maccout  (maccout),
        .wout     (wout),
        .wwriteout(wwriteout),
        .activeout(activeout),
        .dataout  (dataout)
    );

    defparam DUT.width_height = width_height;

    always begin
        #5;
        clk = ~clk;
    end // always

    initial begin
        clk = 1'b0;
        active = 1'b0;
        datain = 32'h0000_0000;
        win = 32'h0000_0000;
        sumin = 64'h0000_0000_0000_0000;
        wwrite = 4'b0000;

        #10;

        //win = 32'h0404_0404;
        win = 32'h0403_0201;
        wwrite = 4'b1111;

        #10;

        //win = 32'h0303_0303;
        win = 32'h0403_0201;

        #10;

        //win = 32'h0202_0202;
        win = 32'h0403_0201;

        #10;

        //win = 32'h0101_0101;
        win = 32'h0403_0201;
        wwrite = 4'b0000;

        #10

        datain = 32'h0000_0000;
        active = 1'b1;

        #10;

        datain = 32'h0000_0401;

        #10;

        datain = 32'h0008_0502;

        #10;

        datain = 32'h0C09_0603;

        #10;

        datain = 32'h0D0A_0700;

        #10;

        datain = 32'h0E0B_0000;

        #10;

        datain = 32'h0F00_0000;
        active = 1'b0;

        #10;

        datain = 32'h0000_0000;

        #30;

        wwrite = 4'b1111;
        win = 32'h0F0B_0703;

        #10;

        win = 32'h0E0A_0602;

        #10;

        win = 32'h0D09_0501;

        #10;

        win = 32'h0C08_0400;
        wwrite = 4'b0000;

        #10;

        datain = 32'h0000_0001;
        active = 1'b1;

        #10;

        datain = 32'h0000_0502;

        #10;

        datain = 32'h0009_0603;

        #10;

        datain = 32'h0D0A_0704;

        #10;

        datain = 32'h0E0B_0800;

        #10;

        datain = 32'h0F0C_0000;

        #10;

        datain = 32'h1000_0000;

        #10;

        datain = 32'h0000_0015;

        #10;

        datain = 32'h0000_1D00;

        #10;

        datain = 32'h0021_0000;

        #10;

        datain = 32'h0400_0000;

        #10;

        datain = 32'h0000_0000;
        active = 1'b0;

        #30;

        wwrite = 4'b1111;
        win = 32'h000C_030A;

        #10;

        win = 32'h00AA_0B02;

        #10;

        win = 32'h000C_010A;

        #10;

        win = 32'h0000_0000;
        wwrite = 4'b0000;

        #10;

        datain = 32'h0000_0000;
        active = 1'b1;

        #10;

        datain = 32'h0000_AA00;

        #10;

        datain = 32'h00DD_BB00;

        #10;

        datain = 32'h01EE_CC00;

        #10;

        datain = 32'h01FF_0000;

        #10;

        datain = 32'h0900_0000;
        active = 1'b0;

        #10;

        datain = 32'h0000_0000;

        #30;

        $stop;
    end // initial
endmodule // tb_sysArr