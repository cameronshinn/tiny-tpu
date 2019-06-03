// master_control.v
// Cameron Shinn

/**
 * The master controller takes instructions from the bus as its input and drives
 * the corresponding control signals to the individual controllers of each
 * submodule
 * 
 * Instruction set:
 * signals marked with NONE are ignored
 * 
 * read_inputs() - Read inputs from the bus into input memory
 *     @opcode: 001 (1)
 *     @dim_1: number of rows in matrix
 *     @dim_2: number of columns in matrix
 *     @dim_3: NONE
 *     @addr_1: base address to store in input memory
 *     @accum_table_submat_row_in: NONE
 *     @accum_table_submat_col_in: NONE
 * 
 * read_weights() - Read weights from the bus into weight memory
 *     @opcode: 010 (2)
 *     @dim_1: number of rows in weight matrix
 *     @dim_2: number of columns in weight matrix
 *     @dim_3: NONE
 *     @addr_1: base address to store in weight memory
 *     @accum_table_submat_row_in: NONE
 *     @accum_table_submat_col_in: NONE
 * 
 * fill_fifo() - Fill the FIFO with weights from the give memory location
 *     @opcode: 011 (3)
 *     @dim_1: number of rows in weight matrix
 *     @dim_2: number of columns in weight matrix
 *     @dim_3: NONE
 *     @addr_1: base address to read from weight memory
 *     @accum_table_submat_row_in: NONE
 *     @accum_table_submat_col_in: NONE
 * 
 * matrix_multiply() - Empty the FIFO into the systolic array, perform a matrix multiply, and store outputs in the accumulator table
 *     @opcode: 100 (4)
 *     @dim_1: intermediate dimension (number of columns in weight matrix and number of rows in input matrix)
 *     @dim_2: number of rows in weight matrix
 *     @dim_3: number of columns in input matrix
 *     @addr_1: base address of input matrix in the input memory
 *     @accum_table_submat_row_in: row index of the accumulator table where the output matrix will be stored
 *     @accum_table_submat_col_in: column index of the accumulator table where the output matrix will be stored
 * 
 * store_outputs()
 *     @opcode: 101 (5)
 *     @dim_1: number of rows to read from accumulator table index
 *     @dim_2: number of columns to read from accumulator table index
 *     @dim_3: LSB set to 1 to perform ReLU activation on the outputs or 0 to store them as-is
 *             2nd LSB set to 1 to clear the entire accumulator table after the read or 0 otherwise
 *     @addr_1: base address to write to output memory
 *     @accum_table_submat_row_in: row index of the accumulator table where the output matrix will be read from
 *     @accum_table_submat_col_in: column index of the accumulator table where the output matrix will be read from
 * 
 * write_outputs()
 *     @opcode: 110 (6)
 *     @dim_1: number of rows in output matrix
 *     @dim_2: number of columns in output matrix
 *     @dim_3: NONE
 *     @addr_1: base address to read from output memory
 *     @accum_table_submat_row_in: NONE
 *     @accum_table_submat_col_in: NONE
 * 
 * init_tpu() - Resets the TPU
 *     @opcode 111 (7)
 *     all else: NONE
 */

