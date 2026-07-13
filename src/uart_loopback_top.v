module uart_loopback_top #(
    parameter CLKS_PER_BIT = 87
)(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output tx_serial,
    output [7:0] rx_data,
    output rx_done,
    output tx_busy,
    output tx_done
);

uart_tx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) TX_UNIT (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_serial(tx_serial),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

uart_rx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) RX_UNIT (
    .clk(clk),
    .rst(rst),
    .rx_serial(tx_serial),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .rx_busy()
);

endmodule
