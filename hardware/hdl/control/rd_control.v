// This module controls the signal to read data from memory
// It will send enble and memory signal to memArr module
// Alan Qin
// Apri. 22 2019

module rd_control(
  clk, // clock signal
  reset, // reset the inputs and reg signals
  active, // this module only works when the active is high
  rd_en, // enable accessing to the memeory
  rd_addr // read address the full address should be base addr + wr_addr
  );

  parameter width_height = 16;
  localparam data_width = 8 * width_height; // number of data bits needed

  input clk, reset, active;
  output reg [width_height-1:0] rd_en;
  output reg [data_width-1:0] rd_addr;

  reg [width_height-1:0] rd_en_c;
  reg [data_width-1:0] rd_addr_c, rd_inc;
  reg rd_dec;

  always@(posedge clk) begin
    rd_en <= rd_en_c;
    rd_addr <= rd_addr_c;
  end

  always@(*) begin
    if(active) begin // start to get read address
      if(rd_en == 16'hffff) begin
        rd_dec = 1;
      end

      if(rd_dec) begin
        rd_en_c = rd_en << 1;
      end

      else begin
        rd_en_c = (rd_en << 1) + 1;
      end

      rd_inc = {15'b0, rd_en[3], 15'b0, rd_en[2], 15'b0, rd_en[1], 15'b0, rd_en[0]};
      rd_addr_c = rd_inc + rd_addr;
    end

    else begin
      rd_en_c = 16'h0000;
    end

    if(reset == 1) begin
      rd_addr_c = 0;
      rd_en_c  = 16'h0000;
      rd_dec = 0;
    end
  end
endmodule
