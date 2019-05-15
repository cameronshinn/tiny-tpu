module tb_wr_mem();

reg clk, reset, rd_active, wr_active;
wire [15:0] wr_en, rd_en;
wire [127:0] wr_addr, rd_addr;
reg [127:0] wr_addr_mem, rd_addr_mem;
reg [127:0] wr_data;
wire [127:0] rd_data;
reg [15:0] wr_en_mem, rd_en_mem;

integer i, j;

always begin
  #5
  clk = ~clk;
end

initial begin
  clk = 0;
  reset = 1;
  wr_data = 0;
  #10;
  for(i = 0; i < 16; i = i + 1) begin
    wr_active = 1;
    wr_data = wr_data << 8 + i;
    #10;
  end
  #10;
  for(j = 0; j < 16; j = j + 1) begin
    rd_active = 1;
    $display(rd_data);
    #10;
  end
end

rd_control RD(
  .clk(clk), // clock signal
  .reset(reset), // reset the inputs and reg signals
  .active(rd_active), // this module only works when the active is high
  .rd_en(rd_en), // enable accessing to the memeory
  .rd_addr(rd_addr) // read address the full address should be base addr + wr_addr
  );

wr_control WR(
  .clk(clk), // clock signal
  .reset(reset), // reset the inputs and reg signals
  .active(wr_active), // this module only works when the active is high
  .wr_en(wr_en), // enable accessing to the memeory
  .wr_addr(wr_addr) // write address (offset), the full address should be base addr + wr_addr
  );

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
