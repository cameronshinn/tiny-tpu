module sysArr2x2(
    input clk,
    input active,
    input [15:0] datain, // 2 datain inputs
    input [15:0] win, // 2 weight inputs
    input [31:0] sumin, // 2 sumin inputs
    input [1:0] wwrite, // 2 write enable inputs

    output wire [15:0] maccout1, // 2 maccout outputs
    output wire [15:0] maccout2,

    output wire [7:0] wout1, // 2 weight outputs
    output wire [7:0] wout2,

    output wire wwriteout1, // 2 weight write outputs
    output wire wwriteout2,

    output wire activeout1, // 2 active outputs
    output wire activeout2,

    output wire [7:0] dataout1, // 2 dataout outputs
    output wire [7:0] dataout2

);

    // Interconnects
    wire [15:0] macc_topLeft, macc_topRight;
    wire activeOutTopLeft, activeOutTopRight, activeOutBotLeft, activeOutBotRight;
    wire [7:0] dataoutTopLeft, dataoutBotLeft, dataoutTopRight, dataoutBotRight;
    wire [7:0] woutTopLeft, woutTopRight;
    wire wwriteoutTopLeft, wwriteoutTopRight;

    wire [15:0] maccoutBotLeft, maccoutBotRight;
    wire [7:0] woutBotLeft, woutBotRight;
    wire wwriteoutBotLeft, wwriteoutBotRight;

    assign maccout1 = maccoutBotLeft;
    assign maccout2 = maccoutBotRight;

    assign wout1 = woutBotLeft;
    assign wout2 = woutBotRight;

    assign wwriteout1 = wwriteoutBotLeft;
    assign wwriteout2 = wwriteoutBotRight;

    assign activeout1 = activeOutBotLeft;
    assign activeout2 = activeOutBotRight;

    assign dataout1 = dataoutTopRight;
    assign dataout2 = dataoutBotRight;

    pe topLeft(
        .clk      (clk), // done
        .active   (active),
        .datain   (datain[7:0]),
        .win      (win[7:0]),
        .sumin    (sumin[15:0]),
        .wwrite   (wwrite[0]),
        .maccout  (macc_topLeft),
        .dataout  (dataoutTopLeft),
        .wout     (woutTopLeft),
        .wwriteout(wwriteoutTopLeft),
        .activeout(activeOutTopLeft)
    );

     pe topRight(
        .clk      (clk), // done
        .active   (activeOutTopLeft),
        .datain   (dataoutTopLeft),
        .win      (win[15:8]),
        .sumin    (sumin[31:16]),
        .wwrite   (wwrite[1]),
        .maccout  (macc_topRight),
        .dataout  (dataoutTopRight),
        .wout     (woutTopRight),
        .wwriteout(wwriteoutTopRight),
        .activeout(activeOutTopRight)
    );

    pe botLeft(
        .clk      (clk), // done
        .active   (activeOutTopLeft),
        .datain   (datain[15:8]),
        .win      (woutTopLeft),
        .sumin    (macc_topLeft),
        .wwrite   (wwriteoutTopLeft),
        .maccout  (maccoutBotLeft),
        .dataout  (dataoutBotLeft),
        .wout     (woutBotLeft),
        .wwriteout(wwriteoutBotLeft),
        .activeout(activeOutBotLeft)
    );

    pe botRight(
        .clk      (clk), // done
        .active   (activeOutBotLeft & activeOutTopRight),
        .datain   (dataoutBotLeft),
        .win      (woutTopRight),
        .sumin    (macc_topRight),
        .wwrite   (wwriteoutTopRight),
        .maccout  (maccoutBotRight),
        .dataout  (dataoutBotRight),
        .wout     (woutBotRight),
        .wwriteout(wwriteoutBotRight),
        .activeout(activeOutBotRight)
    );

endmodule // sysArr2x2