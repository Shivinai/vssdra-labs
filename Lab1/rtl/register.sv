module register #(
    parameter int WIDTH = 16,
    parameter logic signed [WIDTH-1:0] RESET_VALUE = '0
) (
    input  logic signed [WIDTH-1:0] DIN,
    input  logic CLK,
    input  logic ENABLE,
    input  logic RESET,
    input  logic CLEAR,
    output logic signed [WIDTH-1:0] DOUT
);

    always_ff @(posedge CLK) begin
        if (RESET) begin
            DOUT <= RESET_VALUE;
        end else if (CLEAR) begin
            DOUT <= '0;
        end else if (ENABLE) begin
            DOUT <= DIN;
        end
    end

endmodule