module master_control(clk,
                      reset,
                      reset_out,
                      start,
                      done,
                      opcode,
                      dim_1,
                      dim_2,
                      dim_3,
                      addr_1,
                      accum_table_submat_row_in,
                      accum_table_submat_col_in,
                      weight_fifo_arr_done,
                      data_mem_calc_done,
                      fifo_ready,
                      bus_to_mem_addr,
                      in_mem_wr_en,
                      weight_mem_out_rd_addr,
                      weight_mem_out_rd_en,
                      weight_mem_wr_en,
                      out_mem_out_wr_addr,
                      out_mem_out_wr_en,
                      out_mem_rd_en,
                      in_fifo_active,
                      out_fifo_active,
                      data_mem_calc_en,
                      input_mem_rd_base_addr,
                      wr_submat_row_out,
                      wr_submat_col_out,
                      wr_row_num,
                      rd_submat_row_out,
                      rd_submat_col_out,
                      rd_row_num,
                      accum_clear,
                      relu_en);

    parameter SYS_ARR_COLS = 16;
    parameter SYS_ARR_ROWS = 16;
    parameter MAX_OUT_ROWS = 128;
    parameter MAX_OUT_COLS = 128;
    parameter ADDR_WIDTH = 8;

    // instruction macros
    parameter READ_INPUTS = 3'b001;
    parameter READ_WEIGHTS = 3'b010;
    parameter FILL_FIFO = 3'b011;
    parameter MATRIX_MULTIPLY = 3'b100;
    parameter STORE_OUTPUTS = 3'b101;
    parameter WRITE_OUTPUTS = 3'b110;
    parameter INIT_TPU = 3'b111;

    input clk;
    input reset;
    output reg reset_out; // connect to all resets in TPU

    input start; // starts instruction execution on a pulse
    output reg done; // high when ready for new instruction (new start pulse)

    // instruction set inputs
    input [2:0] opcode;
    input [$clog2(SYS_ARR_ROWS)-1:0] dim_1;
    input [$clog2(SYS_ARR_COLS)-1:0] dim_2;
    input [$clog2(SYS_ARR_COLS)-1:0] dim_3;
    input [ADDR_WIDTH-1:0] addr_1;
    input [$clog2(MAX_OUT_ROWS/SYS_ARR_ROWS)-1:0] accum_table_submat_row_in;
    input [$clog2(MAX_OUT_COLS/SYS_ARR_COLS)-1:0] accum_table_submat_col_in;

    // special input connections for matrix_multiplication
    input weight_fifo_arr_done; // done signal from fifo output controller
    input data_mem_calc_done; //

    // output back to bus
    output wire fifo_ready; // used to tell the cpu when the fifo can be refilled
                            // not currently set up. will have to suffer fifo latency

    // output to be connected to...
    // output memory rd addr
    // input memory wr addr
    // weight memory wr addr
    output wire [ADDR_WIDTH-1:0] bus_to_mem_addr; // not sure about width yet

    // outputs to input memory ctrl
    output reg [SYS_ARR_COLS-1:0] in_mem_wr_en;

    // outputs to weight memory ctrl
    output wire [SYS_ARR_COLS*ADDR_WIDTH-1:0] weight_mem_out_rd_addr;
    output wire [SYS_ARR_COLS-1:0] weight_mem_out_rd_en;
    output reg [SYS_ARR_COLS-1:0] weight_mem_wr_en;
    // outputs to output memory ctrl
    output wire [ADDR_WIDTH-1:0] out_mem_out_wr_addr;
    output wire [SYS_ARR_COLS-1:0] out_mem_out_wr_en;
    output reg [SYS_ARR_COLS-1:0] out_mem_rd_en;

    // outputs to FIFO input ctrl
    output wire in_fifo_active;

    // outputs to FIFO output ctrl
    output wire out_fifo_active;

    // outputs to MMU ctrl
    output wire data_mem_calc_en;

    // outputs to accumulator table write control
    output wire [$clog2(MAX_OUT_ROWS/SYS_ARR_ROWS)-1:0] wr_submat_row_out;
    output wire [$clog2(MAX_OUT_COLS/SYS_ARR_COLS)-1:0] wr_submat_col_out;
    output wire [$clog2(SYS_ARR_ROWS)-1:0] wr_row_num; // not sure if mat mult ctrl has an out port for this yet

    // outputs to accumulator table read control
    output wire [$clog2(MAX_OUT_ROWS/SYS_ARR_ROWS)-1:0] rd_submat_row_out;
    output wire [$clog2(MAX_OUT_COLS/SYS_ARR_COLS)-1:0] rd_submat_col_out;
    output wire [$clog2(SYS_ARR_ROWS)-1:0] rd_row_num;

    // clear the accumulators
    output wire accum_clear;

    // output to ReLU
    output wire relu_en;

    output wire [7:0] input_mem_rd_base_addr;

    // possible signal paths for start
    reg start_mem_control;
    reg start_fill_fifo_control;
    reg start_multip_control;
    reg start_output_control;
    reg start_reset_control;

    // possible signal paths for done output
    wire done_mem_contol;
    wire done_fill_fifo_control;
    wire done_multip_control;
    wire done_output_control;
    reg done_reset_control; // not sure if this is needed

    wire [SYS_ARR_COLS-1:0] mem_control_en;

    master_mem_control master_mem_control (
        .clk      (clk),
        .reset    (reset | reset_out),
        .active   (start_mem_control), // i.e. start
        .base_addr(addr_1),
        .num_row  (dim_1),
        .num_col  (dim_2),
        .out_addr (bus_to_mem_addr),
        .out_en   (mem_control_en), // needs to be split up and separated for the 3 mem modules
        .done     (done_mem_contol)
    );

    master_fill_fifo_control master_fill_fifo_control (
        .clk              (clk),
        .reset            (reset | reset_out),
        .start            (start_fill_fifo_control),
        .done             (done_fill_fifo_control),
        .num_row          (dim_1),
        .num_col          (dim_2),
        .base_addr        (addr_1),
        .weightMem_rd_en  (weight_mem_out_rd_en),
        .weightMem_rd_addr(weight_mem_out_rd_addr),
        .fifo_active      (in_fifo_active) // also input to sysArr.wwrite in top.v (i'm pretty sure)
    );

    master_multip_control master_multip_control (
        .clk                       (clk),
        .reset                     (reset | reset_out),
        .active                    (start_multip_control), // i.e. start
        .intermed_dim              (dim_1),
        .num_row_weight_mat        (dim_2),
        .num_col_in_mat            (dim_3),
        .base_addr_in              (addr_1), // input data base addr // not sure what this is for -Cameron
        .accum_table_submat_row_in (accum_table_submat_row_in),
        .accum_table_submat_col_in (accum_table_submat_col_in),
        .accum_table_submat_row_out(wr_submat_row_out),
        .accum_table_submat_col_out(wr_submat_col_out),
        .weight_fifo_arr_en        (out_fifo_active),
        .weight_fifo_arr_done      (weight_fifo_arr_done),
        .data_mem_calc_en          (data_mem_calc_en),
        .data_mem_calc_done        (data_mem_calc_done),
        .fifo_ready                (fifo_ready),
        .base_addr_out             (input_mem_rd_base_addr),
        .done                      (done_multip_control)
    );

    master_output_control store_output_control (
        .clk           (clk),
        .reset         (reset | reset_out),
        .start         (start_output_control),
        .done          (done_output_control),
        .submat_row_in (accum_table_submat_row_in),
        .submat_col_in (accum_table_submat_col_in),
        .submat_row_out(rd_submat_row_out),
        .submat_col_out(rd_submat_col_out),
        .num_rows_read (dim_1),
        .num_cols_read (dim_2),
        .row_num       (rd_row_num),
        .clear_after   (dim_3[1]),
        .activate      (dim_3[0]),
        .accum_clear   (accum_clear), // also needs to be tied to reset signal
        .relu_en       (relu_en),
        .wr_base_addr  (addr_1),
        .wr_en         (out_mem_out_wr_en),
        .wr_addr       (out_mem_out_wr_addr)
    );

    always @(*) begin
        in_mem_wr_en = {SYS_ARR_COLS{1'b0}};
        weight_mem_wr_en = {SYS_ARR_COLS{1'b0}};
        out_mem_rd_en = {SYS_ARR_COLS{1'b0}};

        start_mem_control = 1'b0;
        start_fill_fifo_control = 1'b0;
        start_multip_control = 1'b0;
        start_output_control = 1'b0;
        start_reset_control = 1'b0;
        done = 1'b1;

        case (opcode)
            
            READ_INPUTS:
                begin
                    start_mem_control = start;
                    done = done_mem_contol;
                    in_mem_wr_en = mem_control_en;
                end // READ_INPUTS

            READ_WEIGHTS:
                begin
                    start_mem_control = start;
                    done = done_mem_contol;
                    weight_mem_wr_en = mem_control_en;
                end // READ_WEIGHTS

            FILL_FIFO:
                begin
                    start_fill_fifo_control = start;
                    done = done_fill_fifo_control;
                end // FILL_FIFO

            MATRIX_MULTIPLY:
                begin
                    start_multip_control = start;
                    done = done_multip_control;
                end // MATRIX_MULTIPLY

            STORE_OUTPUTS:
                begin
                    start_output_control = start;
                    done = done_output_control;
                end // STORE_OUTPUTS
           
            WRITE_OUTPUTS:
                begin
                    start_mem_control = start;
                    done = done_mem_contol;
                    out_mem_rd_en = mem_control_en;
                end // WRITE_OUTPUTS
           
            INIT_TPU:
                begin
                    start_reset_control = start;
                    done = done_reset_control;
                end // INIT_TPU
            
        endcase // opcode
    end // always @(*)

    always @(posedge clk) begin
        if (start_reset_control) begin
            reset_out = 1'b1;
            done_reset_control = 1'b0;
        end // if (start_reset_control)

        else begin
            reset_out = 1'b0;
            done_reset_control = 1'b1;
        end // else
    end // always @(posedge clk)

endmodule // master_control