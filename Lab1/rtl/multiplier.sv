module multiplier #(
    parameter int WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] DIN_A,
    input  logic signed [WIDTH-1:0] DIN_B,
    input  logic START,
    input  logic RESET,
    output logic READY,
    output logic signed [WIDTH-1:0] DOUT
);
    localparam int CNT = WIDTH / 2;

    logic signed [WIDTH:0] B_EXTENDED;
    logic signed [2*WIDTH-1:0] TEMP;

    assign B_EXTENDED = {DIN_B, 1'b0};

    always_comb begin
        TEMP = '0;
        READY = 1'b0;
        DOUT = '0;

        if (!RESET && START) begin
            READY = 1'b1;
            for (int i = 0; i < CNT; i++) begin
                logic [2:0] TRIPLET;
                logic signed [2*WIDTH-1:0] CONTROL;

                TRIPLET = B_EXTENDED[2*i +: 3];

                case (TRIPLET)
                    3'b000: CONTROL = '0;
                    3'b001: CONTROL = DIN_A;
                    3'b010: CONTROL = DIN_A;
                    3'b011: CONTROL = DIN_A <<< 1;
                    3'b100: CONTROL = -DIN_A <<< 1;
                    3'b101: CONTROL = -DIN_A;
                    3'b110: CONTROL = -DIN_A;
                    3'b111: CONTROL = '0;
                    default: CONTROL = '0;
                endcase
                TEMP = TEMP + (CONTROL <<< (2*i));
            end

            if (TEMP[31:30] == 2'b01) begin
                DOUT = 16'h7FFF; 
            end else begin
                DOUT = TEMP[30:15];
            end
        end
    end

endmodule