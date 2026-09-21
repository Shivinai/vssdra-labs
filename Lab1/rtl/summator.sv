module summator #(
    parameter int WIDTH = 16 
) (
    input logic signed [WIDTH-1:0] DIN_A,
    input logic signed [WIDTH-1:0] DIN_B,
    output logic signed [WIDTH-1:0] DOUT 
);

    assign DOUT = DIN_A + DIN_B;
    
endmodule
