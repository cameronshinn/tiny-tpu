// Instantiates a systolic array row with four PEs in it, and drives input signals.

module tb_sysArrRow();

    localparam row_width = 4;
    localparam weight_width = 8 * row_width;
    localparam sum_width = 16 * row_width;

    // Inputs to DUT
    reg clk;
    reg active;
    reg [7:0] datain;
    reg [weight_width-1:0] win;
    reg [sum_width-1:0] sumin;
    reg [row_width-1:0] wwrite;

    // Outputs from DUT
    wire [sum_width-1:0] maccout;
    wire [weight_width-1:0] wout;
    wire [row_width-1:0] wwriteout;
    wire [row_width-1:0] activeout;
    wire [7:0] dataout;

    // Instantiation of DUT
    sysArrRow DUT (
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

    defparam DUT.row_width = row_width;

    always begin
        #5;
        clk = ~clk;
    end // always

    initial begin
        clk = 1'b0;
        active = 1'b0;
        datain = 8'h00;
        win = 32'h0000_0000;
        sumin = 64'h0000_0000_0000_0000;
        wwrite = 4'b0000;

        #10;

        win = 32'h4433_2211;
        wwrite = 4'b1111;

        #10;

        win = 32'hFFFF_FFFF;
        wwrite = 4'b0000;

        #10;

        active = 1'b1;

        #10;

        datain = 8'h01;

        #10;

        datain = 8'h02;

        #10;

        datain = 8'h03;

        #10;

        datain = 8'h04;

        #10;

        active = 1'b0;

        #50;

        $stop;
    end // initial
endmodule // tb_sysArrRow