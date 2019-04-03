// reluMux.v
// Cameron Shinn

// Inputs
//
//

// Outputs
//
//

module reluMux(in, out);

    paramter DATA_WIDTH = 8;

    input [DATA_WIDTH-1:0] in;
    output wire [DATA_WIDTH-1:0] out;    

    assign out = (in > 0) ? in : '0;

endmodule  // reluMux(in, out)