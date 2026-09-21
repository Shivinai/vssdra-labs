module register #(
    parameter int WIDTH = 16
) (
    input logic signed [WIDTH-1:0] DIN,
    input logic CLK,
    input logic ENABLE,
    input logic RESET,
    output logic signed [WIDTH-1:0] DOUT
);

    always_ff @(posedge CLK) begin
        if (RESET) begin
            DOUT <= '0;
        end else if (ENABLE) begin
            DOUT <= DIN;
        end
    end

endmodule
