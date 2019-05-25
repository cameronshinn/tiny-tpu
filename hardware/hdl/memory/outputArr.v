module outputArr(
   clk,
   rd_en,
   wr_en,
   wr_data,
   rd_data,
   wr_addr,
   rd_addr
);

    parameter width_height = 4;
    localparam en_bits = width_height;

    input clk;
    input [en_bits - 1: 0] rd_en;
    input [en_bits - 1: 0] wr_en;
    input [(width_height * 16)-1:0] wr_data;
    input [(width_height * 8)-1:0] rd_addr;
    input [(width_height * 8)-1:0] wr_addr;
    output wire [(width_height * 16)-1:0] rd_data;

    genvar i;
    generate 
        for (i = 0; i < width_height; i = i + 1) begin : gen_outputArr
            output_mem output_mem(
                .clock(clk),
                .data(wr_data[((i*16) + 16)-1:(i*16)]),
                .rdaddress(rd_addr[((i*8) + 8)-1:(i*8)]),
                .wraddress(wr_addr[((i*8) + 8)-1:(i*8)]),
                .wren(wr_en[i]),
                .rden(rd_en[i]),
                .q(rd_data[((i*16) + 16)-1:(i*16)])
            );
        end // for (i = 0; i < width_height; i++)
    endgenerate
endmodule // memArr
