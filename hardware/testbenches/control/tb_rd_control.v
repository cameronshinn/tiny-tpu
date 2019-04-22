module tb_rd_control();

reg clk;
reg reset;
reg active;
wire [3:0] rd_en;
wire [31:0] rd_addr;

always begin
 #5;
 clk = ~clk;
end

initial begin
  clk = 1'b0;
  reset = 1'b1;
  active = 1'b0;
  #10;
  reset = 1'b0;
  #10;
  #10;
  active = 1'b1;
  #10;
  $stop;
  #10;
  #10;
  #10;
  #10;
  #10;
  #10;
  $stop;
end

rd_control addr (.clk(clk), .reset(reset), .active(active), .rd_en(rd_en), .rd_addr(rd_addr));

endmodule
