// master_multip_control
// Alan Qin and Cameron Shinn

module master_multip_control(
    clk,
    reset,
    active,
    intermed_dim,
    num_row_weight_mat,
    num_col_in_mat,
    base_addr_in, // base addr of the data from input memory
    accum_table_submat_row_in,
    accum_table_submat_col_in,
    accum_table_submat_row_out,
    accum_table_submat_col_out,
    weight_fifo_arr_en,
    weight_fifo_arr_done,
    data_mem_calc_en,
    data_mem_calc_done,
    base_addr_out,
    fifo_ready,
    done
);

parameter width_height = 16;
parameter data_width = width_height * 8;
parameter max_out_width_height = 128;

parameter HOLD = 2'b00;
parameter DELAY = 2'b01;
parameter W_FIFO_ARR = 2'b10;
parameter D_MEM_CALC = 2'b11;

input clk, reset, active;
input weight_fifo_arr_done, data_mem_calc_done;
input [$clog2(width_height)-1:0] num_row_weight_mat, num_col_in_mat, intermed_dim;
input [data_width-1:0] base_addr_in;
input [$clog2(max_out_width_height/width_height)-1:0] accum_table_submat_col_in; 
input [$clog2(max_out_width_height/width_height)-1:0] accum_table_submat_row_in;

output wire [$clog2(max_out_width_height/width_height)-1:0] accum_table_submat_col_out;
output wire [$clog2(max_out_width_height/width_height)-1:0] accum_table_submat_row_out;
output reg weight_fifo_arr_en, data_mem_calc_en;
output wire fifo_ready; //indicates when the fill_fifo instruction can be called
// ^^ need to latch some of the inputs when this goes high so that new data can
//    be written on the bus for the fill_fifo instruction, but we should do that
//    later
output wire base_addr_out;
output wire done;

reg [1:0] state, state_c;

assign accum_table_submat_col_out = accum_table_submat_col_in;
assign accum_table_submat_row_out = accum_table_submat_row_in;
assign fifo_ready = weight_fifo_arr_done;
assign base_addr_out = base_addr_in;
assign done = (state == HOLD) ? 1'b1 : 1'b0;

always @(posedge clk) begin
    state <= state_c;
end

always @(*) begin
    case (state)
        HOLD: begin
            data_mem_calc_en = 1'b0;
            weight_fifo_arr_en = 1'b0;

            if (active) begin
                state_c = W_FIFO_ARR;
                weight_fifo_arr_en = 1'b1;
            end // if (active)
        end // HOLD

        W_FIFO_ARR: begin
            data_mem_calc_en = 1'b0;
            weight_fifo_arr_en = 1'b0;
            
            if(weight_fifo_arr_done) begin
                state_c = D_MEM_CALC;
            end
        end

        D_MEM_CALC: begin
            data_mem_calc_en = 1'b1;
            weight_fifo_arr_en = 1'b0;

            if(data_mem_calc_done) begin
                state_c = HOLD;
            end
        end
    endcase

    if (reset) begin
        state_c = HOLD;
        data_mem_calc_en = 1'b0;
        weight_fifo_arr_en = 1'b0;
    end
end
endmodule
