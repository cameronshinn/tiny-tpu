module wr_mem_control(
    clk,
    wr_en,
    wr_addr,
    wr_data,
    rd_en,
    rd_addr,
    rd_data
);

parameter width_height = 16;
parameter data_width = 8*width_height;

input clk;
input [width_height-1:0] wr_en, rd_en;
input [data_width-1:0] wr_addr, wr_data;
input [data_width-1:0] rd_addr;
output [data_width-1:0] rd_data;

genvar i;
generate
    for(i = 0; i < width_height; i=i+1) begin : gen_wr_mem_control
        memArr DATA_MEM (
            .clk(clk),
            .rd_en(rd_en[i]),
            .wr_en(wr_en[i]),
            .wr_data(wr_en[i*8 : ((i+1)*8 - 1)]),
            .rd_data(rd_en[i*8 : ((i+1)*8 - 1)]),
            .wr_addr(wr_addr[i*8 : ((i+1)*8 - 1)]),
            .rd_addr(rd_en[i*8 : ((i+1)*8 - 1)])
            );
    end
endgenerate
endmodule
