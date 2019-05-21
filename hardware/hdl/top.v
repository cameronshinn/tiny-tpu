module top (
    clk,
    reset,
    active,
    inputMem_wr_en,
    inputMem_wr_addr,
    inputMem_wr_data,
    inputMem_rd_addr_base,
    outputMem_rd_en,
    outputMem_rd_addr,
    outputMem_wr_addr_base,
    outputMem_rd_data,
    weightMem_wr_en,
    weightMem_wr_addr,
    weightMem_wr_data,
    weightMem_rd_en,
    weightMem_rd_addr,
    mem_to_fifo,
    fifo_to_arr,
    mem_to_fifo_done,
    fifo_to_arr_done,
    output_done,
    weight_write
 );


// ========================================
// ---------- Parameters ------------------
// ========================================

    parameter WIDTH_HEIGHT = 16;


// ========================================
// ------------ Inputs --------------------
// ========================================
    input clk;
    input reset;

    // start signal for matrix multiply
    input active;

    // input memory signals
    input [WIDTH_HEIGHT - 1:0] inputMem_wr_en;
    input [(WIDTH_HEIGHT * 8) - 1:0] inputMem_wr_addr;
    input [(WIDTH_HEIGHT * 8) - 1:0] inputMem_wr_data;

    // base read address (input) for matrix multiply
    input [(WIDTH_HEIGHT * 8) - 1:0] inputMem_rd_addr_base;

    // output memory signals
    input [WIDTH_HEIGHT - 1:0] outputMem_rd_en;
    input [(WIDTH_HEIGHT * 8) - 1:0] outputMem_rd_addr;

    // base write address (output) for matrix multiply
    input [(WIDTH_HEIGHT * 8) - 1:0] outputMem_wr_addr_base;

    // weight memory signals
    input [WIDTH_HEIGHT - 1:0] weightMem_wr_en;
    input [(WIDTH_HEIGHT * 8) - 1:0] weightMem_wr_addr;
    input [(WIDTH_HEIGHT * 8) - 1:0] weightMem_wr_data;
    input [WIDTH_HEIGHT - 1:0] weightMem_rd_en;
    input [(WIDTH_HEIGHT * 8) - 1:0] weightMem_rd_addr;

    // FIFO stuff
    input mem_to_fifo;
    input fifo_to_arr;

    // commit FIFO outputs to systolic array
    input [WIDTH_HEIGHT - 1:0] weight_write;


// ========================================
// ------------ Outputs -------------------
// ========================================
    // tell host cpu when loading weights is done
    output mem_to_fifo_done;
    // tell host CPU when multiply is done
    output fifo_to_arr_done;
    output output_done;

    // output memory read port
    output [(WIDTH_HEIGHT * 16) - 1:0] outputMem_rd_data;


// ========================================
// ------- Local Wires and Regs -----------
// ========================================
    wire [(WIDTH_HEIGHT * 8) - 1:0] inputMem_to_sysArr;
    wire [WIDTH_HEIGHT - 1:0] inputMem_rd_en;
    wire [(WIDTH_HEIGHT * 8) - 1:0] inputMem_rd_addr_offset;
    wire [(WIDTH_HEIGHT * 8) - 1:0] weightMem_rd_data;
    wire [(WIDTH_HEIGHT * 8) - 1:0] weightFIFO_to_sysArr;
    wire [WIDTH_HEIGHT - 1:0] outputMem_wr_en;
    //wire [(WIDTH_HEIGHT * 16) - 1:0] sysArr_to_outputMem;
    wire [(WIDTH_HEIGHT * 8) - 1:0] outputMem_wr_addr_offset;
    wire [(WIDTH_HEIGHT * 16) - 1:0] outputMem_wr_data;
    wire [WIDTH_HEIGHT - 1:0] mem_to_fifo_en;
    wire [WIDTH_HEIGHT - 1:0] fifo_to_arr_en;
    wire rd_to_wr_start;

    // set sys_arr_active 2 cycles after we start reading memory
    wire sys_arr_active;
    reg sys_arr_active1;
    reg sys_arr_active2;
    reg sys_arr_active3;

// ========================================
// -------------- Logic -------------------
// ========================================

    // sys_arr_active 2 cycles after we start reading memory
    assign sys_arr_active = inputMem_rd_en[0];

