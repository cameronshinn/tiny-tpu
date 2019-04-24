// This module controls the fifo signals
// It set the enble of fifo to sequentially store fifo into mmu by col
// Alan Qin
// Apri 22 2019
module fifo_control(
  clk,
  reset,
  active,
  fifo_en
  );

  parameter fifo_width = 4;

  input clk, reset, active;
  output reg [fifo_width-1:0] fifo_en;
  reg [fifo_width-1:0] fifo_en_c;

  always@(posedge clk) begin
    fifo_en <= fifo_en_c;
  end

  always@(*) begin
    if(active) begin
      fifo_en_c = (fifo_en << 1) + 1;

      if(fifo_en = 4'b1111) begin
        fifo_en_c = 4'b1111;
      end
    end

    else begin
      fifo_en_c = 4'b0000;
    end

    if(reset) begin
      fifo_en_c = 4'b0000;
    end
  end
endmodule
