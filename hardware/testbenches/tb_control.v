module tb_control();

reg clk, reset;
reg fifo_active, rd_active, wr_active;
reg signed [7:0] data [15:0];
reg signed [7:0] weight [15:0];
reg [3:0] wwrite;
reg [31:0] win;

wire [31:0] rd_addr, wr_addr;
wire [31:0] rd_data, wr_data;
wire [3:0] fifo_en, rd_en, wr_en;
wire fifo_done;

always begin
  #5;
  clk = ~clk;
end

initial begin
  $readmemb("data.txt",data, 0000);
  clk = 0;
  reset = 1;
  repeat(2) @(posedge clk); // Wait 2 clock cycles
  reset <= 1'b0;
  repeat(2) @(posedge clk); // Wait 2 clock cycles
  start <= 1'b1;
  repeat(1) @(posedge clk); // Wait 1 clock cycle
  start <= 1'b0;

  // load weights from fifo
  fifo_active = 1;
  #10;
  #10;
  #10;
  #10;
  $stop;

  //start to read values
  wwrite = 4'b1111;
  win = {8'd12, 8'd13, 8'd14, 8'd15};
  rd_active = 1;
  #10;
  #10;
  #10;
  #10;
  $stop;
  wwrite = 0000;
  wr_active = 1;
  repeat(12) begin
    #10;
  end
  $stop;

end

fifo_control FIFO (.clk(clk), .reset(reset), .active(fifo_active),
    .fifo_en(fifo_en), .done(fifo_done));

rd_control RD (.clk(clk), .reset(reset), .active(rd_active), .rd_en(rd_en),
    .rd_addr(rd_addr));

wr_control WR (.clk(clk), .reset(reset), .active(wr_active), .wr_en(wr_en),
    .wr_addr(wr_addr));

memArr MEM (.clk(clk), .rd_en(rd_en), .wr_en(wr_en), .wr_data(wr_data),
    .rd_data(rd_data), wr_addr(wr_addr), .rd_addr(rd_addr));

sysArr ARR (.clk(clk), .active(arr_active), .datain(rd_data), .win(win),
    .sumin(0), .wwrite(wwrite), .maccout(), .wout(),
    .wwriteout(), .activeout(), .dataout(wr_data));

endmodule