// ========================================
// ------- Module Instantiations ----------
// ========================================

    sysArr sysArr(
        .clk      (clk),
        .active   (sys_arr_active2),                     // from control or software
        .datain   (inputMem_to_sysArr),         // from input memory
        .win      (weightFIFO_to_sysArr),        // from weight FIFO's
        .sumin    (256'd0),                           // Can be used for biases
        .wwrite   (weight_write),               // from control
        .maccout  (outputMem_wr_data),          // to output memory
        .wout     (),                           // Not used
        .wwriteout(),                           // Not used
        .activeout(),                           // Not used
        .dataout  ()                            // Not used
    );
    defparam sysArr.width_height = WIDTH_HEIGHT;


    // =========================================
    // --------- Input Side of Array -----------
    // =========================================
    memArr inputMem(
        .clk    (clk),
        .rd_en  (inputMem_rd_en),               // from control
        .wr_en  (inputMem_wr_en),               // from interconnect (INPUT)
        .wr_data(inputMem_wr_data),             // from interconnect (INPUT)
        .rd_addr(inputMem_rd_addr_base + inputMem_rd_addr_offset),  // from control & interconnect
        .wr_addr(inputMem_wr_addr),             // from interconnect (INPUT)
        .rd_data(inputMem_to_sysArr)            // to sysArr
    );
    defparam inputMem.width_height = WIDTH_HEIGHT;

    rd_control inputMemControl (
        .clk    (clk),
        .reset  (reset),
        .active (active),                       // tied to sysArr Active
        .rd_en  (inputMem_rd_en),               // to input memory
        .rd_addr(inputMem_rd_addr_offset),      // to input memory
        .wr_active(rd_to_wr_start)              // to wr_control
    );
    defparam inputMemControl.width_height = WIDTH_HEIGHT;


    // ========================================
    // --------- Weight side of Array ---------
    // ========================================
    memArr weightMem(
        .clk    (clk),
        .rd_en  (weightMem_rd_en),              // from interconnect
        .wr_en  (weightMem_wr_en),              // from interconnect
        .wr_data(weightMem_wr_data),            // from interconnect
        .rd_addr(weightMem_rd_addr),            // from interconnect
        .wr_addr(weightMem_wr_addr),            // from interconnect
        .rd_data(weightMem_rd_data)             // to weightFIFO
    );
    defparam weightMem.width_height = WIDTH_HEIGHT;

    fifo_control mem_fifo (
        .clk         (clk),
        .reset       (reset),
        .active      (mem_to_fifo),             // from interconnect
        .stagger_load(1'b0),
        .fifo_en     (mem_to_fifo_en),          // to weightFIFO's
        .done        (mem_to_fifo_done)         // to interconect
    );
    defparam mem_fifo.fifo_width = WIDTH_HEIGHT;

    fifo_control fifo_arr (
        .clk         (clk),
        .reset       (reset),
        .active      (fifo_to_arr),             // from interconnect
        .stagger_load(1'b0),
        .fifo_en     (fifo_to_arr_en),          // to weightFIFO's
        .done        (fifo_to_arr_done)         // to interconnect
    );
    defparam fifo_arr.fifo_width = WIDTH_HEIGHT;


    weightFifo weightFIFO (
        .clk      (clk),
        .reset    (reset),
        .en       (mem_to_fifo_en | fifo_to_arr_en), // from fifoControl
        .weightIn (weightMem_rd_data),          // from weightMem
        .weightOut(weightFIFO_to_sysArr)        // to sysArr
    );
    defparam weightFIFO.DATA_WIDTH = 8;
    defparam weightFIFO.FIFO_INPUTS = WIDTH_HEIGHT;
    defparam weightFIFO.FIFO_DEPTH = WIDTH_HEIGHT;


    // =========================================
    // --------- Output side of array ----------
    // =========================================
    outputArr outputMem (
        .clk    (clk),
        .rd_en  (outputMem_rd_en),              // from interconnect
        .wr_en  (outputMem_wr_en),              // from outputMemControl
        .wr_data(outputMem_wr_data),          // from sysArr
        .rd_addr(outputMem_rd_addr),            // from interconnect
        .wr_addr(outputMem_wr_addr_base + outputMem_wr_addr_offset), // outputMemControl + base from interconnect
        .rd_data(outputMem_rd_data)             // to interconect
    );
    defparam outputMem.width_height = WIDTH_HEIGHT;

    wr_control outputMemControl (
        .clk    (clk),
        .reset  (reset),
        .active (rd_to_wr_start),               // ???? don't know source yet (sysArr?)
        .wr_en  (outputMem_wr_en),              // to outputMem
        .wr_addr(outputMem_wr_addr_offset),      // to outputMem
        .done   (output_done)
    );
    defparam outputMemControl.width_height = WIDTH_HEIGHT;


// ======================================
// ----------- Flip flops ---------------
// ======================================
    always @(posedge clk) begin

        // set sys_arr_active 2 cycles after we read memory
        sys_arr_active1 <= sys_arr_active;
        sys_arr_active2 <= sys_arr_active1;
        sys_arr_active3 <= sys_arr_active2;
    end // always

endmodule // top