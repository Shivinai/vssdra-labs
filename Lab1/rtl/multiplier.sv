module multiplier #(
    parameter int WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] DIN_A,
    input  logic signed [WIDTH-1:0] DIN_B,
    input  logic START,
    input  logic RESET,
    output logic READY,
    output logic signed [WIDTH*2-1:0] DOUT
);
    localparam int WIDTH_B = (WIDTH % 2 == 0) ? WIDTH : (WIDTH + 1);
    localparam int CNT = WIDTH_B / 2;

    logic signed [WIDTH_B:0] B_EXTENDED;
    logic signed [2*WIDTH-1:0] A_EXTENDED;

    assign A_EXTENDED = (2*WIDTH)'(DIN_A);
    assign B_EXTENDED = (WIDTH_B + 1)'($signed({DIN_B, 1'b0}));

    always_comb begin
        DOUT  = '0;
        READY = 1'b0;
        
        if (RESET) begin
            DOUT  = '0;
            READY = 1'b0;
        end else if (START) begin
            READY = 1'b1;
            for (int i = 0; i < CNT; i++) begin
                logic [2:0] TRIPLET;
                logic signed [2*WIDTH-1:0] CONTROL;

                TRIPLET = B_EXTENDED[2*i +: 3];

                case (TRIPLET)
                    3'b000: CONTROL = '0;
                    3'b001: CONTROL = A_EXTENDED;
                    3'b010: CONTROL = A_EXTENDED;
                    3'b011: CONTROL = A_EXTENDED <<< 1;
                    3'b100: CONTROL = -(A_EXTENDED <<< 1);
                    3'b101: CONTROL = -A_EXTENDED;
                    3'b110: CONTROL = -A_EXTENDED;
                    3'b111: CONTROL = '0;
                endcase

                DOUT = DOUT + (CONTROL <<< (2*i));
            end
        end
    end

endmodule
