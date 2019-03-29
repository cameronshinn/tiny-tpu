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

        win = 32'h0404_0404;
        wwrite = 4'b1111;

        #10;

        win = 32'h0303_0303;

        #10;

        win = 32'h0202_0202;

        #10;

        win = 32'h0101_0101;
        wwrite = 4'b0000;

        #10

        datain = 32'h0000_0001;
        active = 1'b1;

        #10;

        datain = 32'h0000_0101;

        #10;

        datain = 32'h0001_0101;

        #10;

        datain = 32'h0101_0101;

        #10;

        datain = 32'h0101_0100;

        #10;

        datain = 32'h0101_0000;

        #10;

        datain = 32'h0100_0000;
        active = 1'b0;

        #10;

        datain = 32'h0000_0000;

        #100;

        $stop;
    end // initial
endmodule // tb_sysArr