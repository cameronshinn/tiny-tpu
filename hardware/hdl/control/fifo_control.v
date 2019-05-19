// This module controls the fifo signals
// It set the enble of fifo to sequentially store fifo into mmu by col
// Alan Qin
// Apri 22 2019
module fifo_control(
  clk,
  reset,
  active,
  fifo_en,
  done
  );

  parameter fifo_width = 16;

  input clk, reset, active;
  output reg [fifo_width-1:0] fifo_en;
  output reg done;
  reg [fifo_width-1:0] fifo_en_c;
  reg fifo_dec; // enable starts to decrease
  reg state, state_c;

  parameter Hold = 1'b0;
  parameter Start = 1'b1;

  always@(posedge clk) begin
    fifo_en <= fifo_en_c;
    state <= state_c;
  end

  always@(*) begin
    case (state)
      Hold: begin
        if(active) begin
          state_c = Start;
        end
      end

      Start: begin
        if(fifo_en == 16'hffff) begin
          fifo_dec = 1;
        end

        if(fifo_dec) begin
          fifo_en_c = fifo_en << 1;
          if(fifo_en == 16'h0000) begin
            done = 1;
          end
        end

        else begin
          fifo_en_c = (fifo_en << 1) + 1;
        end
      end
      endcase

    if(reset) begin
      fifo_en_c = 16'h0000;
      state_c = Hold;
      done = 0;
    end
  end
endmodule
