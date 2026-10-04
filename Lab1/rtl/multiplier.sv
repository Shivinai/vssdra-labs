module multiplier #(
    parameter int WIDTH = 16
) (
    input  logic CLK,
    input  logic RESET,
    input  logic START,
    input  logic signed [WIDTH-1:0] DIN_A,
    input  logic signed [WIDTH-1:0] DIN_B,
    output logic READY,
    output logic signed [2*WIDTH-1:0] DOUT
);
    logic LOAD;
    logic RUN;

    logic signed [WIDTH-1:0] A_REG;
    logic [WIDTH-1:0] B_REG;
    logic  B_PREV;
    logic signed [WIDTH+1:0] ACCUMULATOR;

    logic [2:0] TRIPLET;
    logic signed [WIDTH+1:0] CONTROL;
    logic signed [WIDTH+1:0] SUM;

    multiplier_control #(
        .WIDTH(WIDTH)
    ) u_multiplier_control (
        .CLK (CLK),
        .RESET (RESET),
        .START (START),
        .LOAD (LOAD),
        .RUN (RUN),
        .READY (READY)
    );

    assign TRIPLET = {B_REG[1:0], B_PREV};

    always_comb begin
        case (TRIPLET)
            3'b000: CONTROL = '0;
            3'b001: CONTROL = A_REG;
            3'b010: CONTROL = A_REG;
            3'b011: CONTROL = A_REG <<< 1;
            3'b100: CONTROL = -A_REG <<< 1;
            3'b101: CONTROL = -A_REG;
            3'b110: CONTROL = -A_REG;
            3'b111: CONTROL = '0;
            default: CONTROL = '0;
        endcase

        SUM = ACCUMULATOR + CONTROL;
    end

    always_ff @(posedge CLK) begin
        if (RESET) begin
            A_REG <= '0;
            B_REG <= '0;
            B_PREV <= 1'b0;
            ACCUMULATOR <= '0;
        end else if (LOAD) begin
            A_REG <= DIN_A;
            B_REG <= DIN_B;
            B_PREV <= 1'b0;
            ACCUMULATOR <= '0;
        end else if (RUN) begin
            ACCUMULATOR <= {{2{SUM[WIDTH+1]}}, SUM[WIDTH+1:2]};
            B_REG <= {SUM[1:0], B_REG[WIDTH-1:2]};
            B_PREV <= B_REG[1];
        end
    end

    assign DOUT = {ACCUMULATOR[WIDTH-1:0], B_REG};

endmodule
