module pe_tb();

    reg clk, active, wwrite;
    reg [7:0] datain, win;
    reg [15:0] sumin;

    wire [15:0] maccout;
    wire [7:0] dataout;

    pe DUT(
        .clk(clk),
        .active(active),
        .datain(datain),
        .win(win),
        .sumin(sumin),
        .wwrite(wwrite),
        .maccout(maccout),
        .dataout(dataout)
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

        active = 1'b1;

        #100;

        active = 1'b0;

        #100;

        win = 8'h11;
        datain = 8'h01;

        #50;

        wwrite = 1'b1;

        #10;

        wwrite = 1'b0;

        #10;

        win = 8'hFF;

        #10;

        active = 1'b1;
    end // initial

endmodule // pe_tb
