module mac #(
    parameter int WIDTH = 16,
    parameter int FRAC = 13,
    parameter int ACCUMULATOR_WIDTH = 2*WIDTH + 4
) (
    input logic CLK,
    input logic RESET,
    input logic CLEAR,
    input logic START,
    input logic signed [WIDTH-1:0] DIN_A,
    input logic signed [WIDTH-1:0] DIN_B,
    output logic READY,
    output logic signed [WIDTH-1:0] DOUT,
    output logic signed [ACCUMULATOR_WIDTH-1:0] ACC
);
    logic MULT_START;
    logic MULT_READY;
    logic REG_WRITE;
 
    logic signed [2*WIDTH-1:0] MULT_OUT;
    logic signed [ACCUMULATOR_WIDTH-1:0] SUM_OUT;
    logic signed [ACCUMULATOR_WIDTH-1:0] ACC_OUT;
 
    control u_control (
        .CLK (CLK),
        .RESET (RESET),
        .START (START),
        .MULT_READY (MULT_READY),
        .CONTROL_READY (READY),
        .MULT_START (MULT_START),
        .REG_WRITE (REG_WRITE)
    );
 
    multiplier #(
        .WIDTH(WIDTH)
    ) u_multiplier (
        .CLK (CLK),
        .RESET (RESET),
        .START (MULT_START),
        .DIN_A (DIN_A),
        .DIN_B (DIN_B),
        .READY (MULT_READY),
        .DOUT (MULT_OUT)
    );
 
    summator #(
        .WIDTH(WIDTH),
        .ACCUMULATOR_WIDTH(ACCUMULATOR_WIDTH)
    ) u_summator (
        .DIN_A (MULT_OUT),
        .DIN_B (ACC_OUT),
        .DOUT (SUM_OUT)
    );
 
    register #(
        .WIDTH(ACCUMULATOR_WIDTH)
    ) u_register (
        .CLK (CLK),
        .RESET (RESET),
        .CLEAR (CLEAR),
        .ENABLE (REG_WRITE),
        .DIN (SUM_OUT),
        .DOUT (ACC_OUT)
    );
 
    assign ACC = ACC_OUT;
 
    localparam logic signed [ACCUMULATOR_WIDTH-1:0] ONE = ACCUMULATOR_WIDTH'(1);
    localparam logic signed [ACCUMULATOR_WIDTH-1:0] MAX_V = (ONE <<< (WIDTH-1)) - ONE;
    localparam logic signed [ACCUMULATOR_WIDTH-1:0] MIN_V = -(ONE <<< (WIDTH-1));
    localparam logic signed [ACCUMULATOR_WIDTH-1:0] HALF = ONE <<< (FRAC-1);
 
    logic signed [ACCUMULATOR_WIDTH-1:0] ROUNDED;
    logic signed [ACCUMULATOR_WIDTH-1:0] SHIFTED;
 
    assign ROUNDED = ACC_OUT + HALF;
    assign SHIFTED = ROUNDED >>> FRAC;
 
    assign DOUT = (SHIFTED > MAX_V) ? MAX_V[WIDTH-1:0] : (SHIFTED < MIN_V) ? MIN_V[WIDTH-1:0] : SHIFTED[WIDTH-1:0];
 
endmodule
