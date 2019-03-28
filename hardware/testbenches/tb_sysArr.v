module tb_sysArr();
    parameter width_height = 2;
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
        datain = 16'h0000;
        win = 16'h0000;
        sumin = 32'h0000_0000;
        wwrite = 2'b00;

        #10;

        win = 16'h0101;
        wwrite = 2'b11;

        #10;

        wwrite = 2'b00;
        datain = 16'h0001;
        active = 1'b1;

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

        $stop;
    end // initial
endmodule // tb_sysArr