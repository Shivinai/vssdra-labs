module multiplier_control #(
    parameter int WIDTH = 16
) (
    input  logic CLK,
    input  logic RESET,
    input  logic START,
    output logic LOAD,
    output logic RUN,
    output logic READY
);

    localparam int CNT = WIDTH / 2;
    logic [$clog2(CNT+1)-1:0] COUNTER;

    typedef enum logic [1:0] {
        IDLE,
        WORK,
        DONE
    } state_t;

    state_t STATE;

    always_ff @(posedge CLK) begin
        if (RESET) begin
            STATE   <= IDLE;
            COUNTER <= '0;
        end else begin
            case (STATE)
                IDLE: begin
                    COUNTER <= '0;
                    if (START) begin
                        STATE <= WORK;
                    end
                end
                
                WORK: begin
                    COUNTER <= COUNTER + 1'b1;
                    if (COUNTER == CNT - 1) begin
                        STATE <= DONE;
                    end
                end

                DONE: begin
                    STATE <= IDLE;
                end

                default: begin
                    STATE <= IDLE;
                end
            endcase
        end
    end

    assign LOAD = (STATE == IDLE) && START;
    assign RUN = (STATE == WORK);
    assign READY = (STATE == DONE);

endmodule
