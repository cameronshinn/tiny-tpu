// fifo_control.v
// Cameron Shinn

module fifo_control(
    clk,
    reset,
    active, // active fifo control
    stagger_load, // en stagger load way
    fifo_en, // output fifo en
    done, // done flushing fifo
    weight_write
    );

    parameter fifo_width = 16;
    localparam COUNT_WIDTH = $clog2(fifo_width) + 1;

    input clk;
    input reset;
    input active;
    input stagger_load;
    output wire [fifo_width-1:0] fifo_en;
    output wire done;
    output wire weight_write;

    reg started, started_c;
    reg [COUNT_WIDTH - 1:0] count, count_c;
    reg stagger_latch, stagger_latch_c; // must latch to prevent changing midway

    assign fifo_en = {fifo_width{started}};
    assign done = ~(started || active);
    assign weight_write = (started && count < 16);

    always @(*) begin
        started_c = started;
        count_c = count;
        stagger_latch_c = stagger_latch;

        if (active && !started) begin // active signal and not started already
            started_c = 1'b1;
            stagger_latch_c = stagger_load;
            count_c = {COUNT_WIDTH{1'b0}};
        end // if (active && !started)

        if (started) begin
            count_c = count + 1'b1;

            if (stagger_latch) begin
                if (count == fifo_width*2-1) begin
                    started_c = 1'b0;
                end // if (count == fifo_width*2-1)
            end // if (stagger_latch)

            else begin // not staggered load
                if (count == fifo_width-1) begin
                    started_c = 1'b0;
                end // if (count == fifo_width-1)
            end // else
        end // if (started)

        if (reset) begin
            started_c = 1'b0;
            count_c = {COUNT_WIDTH{1'b0}};
            stagger_latch_c = stagger_load;
        end // if (reset)
    end // always @(*)

    always @(posedge clk) begin
        started <= started_c;
        count <= count_c;
        stagger_latch <= stagger_latch_c;
    end // always @(posedge clk)

endmodule // fifo_control
