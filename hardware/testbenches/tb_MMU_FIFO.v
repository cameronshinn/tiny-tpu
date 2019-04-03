module tb_MMU_FIFO();

    parameter DATA_WIDTH = 8;
    parameter FIFO_INPUTS = 4;
    parameter FIFO_STAGES = 4;
    localparam FIFO_WIDTH = DATA_WIDTH * FIFO_INPUTS;
    parameter width_height = 4;
    localparam weight_width = 8 * width_height;
    localparam sum_width = 16 * width_height;
    localparam data_width = 8 * width_height;

    // FIFO side inputs
    reg clk;
    reg reset;
    reg en;
    reg [FIFO_WIDTH-1:0] weightIn;

    // MMU side inputs
    reg active;
    reg [data_width-1:0] datain;
    reg [sum_width-1:0] sumin;
    reg [width_height-1:0] wwrite;

    // FIFO side outputs
    wire [FIFO_WIDTH-1:0] weightOut;

    // MMU side outputs
    wire [sum_width-1:0] maccout;
    wire [weight_width-1:0] wout;
    wire [width_height-1:0] wwriteout;
    wire [width_height-1:0] activeout;
    wire [data_width-1:0] dataout;

    wire [weight_width-1:0] win;
    assign win = weightOut; // MMU_DUT.win = FIFO_DUT.weightOut
    // weights now coming from FIFO

    // Module instantiations

    weightFifo FIFO_DUT(
        .clk      (clk),
        .reset    (reset),
        .en       (en),
        .weightIn (weightIn),
        .weightOut(weightOut) // Wire to win of MMU
    );

    defparam FIFO_DUT.DATA_WIDTH = DATA_WIDTH;
    defparam FIFO_DUT.FIFO_INPUTS = FIFO_INPUTS;
    defparam FIFO_DUT.FIFO_STAGES = FIFO_STAGES;

    sysArr MMU_DUT(
        .clk      (clk),
        .active   (active),
        .datain   (datain),
        .win      (win), // Wire to weightOut of FIFO
        .sumin    (sumin),
        .wwrite   (wwrite),
        .maccout  (maccout),
        .wout     (wout),
        .wwriteout(wwriteout),
        .activeout(activeout),
        .dataout  (dataout)
    );

    defparam MMU_DUT.width_height = width_height;

    always begin
        #5;
        clk = ~clk;
    end // always

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        en = 1'b0;
        weightIn = 32'h0000_0000;

        active = 1'b0;
        datain = 32'h0000_0000;
        sumin = '0;
        wwrite = 4'b0000;

        #10;

        reset = 1'b0;
        en = 1'b1;
        weightIn = 32'h0F0B_0703;

        #10;

        weightIn = 32'h0E0A_0602;

        #10;

        weightIn = 32'h0D09_0501;

        #10;

        weightIn = 32'h0C08_0400;

        #10;

        weightIn = 32'hDEAD_BEEF;
        wwrite = 4'b1111;

        #30;

        wwrite = 4'b0000;

        #10;

        en = 1'b0;
    end // initial
endmodule // tb_MMU_FIFO