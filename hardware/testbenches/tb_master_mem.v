`timescale 1ns/10ps
module tb_master_mem();

reg clk, reset, active;
reg [7:0] base_addr;
reg [4:0] num_row, num_col;

wire [127:0] out_addr;
wire done;

always begin
  #5;
  clk = ~clk;
end

initial begin
  clk = 0;
  reset = 1;
  active = 0;
  base_addr = 8'h00;
  num_col = 5'b15;
  num_row = 5'b15;
  #10;
  reset = 0;
  active = 1;
  #10;
  active = 0;
  repeat(16) begin
    #10;
  end
  $stop;
end

master_mem_control MEM(
  .clk(clk),
  .reset(reset),
  .active(active),
  .base_addr(base_addr),
  .num_row(num_row),
  .num_col(num_col),
  .out_addr(out_addr),
  .done(done)
);

endmodule
