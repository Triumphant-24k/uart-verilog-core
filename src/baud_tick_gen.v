module baud_tick_gen #(
    parameter CLKS_PER_BIT = 87
)(
    input clk,
    input rst,
    output reg tick
);

reg [$clog2(CLKS_PER_BIT)-1:0] count;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0;
        tick <= 1'b0;
    end else begin
        if (count == CLKS_PER_BIT - 1) begin
            count <= 0;
            tick <= 1'b1;
        end else begin
            count <= count + 1'b1;
            tick <= 1'b0;
        end
    end
end

endmodule
