// sysArrRow creates a parametrized row of systolic array PEs

module sysArrRow(
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
    parameter row_width = 2;
    localparam weight_width = 8 * row_width; // Number of weight bits needed
    localparam sum_width = 16 * row_width; // Number of sum bits needed

    input clk;
    input active;
    input [7:0] datain; // For single row, we only need one data in.
    input [weight_width-1:0] win; // Number of weight bytes equal to row_width
    input [sum_width-1:0] sumin;
    input [row_width-1:0] wwrite;

    // Outputs to the next row in array (bottom)
    output wire [sum_width-1:0] maccout;
    output wire [weight_width-1:0] wout;
    output wire [row_width-1:0] wwriteout;
    output wire [row_width-1:0] activeout;

    // Outputs to the right side of the array
    output [7:0] dataout;

    // Interconnects (PE - PE Connections)
    wire [row_width-1:0] activeout_inter;
    wire [(weight_width-8)-1:0] dataout_inter;

    assign activeout = activeout_inter;

    genvar i;
    generate
        for (i = 0; i < row_width; i = i + 1) begin
            if (i == 0) begin
                // The first PE in the row has different inputs
                pe first_pe_inst(
                    .clk(clk),
                    .active(active),
                    .datain(datain),
                    .win(win[7:0]),
                    .sumin(sumin[15:0]),
                    .wwrite(wwrite[0]),
                    .maccout(maccout[15:0]),
                    .dataout(dataout_inter[7:0]),
                    .wout(wout[7:0]),
                    .wwriteout(wwriteout[0]),
                    .activeout(activeout_inter[i])
                );
            end // if (i == 0)
            else if (i == row_width - 1) begin
                // The last PE in the row has different outputs
                pe last_pe_inst(
                    .clk(clk),
                    .active(activeout_inter[i-1]),
                    .datain(dataout_inter[(i*8)-1:(i-1)*8]),
                    .win(win[((i+1)*8)-1:(i*8)]),
                    .sumin(sumin[((i+1)*16)-1:(i*16)]),
                    .wwrite(wwrite[row_width-1]),
                    .maccout(maccout[((i+1)*16)-1:(i*16)]),
                    .dataout(dataout),
                    .wout(wout[((i+1)*8)-1:(i*8)]),
                    .wwriteout(wwriteout[row_width-1]),
                    .activeout(activeout_inter[i])
                );
            end // else if (i == row_width - 1)
            else begin
                pe pe_inst(
                    .clk(clk),
                    .active(activeout_inter[i-1]),
                    .datain(dataout_inter[(i*8)-1:(i-1)*8]),
                    .win(win[((i+1)*8)-1:(i*8)]),
                    .sumin(sumin[((i+1)*16)-1:(i*16)]),
                    .wwrite(wwrite[i]),
                    .maccout(maccout[((i+1)*16)-1:(i*16)]),
                    .dataout(dataout_inter[((i+1)*8)-1:(i*8)]),
                    .wout(wout[((i+1)*8)-1:(i*8)]),
                    .wwriteout(wwriteout[i]),
                    .activeout(activeout_inter[i])
                );
            end // else
        end // for (i = 0; i < row_width; i = i + 1)
    endgenerate
endmodule // sysArrRow
