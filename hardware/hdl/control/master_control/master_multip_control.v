module master_multip_control(
  clk,
  reset,
  active,
  intermed_dim,
  num_row_weight_mat,
  num_col_in_mat,
  base_data, // base addr of the data
  accum_table_submat_row_in,
  accum_table_submat_col_in,
  accum_table_submat_row_out,
  accum_table_submat_col_out,
  weight_mem_fifo_en,
  weight_mem_fifo_done,
  weight_fifo_arr_en,
  weight_fifo_arr_done,
  data_mem_calc_en,
  data_mem_calc_done,
  fifo_ready,
  done
)；

parameter width_height = 16;
parameter data_width = width_height * 8;
parameter MAX_OUT_ROWS = 128;
parameter MAX_OUT_COLS = 128;

parameter Hold = 2'b00;
parameter W_mem_fifo = 2'b01;
parameter W_fifo_arr = 2'b10;
parameter D_mem_calc = 2'b11;

input clk, reset, active;
input weight_fifo_arr_done, data_mem_calc_done;
input [$clog2(width_height)-1:0] num_row_weight_mat, num_col_in_mat, intermed_dim;
input [data_width-1:0] base_data;
input [$clog2(MAX_OUT_COLS/SYS_ARR_WIDTH)-1:0] accum_table_submat_col_in; 
input [$clog2(MAX_OUT_ROWS/SYS_ARR_HEIGHT)-1:0] accum_table_submat_row_in;

output wire [$clog2(MAX_OUT_COLS/SYS_ARR_WIDTH)-1:0] accum_table_submat_col_out;
output wire [$clog2(MAX_OUT_ROWS/SYS_ARR_HEIGHT)-1:0] accum_table_submat_row_out;
output reg weight_fifo_arr_en, data_mem_calc_en;
output wire fifo_ready; //indicates when the fill_fifo instruction can be called
// ^^ need to latch some of the inputs when this goes high so that new data can
//    be written on the bus for the fill_fifo instruction, but we should do that
//    later

output wire done;

reg [1:0] state, state_c;

assign accum_table_submat_col_out = accum_table_submat_col_in;
assign accum_table_submat_row_out = accum_table_submat_row_in;
assign fifo_ready = (state != W_fifo_arr) ? 1'b1 : 1'b0;
assign done = (state == hold) ? 1'b1 : 1'b0;

always@(posedge clk) begin
  state <= state_c;
end

always@(*) begin
  case(state)
    Hold: begin
      if(active) begin
        state_c = W_fifo_arr;
      end
    end

    W_fifo_arr: begin
      weight_fifo_arr_en = 1;
      if(weight_fifo_arr_done) begin
        state_c = D_mem_calc;
        weight_fifo_arr_en = 0;
      end
    end

    D_mem_calc: begin
      data_mem_calc_en = 1;
      if(data_mem_calc_done) begin
        data_mem_calc_en = 0;
        weight_fifo_arr_en = 0;
        weight_mem_fifo_en = 0;
        state_c = Hold;
      end
    end
  endcase

  if(reset) begin
    state_c = Hold;
    data_mem_calc_en = 0;
    weight_fifo_arr_en = 0;
    weight_mem_fifo_en = 0;
  end
end
endmodule
