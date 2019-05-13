module tb_wr_mem();

reg clk;
reg [15:0] wr_en, rd_en;
reg [127:0] wr_addr, wr_data, rd_addr;
wire [127:0] rd_data;

integer i, j;

always begin
  #5
  clk = ~clk;
end

initial begin
  clk = 0;
  wr_en = 0;
  wr_addr = 0;
  wr_data = 0;
  rd_en = 0;
  rd_addr = 0;
  #10;
  for(i=0; i<128; i=i+1) begin
    wr_en = wr_en << 1 + 1;
    wr_data = wr_data << 8 + i;
    wr_addr = wr_addr << 8 + i;
    #10;
  end
  #10;
  for(j=0; j<128; j=j+1) begin
    rd_en = rd_en << 1 + 1;
    rd_addr = rd_addr << 8 + 1;
    $display(rd_data );
    #10;
  end
  #10;
  $stop;
end

wr_mem_control CONTROL (.clk(clk), .wr_en(wr_en), .wr_addr(wr_addr), .wr_data(wr_data),
    .rd_en(rd_en), .rd_addr(rd_addr), .rd_data(rd_data));

endmodule
