`timescale 1ns/1ps

module uart_loopback_tb;

localparam CLKS_PER_BIT = 8;

reg clk;
reg rst;
reg tx_start;
reg [7:0] tx_data;

wire tx_serial;
wire [7:0] rx_data;
wire rx_done;
wire tx_busy;
wire tx_done;

uart_loopback_top #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) uut (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_serial(tx_serial),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

always #5 clk = ~clk;

task transmit_and_check;
    input [7:0] data;
    begin
        tx_data = data;
        tx_start = 1'b1;
        #10;
        tx_start = 1'b0;

        wait(rx_done == 1'b1);
        #1;

        if (rx_data == data)
            $display("PASS: Sent %h, Received %h", data, rx_data);
        else
            $display("FAIL: Sent %h, Received %h", data, rx_data);

        #30;
    end
endtask

initial begin
    clk = 0;
    rst = 1;
    tx_start = 0;
    tx_data = 8'h00;

    #20;
    rst = 0;

    transmit_and_check(8'hA5);
    transmit_and_check(8'h3C);
    transmit_and_check(8'h55);

    #50;
    $stop;
end

endmodule
