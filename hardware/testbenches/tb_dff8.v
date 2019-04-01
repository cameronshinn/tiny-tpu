// tb_dff8.v
// Cameron Shinn

`timescale 1ns/10ps

module tb_dff8;

reg clk, reset, en;
reg [7:0] d, q;
integer i;

dff8 tb_dff8 (
    .clk(clk),
    .reset(reset),
    .en(en),
    .d(d),
    .q(q)
);

initial begin
    clk = 1'b0;
    i = 0;
end  // initial

always begin
    #10
    clk = ~clk;
end  // always

always @(posedge clk) begin
    if (clk) begin
        d = 8'b0000_1111;
    end  // if (clk)

    else if (~clk) begin
        d = 8'b1111_0000;
    end  // else if (~clk)

    if (i & 2'b10) begin
        en = 1'b0;
    end  // if (i & 2'b10)

    else begin
        en = 1'b1;
    end  // else

    if (i == 5) begin

    end  // if (i == 5)

    if (i == 6) begin
        $stop
    end  // if (i == 6)

    i = i + 1;
end  // always @(posedge clk)