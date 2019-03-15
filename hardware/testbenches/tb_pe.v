module pe_tb();

    reg clk, active, wwrite;
    reg [7:0] datain, win;
    reg [15:0] sumin;

    wire [15:0] maccout;
    wire [7:0] dataout, wout;
    wire wwriteout, activeout;

    integer i;

    pe DUT(
        .clk(clk),
        .active(active),
        .datain(datain),
        .win(win),
        .sumin(sumin),
        .wwrite(wwrite),
        .maccout(maccout),
        .dataout(dataout),
        .wout(wout),
        .wwriteout(wwriteout),
        .activeout(activeout)
    );

    always begin
        #5;
        clk = ~clk;
    end // always

    initial begin
        clk = 1'b0;
        active = 1'b0;
        wwrite = 1'b0;
        datain = 8'h00;
        win = 8'h00;
        sumin = 16'h0000;

        #100;

        wwrite = 1'b1;

        for (i = 0; i < 64; i = i + 1) begin
            #10;
            win = win + 8'h04;
        end

        wwrite = 1'b0;

        for (i = 0; i < 64; i = i + 1) begin
            #10;
            win = win + 8'h02;
        end

    end // initial

endmodule // pe_tb
