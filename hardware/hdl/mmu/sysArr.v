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
    input [sum_width-1:0] sumin; // 16 bits for each column. Left column has LSB
    input [width_height-1:0] wwrite; // 1 bit for each column. Left column has LSB

    // Outputs from bottom row of array
    output wire [sum_width-1:0] maccout;
    output wire [weight_width-1:0] wout;
    output wire [width_height-1:0] wwriteout;
    output wire [width_height-1:0] activeout;

    // Outputs from right side of array
    output [data_width-1:0] dataout; // 8 bits for each row. Top row has LSB

    // Interconnects (Row - Row Connections)

    genvar j;
    generate
        for (j = 0; j < width_height; j = j + 1) begin
            if (j == 0) begin
                // The first row has different inputs
                sysArrRow first_sysArrRow_inst(
                    .clk      (),
                    .active   (),
                    .datain   (),
                    .win      (),
                    .sumin    (),
                    .wwrite   (),
                    .maccout  (),
                    .wout     (),
                    .wwriteout(),
                    .activeout(),
                    .dataout  ()
                );

                defparam first_sysArrRow_inst.row_width = width_height;

            end // if (j == 0)

            else if (j == width_height-1) begin
                // The last row has different outputs
                sysArrRow sysArrRow_inst(
                    .clk      (),
                    .active   (),
                    .datain   (),
                    .win      (),
                    .sumin    (),
                    .wwrite   (),
                    .maccout  (),
                    .wout     (),
                    .wwriteout(),
                    .activeout(),
                    .dataout  ()
                );

                defparam sysArrRow_inst.row_width = width_height;

            end // else if (j == width_height-1)

            else begin
                // intermediate rows have generic inputs/outputs
                sysArrRow last_sysArrRow_inst(
                    .clk      (),
                    .active   (),
                    .datain   (),
                    .win      (),
                    .sumin    (),
                    .wwrite   (),
                    .maccout  (),
                    .wout     (),
                    .wwriteout(),
                    .activeout(),
                    .dataout  ()
                );

                defparam last_sysArrRow_inst.row_width = width_height;

            end // else
        end // for (j = 0; j < width_height; j = j + 1)
    endgenerate