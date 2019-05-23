`timescale 1 ps / 1 ps

module tb_top();
    parameter WIDTH_HEIGHT = 16;

    // inputs to DUT
    reg clk;
    reg reset;
    reg active;
    reg [WIDTH_HEIGHT - 1:0] inputMem_wr_en;
    reg [(WIDTH_HEIGHT * 8) - 1:0] inputMem_wr_addr;
    reg [(WIDTH_HEIGHT * 8) - 1:0] inputMem_wr_data;
    reg [(WIDTH_HEIGHT * 8) - 1:0] inputMem_rd_addr_base;
    reg [WIDTH_HEIGHT - 1:0] outputMem_rd_en;
    reg [(WIDTH_HEIGHT * 8) - 1:0] outputMem_rd_addr;
    reg [(WIDTH_HEIGHT * 8) - 1:0] outputMem_wr_addr_base;
    reg [WIDTH_HEIGHT - 1:0] weightMem_wr_en;
    reg [(WIDTH_HEIGHT * 8) - 1:0] weightMem_wr_addr;
    reg [(WIDTH_HEIGHT * 8) - 1:0] weightMem_wr_data;
    reg [(WIDTH_HEIGHT * 8) - 1:0] weightMem_rd_addr_base;
    reg load_weights_to_array;
    reg drain_fifo;
    reg fill_fifo;

    // outputs from DUT
    wire mem_to_fifo_done;
    wire fifo_to_arr_done;
    wire output_done;
    wire [(WIDTH_HEIGHT * 16) - 1:0] outputMem_rd_data;

    // instantiation of DUT
    top DUT (
        .clk                   (clk),
        .reset                 (reset),
        .active                (active),
        .inputMem_wr_en        (inputMem_wr_en),
        .inputMem_wr_addr      (inputMem_wr_addr),
        .inputMem_wr_data      (inputMem_wr_data),
        .inputMem_rd_addr_base (inputMem_rd_addr_base),
        .outputMem_rd_en       (outputMem_rd_en),
        .outputMem_rd_addr     (outputMem_rd_addr),
        .outputMem_wr_addr_base(outputMem_wr_addr_base),
        .weightMem_wr_en       (weightMem_wr_en),
        .weightMem_wr_addr     (weightMem_wr_addr),
        .weightMem_wr_data     (weightMem_wr_data),
        .weightMem_rd_addr_base(weightMem_rd_addr_base),
        .fill_fifo             (fill_fifo),
        .drain_fifo            (drain_fifo),
        .mem_to_fifo_done      (mem_to_fifo_done),
        .fifo_to_arr_done      (fifo_to_arr_done),
        .output_done           (output_done),
        .outputMem_rd_data     (outputMem_rd_data)
    );

    // start clock
    always begin
        #5;
        clk = ~clk;
    end // always

    integer i;

    // test suite
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        active = 1'b0;
        inputMem_wr_en = 16'h0000;
        inputMem_wr_addr = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        inputMem_wr_data = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        inputMem_rd_addr_base = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        outputMem_rd_en = 16'h0000;
        outputMem_rd_addr = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        outputMem_wr_addr_base = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        weightMem_wr_en = 16'h0000;
        weightMem_wr_addr = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        weightMem_wr_data = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        weightMem_rd_addr_base = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        load_weights_to_array = 1'b0;

        #20;

        reset = 1'b0;

        #20;

        // Write to the weight and input Memory
        // This will be handled in software with a for loop.
        // Bus module will decode wr_addresses to set enables
        weightMem_wr_en = 16'hFFFF;
        inputMem_wr_en = 16'hFFFF;
        weightMem_wr_data = 128'h0101_0101_0101_0101_0101_0101_0101_0101;
        inputMem_wr_data = 128'h0101_0101_0101_0101_0101_0101_0101_0101;
        weightMem_wr_addr = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        inputMem_wr_addr = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        for (i = 0; i < 16; i = i + 1) begin
            #10;
            weightMem_wr_data = weightMem_wr_data + 128'h0101_0101_0101_0101_0101_0101_0101_0101;
            inputMem_wr_data = inputMem_wr_data + 128'h0101_0101_0101_0101_0101_0101_0101_0101;
            weightMem_wr_addr = weightMem_wr_addr + 128'h0101_0101_0101_0101_0101_0101_0101_0101;
            inputMem_wr_addr = inputMem_wr_addr + 128'h0101_0101_0101_0101_0101_0101_0101_0101;
        end // for
        weightMem_wr_en = 16'h0000;
        inputMem_wr_en = 16'h0000;

        #10;

        // Load weights into FIFO's
        weightMem_rd_addr_base = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        fill_fifo = 1'b1;

        #10;

        fill_fifo = 1'b0;

        #160;

        drain_fifo = 1'b1;

        #160;

        drain_fifo = 1'b0;

        // At this point, weights are loaded. Begin multiplication.

        active = 1'b1;

        #10;

        active = 1'b0;

        #600;

        // Do an entire input and weight loading + multiply again
        weightMem_wr_en = 16'hFFFF;
        inputMem_wr_en = 16'hFFFF;
        weightMem_wr_data = 128'h1010_1010_1010_1010_1010_1010_1010_1010;
        inputMem_wr_data = 128'h1010_1010_1010_1010_1010_1010_1010_1010;
        weightMem_wr_addr = 128'h2020_2020_2020_2020_2020_2020_2020_2020;
        inputMem_wr_addr = 128'h2020_2020_2020_2020_2020_2020_2020_2020;
        for (i = 0; i < 16; i = i + 1) begin
            #10;
            weightMem_wr_data = weightMem_wr_data + 128'h0101_0101_0101_0101_0101_0101_0101_0101;
            inputMem_wr_data = inputMem_wr_data + 128'h0101_0101_0101_0101_0101_0101_0101_0101;
            weightMem_wr_addr = weightMem_wr_addr + 128'h0101_0101_0101_0101_0101_0101_0101_0101;
            inputMem_wr_addr = inputMem_wr_addr + 128'h0101_0101_0101_0101_0101_0101_0101_0101;
        end // for
        weightMem_wr_en = 16'h0000;
        inputMem_wr_en = 16'h0000;

        #10;

        // Load weights into FIFOs
        weightMem_rd_addr_base = 128'h2020_2020_2020_2020_2020_2020_2020_2020;
        fill_fifo = 1'b1;

        #10;

        fill_fifo = 1'b0;

        #160;

        drain_fifo = 1'b1;

        #160;

        drain_fifo = 1'b0;
        inputMem_rd_addr_base = 128'h2020_2020_2020_2020_2020_2020_2020_2020;
        outputMem_wr_addr_base = 128'h2020_2020_2020_2020_2020_2020_2020_2020;

        active = 1'b1;

        #10;

        active = 1'b0;

        #600;

        $stop;
    end // initial
endmodule // tb_top