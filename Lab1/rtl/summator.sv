module summator #(
    parameter int WIDTH = 16,
    parameter int ACCUMULATOR_WIDTH = 2*WIDTH
) (
    input  logic signed [2*WIDTH-1:0] DIN_A,
    input  logic signed [ACCUMULATOR_WIDTH-1:0] DIN_B,
    output logic signed [ACCUMULATOR_WIDTH-1:0] DOUT
);
    assign DOUT = ACCUMULATOR_WIDTH'(DIN_A) + DIN_B;
 
endmodule
 
