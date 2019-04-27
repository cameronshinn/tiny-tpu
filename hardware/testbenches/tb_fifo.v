module tb_fifo();

reg clk, reset, active;
wire [3:0] fifo_en;

always begin
  #5
  clk = ~clk;
end

initial begin
  clk = 0;
  reset = 1;
  active = 0;
  #10;
  reset = 0;
  #10;
  active = 1;
  #10;
  #10;
  #10;
  #10;
  #10;
  #10;
  #10;
  #10;
  #10;
  #10;
  
  $stop;
end

fifo_control c (.clk(clk), .reset(reset), .active(active), .fifo_en(fifo_en));

endmodule
