module tb_sysArr2x2();

    reg clk, active;
    reg [15:0] datain, win;
    reg [31:0] sumin;
    reg [1:0] wwrite;

    wire [15:0] maccout1, maccout2;
    wire [7:0] wout1, wout2, dataout1, dataout2;
    wire wwriteout1, wwriteout2, activeout1, activeout2;

    always begin
        #5;
        clk = ~clk;
    end // always

    sysArr2x2 DUT (
        .clk       (clk),
        .active    (active),
        .datain    (datain),
        .win       (win),
        .sumin     (sumin),
        .wwrite    (wwrite),
        .maccout1  (maccout1),
        .maccout2  (maccout2),
        .wout1     (wout1),
        .wout2     (wout2),
        .wwriteout1(wwriteout1),
        .wwriteout2(wwriteout2),
        .activeout1(activeout1),
        .activeout2(activeout2),
        .dataout1  (dataout1),
        .dataout2  (dataout2)
    );

    initial begin
        clk = 1'b0;
        active = 1'b0;
        datain = 16'h0000;
        win = 16'h0000;
        sumin = 32'h0000_0000;
        wwrite = 2'b00;

        #10;

        win = 16'h0101;
        wwrite = 2'b11;

        #20;

        wwrite = 2'b00;
        active = 1'b1;
        datain = 16'h0001;

        #10;

        datain = 16'h0101;

        #10;

        datain = 16'h0101;
        active = 1'b0;

        #10;

        active = 1'b1;

        #10;

        datain = 16'h0302;

        #10;

        datain = 16'h0400;
        active = 1'b0;

    end // initial

endmodule // tb_sysArr2x2