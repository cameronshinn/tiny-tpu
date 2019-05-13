`define CONTROL_OFFSET 2'b00
`define WEIGHT_OFFSET 2'b01
`define INPUT_OFFSET 2'b10

module matrixMultiplier (
	// signals to connect to an Avalon clock source interface
	clk,
	reset,

	// signals to connect to an Avalon-MM slave interface
	slave_address,
	slave_read,
	slave_write,
	slave_readdata,
	slave_writedata,
	slave_byteenable
);

    parameter DATA_WIDTH = 32;

    // clock interface
    input clk;
    input reset;

    // slave interface
    input [9:0] slave_address;	//GET CORRECT WIDTH
    input slave_read;
    input slave_write;
    output reg [DATA_WIDTH-1:0] slave_readdata;
    input [DATA_WIDTH-1:0] slave_writedata;
    input [(DATA_WIDTH/8)-1:0] slave_byteenable;

    wire [DATA_WIDTH-1:0] matrixA_dout;
    wire [DATA_WIDTH-1:0] matrixB_dout;
    wire [DATA_WIDTH-1:0] matrixResult_dout;
    wire [DATA_WIDTH-1:0] vectorSum;

    wire [7:0] rd_addrA;
    wire [7:0] rd_addrB;
    wire [7:0] wr_addr1_2;
    reg [7:0] wr_addr2_3, wr_addr3_4, wr_addr4_5;
    wire wr_en1_2;
    reg wr_en2_3, wr_en3_4, wr_en4_5;
    reg start;
    wire done1_2;
    reg done2_3, done3_4, done4_5;

    wire matrixA_wren = slave_write & (slave_address[9:8] == `MATRIX_A_ADDRESS_OFFSET);
    wire matrixB_wren = slave_write & (slave_address[9:8] == `MATRIX_B_ADDRESS_OFFSET);
    wire matrixResult_wren = slave_write & (slave_address[9:8] == `MATRIX_RESULT_ADDRESS_OFFSET);

    // ========================================================================
    // TPU
    // ========================================================================
    wire wr_en_weight = slave_write & (slave_address[9:8] == `WEIGHT_OFFSET;
    wire wr_en_data = slave_write & slave_address[9:8] == `INPUT_OFFSET;
    //wire rd_en_weights = slave_read & (slave_address[9:8] == `WEIGHT_OFFSET;
    //wire rd_en_input = slave_read & (slave_address[9:8] == `INPUT_OFFSET;
    //
    wire wr_addr

    reg wr_en_fifo;
    reg load_en_weight;
    reg mult_en;

    
    //wire rd_data_weights;
    //wire rd_data_input;

    top_TPU top(    //no reads???
        .clk(clk),
        .reset(reset),
        .wr_en_weight(wr_en_weights),           //enable write weights to mem
        .wr_en_data(wr_en_input),               //enable write data/input to mem
        .wr_en_fifo(wr_en_fifo),                //enable write from mem to fifo
        //.rd_en_weights(rd_en_weights),
        //.rd_en_input(rd_en_input),
        .wr_addr_weight(slave_address[7:0]),    //write weight addr to mem
        //.wr_addr_input(slave_address[7:0]),
        .wr_data_weight(slave_writedata),        //write weight data/input to mem
        //.rd_addr_weights(slave_address[7:0]),
        //.rd_addr_input(slave_address[7:0]),
        .base_addr_weight(slave_address[7:0]),  //base addr for weights in mem
        .base_addr_data(slave_address[7:0]),    //base addr for data/inputs in mem
        //.load_fifo(ld_fifo),
        .load_en_weight(load_en_weight),       //load weight from fifo & write to array?
        .mult_en(mult_en),                      //enable the multiplication
        //.rd_data_weights(rd_data_weights),
        //.rd_data_input(rd_data_input),
        .wr_addr_output(wr_addr_output)         //output addr to write to?
        //to-do: add outputs
    );

    always @ (*) begin
        case(slave_address[9:8]) begin //wtf do I do here now
            `CONTROL_OFFSET:
                //slave_read_data = GET FROM ALAN
            `WEIGHT_OFFSET:
                //slave_read_data = rd_data_weights;
            `INPUT_OFFSET:
                //slave_read_data = rd_data_input;
        endcase
    end

    always @ (posedge clk) begin
        if (slave_write == 1 & slave_address[9:8] == `CONTROL_OFFSET) begin
            wr_en_fifo <= slave_address[2];
            load_en_weights <= slave_address[1];
            mult_en <= slave_address[0];
        end
    end

    // ========================================================================
    // END TPU
    // ========================================================================

    //Instantiate two memories to hold the matrices and one for results. Each is 32bits wide and 256 deep. Each is dual ported.
    MatrixRAM	matrixA(
        .clock ( clk),
        .data ( slave_writedata ),
        .rdaddress (rd_addrA),
        .wraddress (slave_address[7:0]),
        .wren (matrixA_wren),
        .q (matrixA_dout)
    );

    MatrixRAM	matrixB(
        .clock ( clk),
        .data ( slave_writedata ),
        .rdaddress (rd_addrB),
        .wraddress (slave_address[7:0]),
        .wren (matrixB_wren),
        .q (matrixB_dout)
    );wire [DATA_WIDTH-1:0] vectorSum;


    MatrixRAM	matrixResult(
        .clock ( clk),
        .data (vectorSum),
        .rdaddress (slave_address[7:0]),
        .wraddress (wr_addr4_5),
        .wren (wr_en4_5),
        .q (matrixResult_dout)
    );

    control Control (
        .clk(clk),
        .start(start),
        .reset(reset),
        .done(done1_2),
        .rd_addrA(rd_addrA),
        .rd_addrB(rd_addrB),
        .wr_addr(wr_addr1_2),
        .wr_en(wr_en1_2)
    );

    vectorAdd Adder (
        .clk(clk),
        .inA(matrixA_dout),
        .inB(matrixB_dout),
        .out(vectorSum)
    );

    //Create some registers for the

    always @(slave_address or matrixA_dout or matrixB_dout or matrixResult_dout or done3_4) begin
      case(slave_address[9:8])
      	`MATRIX_A_ADDRESS_OFFSET: slave_readdata = matrixA_dout;
      	`MATRIX_B_ADDRESS_OFFSET: slave_readdata = matrixB_dout;
      	`MATRIX_RESULT_ADDRESS_OFFSET: slave_readdata = matrixResult_dout;
        `CONTROL_OFFSET: slave_readdata = {31'b101_1010_1010_1010_1010_1010_1010_1010, done4_5};
      endcase // case (slave_address[9:8])
    end


    always @ (posedge clk) begin
        wr_addr2_3 <= wr_addr1_2;
        wr_addr3_4 <= wr_addr2_3;
	    wr_addr4_5 <= wr_addr3_4;
        done2_3 <= done1_2;
        done3_4 <= done2_3;
	    done4_5 <= done3_4;
        wr_en2_3 <= wr_en1_2;
        wr_en3_4 <= wr_en2_3;
	    wr_en4_5 <= wr_en3_4;

        if ((slave_write == 1) && (slave_address[9:8] == `CONTROL_OFFSET)) begin
            case (slave_writedata[1])
                1'b0: begin
                    start <= 1'b0;
                end

                1'b1: begin
                    start <= 1'b1;
                end
            endcase // case (slave_address[1:0])
        end
    end // always @ (posedge clk or posedge reset)
endmodule













