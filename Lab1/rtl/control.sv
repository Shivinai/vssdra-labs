module control (
    input logic RESET,
    input logic CLK,
    input logic START,
    input logic MULT_READY,
    output logic CONTROL_READY,
    output logic MULT_START,
    output logic REG_WRITE
);

    typedef enum logic {
        IDLE = 1'b0,
        WORK = 1'b1
    } STATE_T;

    STATE_T STATE, NEXT_STATE;

    always_ff @(posedge CLK) begin
        if (RESET) begin
            STATE <= IDLE;
        end else begin
            STATE <= NEXT_STATE;
        end
    end

    always_comb begin
        NEXT_STATE = STATE;
        MULT_START = 1'b0;
        REG_WRITE = 1'b0;
        CONTROL_READY = 1'b0;

        case (STATE)
            IDLE: begin
                CONTROL_READY = 1'b1;
                if (START) begin
                    MULT_START = 1'b1;
                    CONTROL_READY = 1'b0;
                    NEXT_STATE = WORK;
                end
            end

            WORK: begin
                MULT_START = 1'b1;
                if (MULT_READY) begin
                    REG_WRITE  = 1'b1; 
                    NEXT_STATE = IDLE;
                end
            end

            default: NEXT_STATE = IDLE;
        endcase
    end
    
endmodule
