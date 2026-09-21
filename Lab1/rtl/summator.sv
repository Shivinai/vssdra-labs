module summator #(
    parameter int WIDTH = 16 
) (
    input logic signed [WIDTH-1:0] DIN_A,
    input logic signed [2*WIDTH-1:0] DIN_B,
    output logic signed [2*WIDTH-1:0] DOUT 
);
    assign DOUT = {16'b0, DIN_A} + DIN_B;

endmodule
