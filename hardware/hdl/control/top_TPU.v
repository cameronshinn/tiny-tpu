module top_TPU(
  clk,
  reset,
  wr_en_weight, //write weights into mem, enable
  wr_addr_weight,
  wr_data_weight, // write data into mem, enable
  wr_en_fifo, // write weight from mem to fifo
  load_en_weight,// write weight from fifo to arr
  base_addr_weight, // base addr for weights in mem
  wr_en_data, // write data into mem
  wr_addr_output, // addr for output addr
  mult_en, // do the calculation
  base_addr_data // base addr for data
  )

  parameter width_height = 16;
  parameter data_width = width_height * 8;

  input clk, reset, wr_en_weight, wr_en_data, mult_en, wr_en_fifo;
  input [data_width-1:0] wr_addr_weight, wr_data_weight;
  input [data_width-1:0] wr_addr_output, base_addr_weight, base_addr_data;

  reg fifo_active, fifo_rd_en, fifo_reset;
  reg [data_width-1:0] fifo_addr;
  reg [data_width-1:0] wr_addr, rd_addr;
  reg wr_en, rd_en; // read and write data enable
  reg rd_active;

  wire fifo_done;
  wire [width_height-1:0] fifo_en;
  wire [data_width-1:0] fifo_data;
  wire wr_active;

  always@(posedge clk or reset) begin
    fifo_rd_addr <= fifo_rd_addr_c;
    wr_data_addr <= wr_data_addr_c;

    if(reset) begin
      fifo_rd_addr_c = base_addr_weight;
      wr_data_addr_c = base_addr_data;
    end
  end

  // load weights from mem to fifo
  always@(*) begin
    // loading the weight into fifo
    if(wr_en_fifo) begin
      // enable memory and fifo
      fifo_rd_en = 1;
      fifo_active = 1;
      fifo_reset = 0;
      fifo_rd_addr_c = fifo_rd_addr - 1;

      if(fifo_done) begin
        fifo_active = 0;
        fifo_reset = 1;
      end
    end
  end

  // load weights from fifo into array
  always@(posedge clk) begin
    if(load_en_weight) begin
      fifo_active = 1;
      fifo_reset = 0;
    end

    if(fifo_done) begin
      fifo_active = 0;
      fifo_reset = 1;
    end
  end

  // start the calculation
  always@(*) begin
    if(mult_en) begin
      rd_active = 1;

      if(wr_active) begin
        wr_data_addr_c = wr_data_addr + 1;
      end
  end

  fifo_control FIFO_CONTROL (.clk(clk), .reset(fifo_reset), .active(fifo_active)),
      .fifo_en(fifo_en), .done(fifo_done));

  memArr FIFO_MEM (.clk(clk), .rd_en(fifo_rd_en), .wr_en(wr_en_weight),
      .wr_data(wr_data_weight), .rd_data(fifo_data), wr_addr(wr_addr_weight),
      .rd_addr());

  memArr DATA_MEM (.clk(clk), .rd_en(rd_en), .wr_en(wr_en), .wr_data(),
      .rd_data(), .wr_addr(wr_addr), .rd_addr(rd_addr));
