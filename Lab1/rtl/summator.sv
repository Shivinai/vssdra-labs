module summator #(
    parameter int WIDTH = 32,
    parameter int ACCUMULATOR_WIDTH = 32
) (
    input logic signed [WIDTH-1:0] DIN_A,
    input logic signed [2*WIDTH-1:0] DIN_B,
    output logic signed [2*WIDTH-1:0] DOUT 
);
    assign DOUT = ACCUMULATOR_WIDTH'(DIN_A) + DIN_B;

endmodule
