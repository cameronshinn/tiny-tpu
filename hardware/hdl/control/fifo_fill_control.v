module fifo_fill_control (
    clk,
    reset,
    active,
    mem_to_fifo,
    weightMem_rd_addr,
    weightMem_rd_en
);

    parameter WIDTH_HEIGHT = 16;

    input clk;
    input reset;
    input active;
    output mem_to_fifo;
    output reg [(WIDTH_HEIGHT*8)-1:0] weightMem_rd_addr;
    output reg [WIDTH_HEIGHT-1:0] weightMem_rd_en;
    reg mem_to_fifo;
    reg mem_to_fifo_c;
    reg [4:0] count;
    reg [4:0] count_c;


    always @(*) begin
        mem_to_fifo_c = 1'b0;
        count_c = 5'h00;
        weightMem_rd_addr = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        weightMem_rd_en = 16'h0000;
        if (reset) begin
            count_c = 5'h00;
            weightMem_rd_addr = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
            weightMem_rd_en = 16'h0000;
            mem_to_fifo_c = 1'b0;
        end // if (reset)

        if (active) begin
            count_c = count + 1'b1;
            weightMem_rd_en = 16'hFFFF;
            mem_to_fifo_c = 1'b1;
        end // if (active)

        if (count > 5'h00) begin
            count_c = count + 1'b1;
            weightMem_rd_en = 16'hFFFF;
            weightMem_rd_addr = {16{4'h0, count[3:0]}};
            mem_to_fifo_c = 1'b0;
        end

        if (count == 5'h10) begin
            count_c = 1'b0;
            weightMem_rd_en = 16'h0000;
            weightMem_rd_addr = 128;
            mem_to_fifo_c = 1'b0;
        end
    end

    always @(posedge clk) begin
        count <= count_c;
        mem_to_fifo <= mem_to_fifo_c;
    end // always @(posedge clk)

endmodule // mult_control


