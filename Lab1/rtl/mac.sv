module mac #(
    parameter int WIDTH = 16
) (
    input  logic CLK,
    input  logic RESET,
    input  logic START,
    input  logic signed [WIDTH-1:0] DIN_A,
    input  logic signed [WIDTH-1:0] DIN_B,
    output logic READY,
    output logic signed [WIDTH*2-1:0] DOUT
);

    logic MULT_START;
    logic MULT_READY;
    logic REG_WRITE;

    logic signed [WIDTH-1:0] MULT_OUT;
    logic signed [2*WIDTH-1:0] SUM_OUT;
    logic signed [WIDTH*2-1:0] ACC_OUT;

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
        .RESET (RESET),
        .START (MULT_START),
        .DIN_A (DIN_A),
        .DIN_B (DIN_B),
        .READY (MULT_READY),
        .DOUT (MULT_OUT)
    );

    summator #(
        .WIDTH(WIDTH)
    ) u_summator (
        .DIN_A (MULT_OUT),
        .DIN_B (ACC_OUT),
        .DOUT (SUM_OUT)
    );

    register #(
        .WIDTH(WIDTH * 2)
    ) u_register (
        .CLK (CLK),
        .RESET (RESET),
        .ENABLE (REG_WRITE),
        .DIN (SUM_OUT),
        .DOUT (ACC_OUT)
    );

    assign DOUT = ACC_OUT;

endmodule
