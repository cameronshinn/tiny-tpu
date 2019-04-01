// dff8.v
// Standard D flip-flop, transferring inputs of size DATA_WIDTH

// Inputs:
//
// clk -- clock signal
// reset -- when high, sets output to 0 on clock positive edge
// en -- enable latch
// d -- data input

// Outputs:
//
// q -- data output

module dff8(clk, reset, en, d, q);

    parameter DATA_WIDTH = 8;

    input clk;
    input reset;
    input en;
    input [DATA_WIDTH-1:0] d;
    output reg [DATA_WIDTH-1:0] q;

    always @(posedge clk) begin
        
        if (reset) begin
            q <= 0;
        end  // if (reset == 1'b1)
        
        else if (en) begin
            q <= d;
        end  // else if (en)

        else begin  // expecting this to get synthesized away (remove otherwise)
            q <= q;
        end  // else

    end  // always @(posedge clk)

endmodule  // dff
