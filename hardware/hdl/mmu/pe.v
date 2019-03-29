// This is a single processing element in the matrix multiply unit.

// Inputs:
//
// clk -- global clk signal
// active -- if high, we are performing multiplies and passing values
// datain -- 8-bit datain (matrix element)
// win -- 8-bit weight value
// sumin -- sum input from previous element in array
// wwrite -- control update of internal weight

// Outputs:
//
// maccout -- datain * weight + sumin
// dataout -- pass datain to the right

module pe(
    input clk,
    input active,
    input [7:0] datain,
    input [7:0] win,
    input [15:0] sumin,
    input wwrite,

    output reg [15:0] maccout,
    output reg [7:0] dataout,
    output reg [7:0] wout,
    output reg wwriteout,
    output reg activeout
);

    reg [15:0] maccout_c;
    reg [7:0] dataout_c, wout_c;
    reg [7:0] weight, weight_c;
    reg wwriteout_c, activeout_c;

    always @(active or datain or sumin) begin

        activeout_c = active;
        if (active == 1'b1) begin
            dataout_c = datain;
            maccout_c = sumin + (datain * weight);
        end // if (active == 1'b1)

        else begin
            // If not active, stall pipeline. We may have run out of memory to feed
            // or store data going into and coming out of systolic array.
            // NOT SURE IF STALL IDEA WILL WORK
            dataout_c = dataout;
            maccout_c = maccout;
        end // else

    end // always @(active or datain or sumin)

    always @(win or wwrite) begin

        wwriteout_c = wwrite;
        if ((wwrite == 1'b1) || (wwriteout == 1'b1)) begin
            weight_c    = win;
            wout_c      = weight;
        end // if (wwrite == 1'b1)

        else begin
            weight_c = weight;
            wout_c = 8'hAA;
        end // else

    end //always @(win or wwrite)

    always @(posedge clk) begin

        maccout   <= maccout_c;
        dataout   <= dataout_c;
        weight    <= weight_c;
        wout      <= wout_c;
        wwriteout <= wwriteout_c;
        activeout <= activeout_c;

    end // always @(posedge clk)

endmodule // pe