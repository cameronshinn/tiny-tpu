// This module controls the signal to read data from memory
// It will send enble and memory signal to memArr module
// Alan Qin
// Apri. 22 2019

module rd_control(
  clk, // clock signal
  reset, // reset the inputs and reg signals
  active, // this module only works when the active is high
  rd_en, // enable accessing to the memeory
  rd_addr // read address
  );

  parameter width_height = 4;
  localparam data_width = 8 * width_height; // number of data bits needed
  
  input clk, reset, active;
  output reg [3:0] rd_en;
  output reg [data_width-1:0] rd_addr;

  reg [3:0] rd_en_c;
  reg [data_width-1:0] rd_addr_c, rd_inc;
  reg rd_dec;

  always@(posedge clk) begin
    rd_en <= rd_en_c;
    rd_addr <= rd_addr_c;
  end

  always@(*) begin
    if(active) begin // start to get read address
      if(rd_en == 4'b1111) begin 
        rd_dec = 1;
      end

      if(rd_dec) begin
        rd_en_c = rd_en << 1;
      end

      else begin
        rd_en_c = (rd_en << 1) + 1;
      end

      rd_inc = {7'b0, rd_en[3], 7'b0, rd_en[2], 7'b0, rd_en[1], 7'b0, rd_en[0]};
      rd_addr_c = rd_inc + rd_addr;
    end

    if(reset == 1) begin
      rd_addr_c = 0;
      rd_en_c  = 4'b0000;
      rd_dec = 0;
    end
  end
endmodule
