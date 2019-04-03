// reluMux.v
// Cameron Shinn

// Inputs:
//
// in -- input signed value of size DATA_WIDTH

// Outputs:
//
// out -- ouptut ReLU value of size DATA_WIDTH

module reluMux(in, out);

    parameter DATA_WIDTH = 8;

    input signed [DATA_WIDTH-1:0] in;
    output wire signed [DATA_WIDTH-1:0] out;    

    assign out = (in > 0) ? in : 0;

endmodule  // reluMux(in, out)