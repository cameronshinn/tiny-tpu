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
    parameter width_height = 16;
    parameter data_width = width_height * 8;

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

    // ========================================================================
    // TPU side
    // ========================================================================

    // control signals
    wire wr_en_weight = slave_write & (slave_address[9:8] == `WEIGHT_OFFSET);
    wire wr_en_data = slave_write & (slave_address[9:8] == `INPUT_OFFSET);
    reg mul_en;
    reg wr_en_fifo;
    //wire rd_en_weights = slave_read & (slave_address[9:8] == `WEIGHT_OFFSET;
    //wire rd_en_input = slave_read & (slave_address[9:8] == `INPUT_OFFSET;

    // address and data signals
    reg [data_width-1:0] wr_addr_weight, wr_data_weight; 

    reg wr_addr_output[data_width];
    reg load_en_weight;

    
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
        .load_en_weight(load_en_weight),       //load weight from fifo & write to array before calculations - ie a prep matrix
        .mult_en(mult_en),                      //enable the multiplication
        //.rd_data_weights(rd_data_weights),
        //.rd_data_input(rd_data_input),
        .wr_addr_output(wr_addr_output)         //output addr to write to in mem?
        //to-do: add outputs
    );

    always @(*) begin
        case(slave_address[9:8]) //wtf do I do here now
            `CONTROL_OFFSET:
                slave_readdata = 0;
            `WEIGHT_OFFSET:
                slave_readdata = 0;
            `INPUT_OFFSET:
                slave_readdata = 0;
            default:
                slave_readdata = 0;
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

endmodule













