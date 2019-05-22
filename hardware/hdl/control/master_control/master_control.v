// master_control.v
// Cameron Shinn

/*
The master controller takes instructions from the bus as its input and drives
the corresponding control signals to the individual controllers of each
submodule

Instruction set:
*signals marked with NONE are ignored*

init_tpu() - Resets the TPU
    @opcode 000 (0)
    all else: NONE

read_inputs() - Read inputs from the bus into input memory
    @opcode: 001 (1)
    @dim_1: number of rows in matrix
    @dim_2: number of columns in matrix
    @dim_3: NONE
    @addr_1: base address to store in input memory
    @addr_2: NONE
    @accum_table_submat_row: NONE
    @accum_table_submat_col: NONE

read_weights() - Read weights from the bus into weight memory
    @opcode: 010 (2)
    @dim_1: number of rows in weight matrix
    @dim_2: number of columns in weight matrix
    @dim_3: NONE
    @addr_1: base address to store in weight memory
    @addr_2: NONE
    @accum_table_submat_row: NONE
    @accum_table_submat_col: NONE

fill_fifo() - Fill the FIFO with weights from the give memory location
    @opcode: 011 (3)

matrix_multiply() - Empty the FIFO into the systolic array, perform a matrix multiply, and store outputs in the accumulator table
    @opcode: 100 (4)
    @dim_1: intermediate dimension (number of columns in weight matrix and number of rows in input matrix)
    @dim_2: number of rows in weight matrix
    @dim_3: number of columns in input matrix
    @addr_1: base address of weight matrix in the weight memory
    @addr_2: base address of input matrix in the input memory
    @accum_table_submat_row: row index of the accumulator table where the output matrix will be stored
    @accum_table_submat_col: column index of the accumulator table where the output matrix will be stored

store_outputs()
    @opcode: 101 (5)
    @dim_1: number of rows to read from accumulator table index
    @dim_2: number of columns to read from accumulator table index
    @dim_3: LSB set to 1 to perform ReLU activation on the outputs or 0 to store them as-is
    @addr_1: base address to write to output memory
    @addr_2: LSB set to 1 to clear the entire accumulator table after the read or 0 otherwise
    @accum_table_submat_row: row index of the accumulator table where the output matrix will be read from
    @accum_table_submat_col: column index of the accumulator table where the output matrix will be read from

write_outputs()
    @opcode: 110 (6)
    @dim_1: number of rows in output matrix
    @dim_2: number of columns in output matrix
    @dim_3: NONE
    @addr_1: base address to read from output memory
    @addr_2: NONE
    @accum_table_submat_row: NONE
    @accum_table_submat_col: NONE
*/

module master_control(clk,
                      reset,
                      start,
                      opcode,
                      intermed_dim,
                      weight_num_rows,
                      input_num_cols,
                      addr_1,
                      addr_2,
                      accum_table_submat_row,
                      accum_table_submat_col);
    
    parameter SYS_ARR_WIDTH = 16;
    parameter SYS_ARR_HEIGHT = 16;
    parameter MAX_OUT_ROWS = 128;
    parameter MAX_OUT_COLS = 128;
    parameter ADDR_WIDTH = 8;

    input clk;
    input reset;

    input start; // starts instruction execution on a positive edge trigger
    
    input [2:0] opcode;
    input [$clog2(SYS_ARR_HEIGHT)-1:0] intermed_dim; // dim_1
    input [$clog2(SYS_ARR_WIDTH)-1:0] weight_num_rows; // dim_2
    input [$clog2(SYS_ARR_WIDTH)-1:0] input_num_cols; // dim_3
    input [ADDR_WIDTH-1:0] addr_1;
    input [ADDR_WIDTH-1:0] addr_2;
    input [$clog2(MAX_OUT_ROWS/SYS_ARR_HEIGHT)-1:0] accum_table_submat_row;
    input [$clog2(MAX_OUT_COLS/SYS_ARR_WIDTH)-1:0] accum_table_submat_col;

    store_output_control store_output_control (
        .clk(),
        .reset(),
        .start(),
        .done(),
        .submat_row_in(),
        .submat_col_in(),
        .submat_row_out(),
        .submat_col_out(),
        .num_cols_read(),
        .num_rows_read(),
        .row_num(),
        .accum_reset(),
        .activate(),
        .relu_en(),
        .clear_after(),
        .wr_base_addr(),
        .wr_en(),
        .wr_addr()      
    );

endmodule