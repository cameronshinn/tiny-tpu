// This module controls the signal of systolic array opperations.
// The control module will get weights from fifo and do the matrix
// multiplication
// Author Alan Qin
// April 12th 2019
// version 1, assume that fifo has been loaded already

module control_sys(
  input fifo_wr,
  input reset,
  input clk,
  input wr_data,
  input datain
);

parameter Write = 3'b001;
parameter Calc = 3'b010;

reg [2:0] state;
reg weight, active;
reg pre_data;

always @(posedge clk) begin
  case(state)
    Hold: begin
      if(fifo_wr == 1)
        state = Write;
    end

    Write: begin
      if(fifo_wr == 0)
        state = Calc;
    end

    Calc: begin
      active = 1;
    end

  endcase

end

weightFifo Weight (.clk(clk), .reset(reset), .en(fifo_wr),
    .weightIn(wr_data), .weightOut(weight));
sysArr Sys (.clk(clk), .active(active), .datain(datain), .win(weight), .sumin(pre_data),
    .wwrite(), .maccout(), .wout(), .wwriteout(), .activeout(), dataout());

endmodule
