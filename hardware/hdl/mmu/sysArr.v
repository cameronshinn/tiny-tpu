// This module describes a systolic array.
// It depends on sysArrRow.v which describes a single row in the array.

module sysArr(
    clk,
    active,
    datain,
    win,
    sumin,
    wwrite,
    maccout,
    wout,
    wwriteout,
    activeout,
    dataout
);

    parameter width_height = 2;
    localparam weight_width = 8 * width_height; // number of weight bits needed
    localparam sum_width = 16 * width_height; // number of sum bits needed
    localparam data_width = 8 * width_height; // number of data bits needed

    input clk;
    input active;
    input [data_width-1:0] datain; // 8 bits for each row. Top row has LSB
    input [weight_width-1:0] win; // 8 bits for each column. Left column has LSB
    input [sum_width-1:0] sumin; // 16 bits for each column. Should always be 0
    input [width_height-1:0] wwrite; // 1 bit for each column. Left column has LSB

    // Outputs from bottom row of array
    output wire [sum_width-1:0] maccout; // 16 bit output of result matrix
    output wire [weight_width-1:0] wout; // Not used
    output wire [width_height-1:0] wwriteout; // Not used
    output wire [width_height-1:0] activeout; // Not used

    // Outputs from right side of array
    output [data_width-1:0] dataout; // 8 bits for each row. Top row has LSB

    // Interconnects (Row - Row Connections)
    wire [((width_height-1)*width_height*16)-1:0] maccout_inter;
    wire [((width_height-1)*width_height*8)-1:0] wout_inter;
    wire [((width_height-1)*width_height)-1:0] wwriteout_inter;
    wire [((width_height-1)*width_height)-1:0] activeout_inter;

    genvar i;
    generate
        for (i = 0; i < width_height; i = i + 1) begin : genblk1
            if (i == 0) begin
                // The first row has different inputs
                sysArrRow first_sysArrRow_inst(
                    .clk      (clk),
                    .active   (active),
                    .datain   (datain[((i+1)*8)-1:(i*8)]),
                    .win      (win),
                    .sumin    ({sum_width{1'b0}}), // Simulation may throw a warning due to unmatched port sizes here
                    .wwrite   (wwrite),
                    .maccout  (maccout_inter[((i+1)*width_height*16)-1:(i*width_height*16)]),
                    .wout     (wout_inter[((i+1)*width_height*8)-1:(i*width_height*8)]),
                    .wwriteout(wwriteout_inter[((i+1)*width_height)-1:(i*width_height)]),
                    .activeout(activeout_inter[((i+1)*width_height)-1:(i*width_height)]),
                    .dataout  (dataout[((i+1)*8)-1:(i*8)])
                );

                defparam first_sysArrRow_inst.row_width = width_height;

            end // if (i == 0)

            else if (i == width_height-1) begin
                // The last row has different outputs
                sysArrRow last_sysArrRow_inst(
                    .clk      (clk),
                    .active   (activeout_inter[((i-1)*width_height)]),
                    .datain   (datain[((i+1)*8)-1:(i*8)]),
                    .win      (wout_inter[(i*width_height*8)-1:((i-1)*width_height*8)]),
                    .sumin    (maccout_inter[(i*width_height*16)-1:((i-1)*width_height*16)]),
                    .wwrite   (wwriteout_inter[(i*width_height)-1:((i-1)*width_height)]),
                    .maccout  (maccout),
                    .wout     (wout),
                    .wwriteout(wwriteout),
                    .activeout(activeout),
                    .dataout  (dataout[((i+1)*8)-1:(i*8)])
                );

                defparam last_sysArrRow_inst.row_width = width_height;

            end // else if (i == width_height-1)

            else begin
                // intermediate rows have generic inputs/outputs
                sysArrRow sysArrRow_inst(
                    .clk      (clk),
                    .active   (activeout_inter[((i-1)*width_height)]),
                    .datain   (datain[((i+1)*8)-1:(i*8)]),
                    .win      (wout_inter[(i*width_height*8)-1:((i-1)*width_height*8)]),
                    .sumin    (maccout_inter[(i*width_height*16)-1:((i-1)*width_height*16)]),
                    .wwrite   (wwriteout_inter[(i*width_height)-1:((i-1)*width_height)]),
                    .maccout  (maccout_inter[((i+1)*width_height*16)-1:(i*width_height*16)]),
                    .wout     (wout_inter[((i+1)*width_height*8)-1:(i*width_height*8)]),
                    .wwriteout(wwriteout_inter[((i+1)*width_height)-1:(i*width_height)]),
                    .activeout(activeout_inter[((i+1)*width_height)-1:(i*width_height)]),
                    .dataout  (dataout[((i+1)*8)-1:(i*8)])
                );

                defparam sysArrRow_inst.row_width = width_height;

            end // else
        end // for (i = 0; i < width_height; i = i + 1)
    endgenerate
endmodule // sysArr
