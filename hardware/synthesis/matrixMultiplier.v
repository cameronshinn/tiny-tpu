// Macros for talking with different address spaces
`define CONTROL_OFFSET 2'b00
`define INPUT_OFFSET 2'b01
`define WEIGHT_OFFSET 2'b01
`define OUTPUT_OFFSET 2'b11


// Macros for control signals. Write these to get the mapped function
`define RESET 4'b1111;
`define FILL_FIFO 4'b0001;
`define FILL_ARR 4'b0010;
`define MULTIPLY 4'b0011;

module matrixMultiplier (
	clk,
	reset,
	slave_address,
	slave_read,
	slave_write,
	slave_readdata,
	slave_writedata,
	slave_byteenable
);


    // BE SURE TO USE FULL AVALON (not lightweight) BUS IN QSYS
    parameter DATA_WIDTH = 64;
    parameter WIDTH_HEIGHT = 16;
    parameter TPU_DATA_WIDTH = WIDTH_HEIGHT * 8;

    input clk;
    input reset;
    input [9:0] slave_address;
    input slave_read;
    input slave_write;
    input [DATA_WIDTH-1:0] slave_writedata;
    input [(DATA_WIDTH/8)-1:0] slave_byteenable;

    output reg [DATA_WIDTH-1:0] slave_readdata;


    /* TODO:
     *
     *      - inputMem_wr_en & weightMem_wr_en                  />
     *      - outputMem_rd_en                                   />
     *      - inputMem_wr_addr & weightMem_wr_addr              />
     *      - outputMem_rd_addr                                 />
     *      - inputMem_wr_data & weightMem_wr_data              />
     *      - outputMem_rd_data                                 />
     *      - Control Signals (Write)
     *          + reset
     *          + active
     *              - inputMem_rd_addr_base
     *              - outputMem_wr_addr_base
     *          + fill_fifo
     *              - weightMem_rd_addr_base
     *          + fifo_to_arr
     *      - Control Signals (Read)
     *          + mem_to_fifo_done
     *          + fifo_to_arr_done
     *          + output_done
     *      - slave_readdata
     */


    // ========================================
    // --------- wr/rd enables ----------------
    // ========================================


    wire [WIDTH_HEIGHT - 1:0] inputMem_wr_en;
    wire [WIDTH_HEIGHT - 1:0] weightMem_wr_en;
    wire [WIDTH_HEIGHT - 1:0] outputMem_rd_en;

    assign inputMem_wr_en = {16{slave_write & (slave_address[9:8] == INPUT_OFFSET)}};
    assign weightMem_wr_en = {16{slave_write & (slave_address[9:8] == WEIGHT_OFFSET)}};
    assign outputMem_rd_en = {16{slave_read & (slave_address[9:8] == OUTPUT_OFFSET)}};


    // ========================================
    // ------------ wr/rd addresses -----------
    // ========================================


    wire [TPU_DATA_WIDTH - 1:0] inputMem_wr_addr;
    wire [TPU_DATA_WIDTH - 1:0] weightMem_wr_addr;
    wire [TPU_DATA_WIDTH - 1:0] outputMem_rd_addr;

    assign inputMem_wr_addr = {16{slave_address[7:0]}};
    assign weightMem_wr_addr = {16{slave_address[7:0]}};
    assign outputMem_rd_addr = {16{slave_address[7:0]}};


    // ========================================
    // ------------ wr/rd data ----------------
    // ========================================


    wire [TPU_DATA_WIDTH - 1:0] inputMem_wr_data;
    wire [TPU_DATA_WIDTH - 1:0] weightMem_wr_data;
    wire [TPU_DATA_WIDTH - 1:0] outputMem_rd_data; // Driven by TPU output

    assign inputMem_wr_data = {16{slave_writedata}};
    assign weightMem_wr_data = {16{slave_writedata}};


    // ========================================
    // ------------ TPU Instantiation ---------
    // ========================================


    top TPU (
        .clk                   (clk),
        .reset                 (),
        .active                (),
        .inputMem_wr_en        (inputMem_wr_en),
        .inputMem_wr_addr      (inputMem_wr_addr),
        .inputMem_wr_data      (inputMem_wr_data),
        .inputMem_rd_addr_base (),
        .outputMem_rd_en       (outputMem_rd_en),
        .outputMem_rd_addr     (outputMem_rd_addr),
        .outputMem_rd_data     (outputMem_rd_data),
        .outputMem_wr_addr_base(),
        .weightMem_wr_en       (weightMem_wr_en),
        .weightMem_wr_addr     (weightMem_wr_addr),
        .weightMem_wr_data     (weightMem_wr_data),
        .weightMem_rd_addr_base(),
        .fill_fifo             (),
        .drain_fifo            (),
        .mem_to_fifo_done      (),
        .fifo_to_arr_done      (),
        .output_done           ()
    );


endmodule
