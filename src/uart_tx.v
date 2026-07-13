module uart_tx #(
    parameter CLKS_PER_BIT = 87
)(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output reg tx_serial,
    output reg tx_busy,
    output reg tx_done
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
        tx_serial <= 1'b1;
        tx_busy <= 1'b0;
        tx_done <= 1'b0;
        clk_count <= 0;
        bit_index <= 0;
        data_reg <= 8'b0;
    end else begin
        tx_done <= 1'b0;

        case (state)
            IDLE: begin
                tx_serial <= 1'b1;
                tx_busy <= 1'b0;
                clk_count <= 0;
                bit_index <= 0;

                if (tx_start) begin
                    data_reg <= tx_data;
                    tx_busy <= 1'b1;
                    state <= START;
                end
            end

            START: begin
                tx_serial <= 1'b0;
                tx_busy <= 1'b1;

                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    state <= DATA;
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            DATA: begin
                tx_serial <= data_reg[bit_index];
                tx_busy <= 1'b1;

                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;

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
                tx_serial <= 1'b1;
                tx_busy <= 1'b1;

                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    state <= DONE;
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            DONE: begin
                tx_done <= 1'b1;
                tx_busy <= 1'b0;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
            end
        endcase
    end
end

endmodule
