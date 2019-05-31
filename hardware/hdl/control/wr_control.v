// This module controls the signal to write data into memory
// It will send enble and memory address signal to memArr module
// Alan Qin
// April 22 2019

module wr_control(
    clk, // clock signal
    reset, // reset the inputs and reg signals
    active, // this module only works when the active is high
    sys_arr_active, // to reset done
    wr_en, // enable accessing to the memeory
    wr_addr, // write address (offset), the full address should be base addr + wr_addr
    done
    );

    parameter width_height = 16;
    localparam data_width = 8 * width_height; // number of data bits needed

    input clk, reset, active, sys_arr_active;
    output reg [width_height-1:0] wr_en;
    output reg [data_width-1:0] wr_addr;
    output reg done;

    reg [width_height-1:0] wr_en_c;
    reg [data_width-1:0] wr_addr_c;
    reg wr_dec, wr_dec_c;
    reg wr_start, wr_start_c;
    reg done_c;

    always @(posedge clk) begin
        wr_en <= wr_en_c;
        wr_addr <= wr_addr_c;
        done <= done_c;
        wr_start <= wr_start_c;
        wr_dec <= wr_dec_c;
    end

    always @(*) begin
        wr_addr_c = wr_addr;
        done_c = done;
        wr_dec_c = wr_dec;
        wr_start_c = wr_start;

        if (active) begin
            wr_start_c = 1;
            done_c = 1'b0;
            //done = 0;
        end

        if(wr_start) begin // start to get read address
            if(wr_en == 16'hffff) begin
                wr_dec_c = 1'b1;
            end

            if(wr_dec) begin
                wr_en_c = wr_en << 1;
            end

            else begin
                wr_en_c = (wr_en << 1) + 1'b1;
            end

            wr_addr_c = {7'b0, wr_en[15],
                         7'b0, wr_en[14],
                         7'b0, wr_en[13],
                         7'b0, wr_en[12],
                         7'b0, wr_en[11],
                         7'b0, wr_en[10],
                         7'b0, wr_en[9],
                         7'b0, wr_en[8],
                         7'b0, wr_en[7],
                         7'b0, wr_en[6],
                         7'b0, wr_en[5],
                         7'b0, wr_en[4],
                         7'b0, wr_en[3],
                         7'b0, wr_en[2],
                         7'b0, wr_en[1],
                         7'b0, wr_en[0]} + wr_addr;

            if (wr_en == 17'h0000 && wr_dec == 1'b1) begin
                wr_start_c = 0;
                wr_addr_c = 16'h0000;
                wr_dec_c = 0;
                //done = 1;
            end
        end

        else begin
            wr_en_c = 16'h0000;
        end

        if (wr_en == 16'h8000) begin
            done_c = 1'b1;
        end // if

        if (sys_arr_active == 1'b1 && done == 1'b1) begin
            done_c = 1'b0;
        end // if

        if(reset == 1) begin
            wr_addr_c = 0;
            wr_en_c  = 16'h0000;
            wr_dec_c = 0;
            wr_start_c = 0;
            done_c = 0;
        end
    end
endmodule
