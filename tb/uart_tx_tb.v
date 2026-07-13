`timescale 1ns/1ps

module uart_tx_tb;

localparam CLKS_PER_BIT = 8;

reg clk;
reg rst;
reg tx_start;
reg [7:0] tx_data;

wire tx_serial;
wire tx_busy;
wire tx_done;

uart_tx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) uut (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_serial(tx_serial),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    tx_start = 0;
    tx_data = 8'h00;

    #20;
    rst = 0;

    tx_data = 8'hA5;
    tx_start = 1;
    #10;
    tx_start = 0;

    wait(tx_done == 1'b1);
    #20;

    tx_data = 8'h3C;
    tx_start = 1;
    #10;
    tx_start = 0;

    wait(tx_done == 1'b1);
    #50;

    $stop;
end

endmodule
