module uart_rx #(
    parameter CLKS_PER_BIT = 87
)(
    input clk,
    input rst,
    input rx_serial,
    output reg [7:0] rx_data,
    output reg rx_done,
    output reg rx_busy
);

localparam IDLE  = 3'd0;
localparam START = 3'd1;
localparam DATA  = 3'd2;
localparam STOP  = 3'd3;
localparam DONE  = 3'd4;

reg [2:0] state;
reg [$clog2(CLKS_PER_BIT)-1:0] clk_count;
reg [2:0] bit_index;
reg [7:0] data_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        rx_data <= 8'b0;
        rx_done <= 1'b0;
        rx_busy <= 1'b0;
        clk_count <= 0;
        bit_index <= 0;
        data_reg <= 8'b0;
    end else begin
        rx_done <= 1'b0;

        case (state)
            IDLE: begin
                rx_busy <= 1'b0;
                clk_count <= 0;
                bit_index <= 0;

                if (rx_serial == 1'b0) begin
                    rx_busy <= 1'b1;
                    state <= START;
                end
            end

            START: begin
                rx_busy <= 1'b1;

                if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                    if (rx_serial == 1'b0) begin
                        clk_count <= 0;
                        state <= DATA;
                    end else begin
                        state <= IDLE;
                    end
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            DATA: begin
                rx_busy <= 1'b1;

                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    data_reg[bit_index] <= rx_serial;

                    if (bit_index == 3'd7) begin
                        bit_index <= 0;
                        state <= STOP;
                    end else begin
                        bit_index <= bit_index + 1'b1;
                    end
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            STOP: begin
                rx_busy <= 1'b1;

                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    state <= DONE;
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            DONE: begin
                rx_data <= data_reg;
                rx_done <= 1'b1;
                rx_busy <= 1'b0;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
            end
        endcase
    end
end

endmodule
