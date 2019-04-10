module memArr(
   clk,
   rd_en,
   wr_en,
   wr_data,
   rd_data,
   wr_addr,
   rd_addr
);

    parameter width_height = 4;
    localparam en_bits = $clog2(width_height);

    input clk;
    input rd_en[en_bits - 1: 0];
    input wr_en[en_bits - 1: 0];
    input wr_data[width_height * 8];
    input rd_addr[width_height * 8];
    input wr_addr[width_height * 8];
    output wire rd_data[width_height * 8];

    genvar i;
    generate
        for (i = 0; i < width_height; i++) begin
            mem input_mem(
                .clock(clk),
                .data(wr_data[((i*8) + 8)-1:(i*8)])
                .rdaddress(rd_addr[((i*8) + 8)-1:(i*8)]),
                .wraddress(wr_addr[((i*8) + 8)-1:(i*8)]),
                .wren(wr_en[i]),
                .rden(rd_en[i]),
                .q(rd_data[((i*8) + 8)-1:(i*8)])
            );
        end // for (i = 0; i < width_height; i++)
    endgenerate
endmodule // memArr