`timescale 1ns/10ps

module tb_fifo();

reg clk, reset, active, stagger_load;
reg [15:0] rd_en, wr_en;
reg [15:0] fifo_en;
reg [127:0] wr_data, rd_addr, wr_addr, weightIn;
wire [15:0] fifo_en_out;
wire [127:0] rd_data, weightOut;
wire done;

always begin
  #5;
  clk = ~clk;
end

initial begin
  clk = 0;
  reset = 1;
  active = 0;
  #10;
  reset = 0;
  #10;
  /*
  // start to write weights into mem
  wr_en = 16'hffff;
  wr_addr = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9,
             8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16};
  wr_data = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9,
             8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16};
  #10;
  wr_addr = {8'd17, 8'd18, 8'd19, 8'd20, 8'd21, 8'd22, 8'd23, 8'd24, 8'd25,
             8'd26, 8'd27, 8'd28, 8'd29, 8'd30, 8'd31, 8'd32};
  wr_data = {8'd0, 8'd5, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9,
            8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16};
  #10;
  //start to read weights from mem into fifo
  rd_en = 16'hffff;
  wr_en = 16'h0000;
  rd_addr = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9,
             8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16};
  #10;
  rd_addr = {8'd17, 8'd18, 8'd19, 8'd20, 8'd21, 8'd22, 8'd23, 8'd24, 8'd25,
             8'd26, 8'd27, 8'd28, 8'd29, 8'd30, 8'd31, 8'd32};
  #10;
  fifo_en = 16'hffff;
  weightIn = rd_data;
  #10;
  weightIn = rd_data;
  #10;
  // get the weights out of fifo
  active = 1;
  $display(weightOut);
  #10;
  repeat(20) begin
    $display(weightOut);
    #10;
  end
  $stop;*/

  active = 1;
  stagger_load = 0;
  repeat(16) begin
    fifo_en = fifo_en_out;
    weightIn = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9,
               8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16};
    #10;
  end
  fifo_en = 0;
  #10;
  #10;
  $stop;
  active = 1;
  stagger_load = 1;
  weightIn = 0;
  repeat(32) begin
      fifo_en = fifo_en_out;
      $display(weightOut);
      #10;
  end
  $stop;
end

fifo_control FIFO_OUT(
  .clk(clk),
  .reset(reset),
  .active(active),
  .stagger_load(stagger_load),
  .fifo_en(fifo_en_out),
  .done(done)
  );

weightFifo tb_weightFifo (
  .clk(clk),
	.reset(reset),
	.en(fifo_en),
	.weightIn(weightIn),
	.weightOut(weightOut)
);

defparam tb_weightFifo.FIFO_INPUTS = 16;
defparam tb_weightFifo.FIFO_DEPTH = 16;

memArr MEM(
   .clk(clk),
   .rd_en(rd_en),
   .wr_en(wr_en),
   .wr_data(wr_data),
   .rd_data(rd_data),
   .wr_addr(wr_addr),
   .rd_addr(rd_addr)
);
defparam MEM.width_height = 16;

endmodule
