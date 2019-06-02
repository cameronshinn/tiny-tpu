module master_mem_control(
    clk,
    reset,
    active,
    base_addr,
    num_row,
    num_col,
    out_addr,
    out_en,
    done
);

parameter addr_width = 8;
parameter width_height = 16;
localparam out_addr_width = addr_width * width_height;

input clk, reset, active;
input [addr_width-1:0] base_addr;
input [$clog2(width_height)-1:0] num_row, num_col;

output reg done;
output reg [width_height-1:0] out_en;
output reg [out_addr_width-1:0] out_addr;

reg start, start_c, done_c;
reg [$clog2(width_height)-1:0] count, count_c;
reg [out_addr_width-1:0] out_addr_c;

always@(posedge clk) begin
    count <= count_c;
    start <= start_c;
    done <= done_c;
    out_addr <= out_addr_c;
end

always@(*) begin
    out_en = {width_height{1'b0}};

    if(active) begin
        start_c = 1;
        done_c = 0;
    end

    if(start) begin
        out_en = {width_height{1'b1}} >> (width_height - num_col - 1);
        out_addr_c = {width_height{base_addr+count}};
        count_c = count + 1;

        if(count >= num_row) begin
            count_c = 0;
            out_addr_c = 0;
            out_en = 0;
            done_c = 1;
            start_c = 0;
        end
    end

    if(reset) begin
        start_c = 0;
        done_c = 0;
        count_c = 0;
        out_addr_c = 0;
    end
end

endmodule
