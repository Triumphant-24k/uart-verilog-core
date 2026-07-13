`timescale 1ns/1ps

module uart_rx_tb;

localparam CLKS_PER_BIT = 8;

reg clk;
reg rst;
reg rx_serial;

wire [7:0] rx_data;
wire rx_done;
wire rx_busy;

uart_rx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) uut (
    .clk(clk),
    .rst(rst),
    .rx_serial(rx_serial),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .rx_busy(rx_busy)
);

always #5 clk = ~clk;

task send_uart_byte;
    input [7:0] data;
    integer i;
    begin
        rx_serial = 1'b0;
        #(CLKS_PER_BIT * 10);

        for (i = 0; i < 8; i = i + 1) begin
            rx_serial = data[i];
            #(CLKS_PER_BIT * 10);
        end

        rx_serial = 1'b1;
        #(CLKS_PER_BIT * 10);
    end
endtask

initial begin
    clk = 0;
    rst = 1;
    rx_serial = 1'b1;

    #20;
    rst = 0;

    send_uart_byte(8'hA5);
    wait(rx_done == 1'b1);
    #20;

    send_uart_byte(8'h3C);
    wait(rx_done == 1'b1);
    #50;

    $stop;
end

endmodule
