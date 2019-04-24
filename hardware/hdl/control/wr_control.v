// This module controls the signal to write data into memory
// It will send enble and memory address signal to memArr module
// Alan Qin
// Apri. 22 2019

module wr_control(
  clk, // clock signal
  reset, // reset the inputs and reg signals
  active, // this module only works when the active is high
  wr_en, // enable accessing to the memeory
  wr_addr // write address (offset), the full address should be base addr + wr_addr
  );

  parameter width_height = 4;
  localparam data_width = 8 * width_height; // number of data bits needed

  input clk, reset, active;
  output reg [3:0] wr_en;
  output reg [data_width-1:0] wr_addr;

  reg [3:0] wr_en_c;
  reg [data_width-1:0] wr_addr_c, wr_inc;
  reg wr_dec;

  always@(posedge clk) begin
    wr_en <= wr_en_c;
    wr_addr <= wr_addr_c;
  end

  always@(*) begin
    if(active) begin // start to get read address
      if(wr_en == 4'b1111) begin
        wr_dec = 1;
      end

      if(wr_dec) begin
        wr_en_c = wr_en << 1;
      end

      else begin
        wr_en_c = (wr_en << 1) + 1;
      end

      wr_inc = {7'b0, wr_en[3], 7'b0, wr_en[2], 7'b0, wr_en[1], 7'b0, wr_en[0]};
      wr_addr_c = wr_inc + wr_addr;
    end

    else begin
      wr_en_c = 4'b0000;
    end

    if(reset == 1) begin
      wr_addr_c = 0;
      wr_en_c  = 4'b0000;
      wr_dec = 0;
    end
  end
endmodule
