// tb_master_output_control.v
// Cameron Shinn

module tb_master_output_control;

    parameter MAX_OUT_ROWS = 128; // output number of rows in 
    parameter MAX_OUT_COLS = 128;
    parameter SYS_ARR_ROWS = 16;
    parameter SYS_ARR_COLS = 16;
    parameter ADDR_WIDTH = 8;
    
    localparam NUM_ACCUM_ROWS = MAX_OUT_ROWS*(MAX_OUT_COLS/SYS_ARR_COLS);
    localparam NUM_SUBMATS_M = MAX_OUT_ROWS/SYS_ARR_ROWS; // not sure if this will do ceiling like I want
    localparam NUM_SUBMATS_N = MAX_OUT_COLS/SYS_ARR_COLS; // not sure if this will do ceiling like I want

    reg clk; 
    reg reset;
    reg start; 
    wire done; 
    wire [$clog2(NUM_SUBMATS_M)-1:0] submat_row_in; 
    wire [$clog2(NUM_SUBMATS_N)-1:0] submat_col_in; 
    wire [$clog2(NUM_SUBMATS_M)-1:0] submat_row_out; 
    wire [$clog2(NUM_SUBMATS_N)-1:0] submat_col_out; 
    wire [$clog2(SYS_ARR_COLS)-1:0] num_cols_read; 
    wire [$clog2(SYS_ARR_ROWS)-1:0] num_rows_read; 
    wire [$clog2(SYS_ARR_ROWS)-1:0] row_num; 
    wire activate; 
    wire relu_en; 
    wire clear_after; 
    wire accum_reset; 
    wire [ADDR_WIDTH-1:0] wr_base_addr;
    wire [SYS_ARR_COLS-1:0] wr_en; 
    wire [SYS_ARR_COLS*ADDR_WIDTH-1:0] wr_addr;

    master_output_control master_output_control (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .submat_row_in(submat_row_in),
        .submat_col_in(submat_col_in),
        .submat_row_out(submat_row_out),
        .submat_col_out(submat_col_out),
        .num_cols_read(num_cols_read),
        .num_rows_read(num_rows_read),
        .row_num(row_num),
        .accum_reset(accum_reset),
        .activate(activate),
        .relu_en(relu_en),
        .clear_after(clear_after),
        .wr_base_addr(wr_base_addr),
        .wr_en(wr_en),
        .wr_addr(wr_addr)      
    );

    assign submat_row_in = 2;
    assign submat_col_in = 3;
    assign num_rows_read = 15;
    assign num_cols_read = 9;
    assign activate = 1;
    assign wr_base_addr = 2;
    assign clear_after = 1;

    initial begin
        clk = 1'b0;
    end // initial

    always begin
        #10
        clk = ~clk;
    end // always

    integer count = 0;

    always @(posedge clk) begin
        if (count == 20) begin
            $stop;
        end // if (count == 20)

        if (count == 1) begin
            reset = 1'b1;
        end // if (count == 2)

        else begin
            reset = 1'b0;
        end // else

        if (count == 2) begin
            start = 1'b1;
        end // if (count == 2)

        else begin
            start = 1'b0;
        end // else

        count = count + 1;
    end

endmodule // tb_store_output_control
