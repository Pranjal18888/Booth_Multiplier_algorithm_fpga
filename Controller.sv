/ ---------------------------------------------------------------------
// CONTROLLER (Finite State Machine)
// ---------------------------------------------------------------------
module booth_controller (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic q0,
    input  logic q_1,
    input  logic count_zero,
    output logic load,
    output logic add_en,
    output logic sub_en,
    output logic shift_en,
    output logic dec_count,
    output logic done
);

    typedef enum logic [2:0] {IDLE, LOAD_S, CHECK, ARITH, SHIFT_S, DONE_S} state_t;
    state_t state, next_state;

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    // Next-state & output logic
    always_comb begin
        load      = 1'b0;
        add_en    = 1'b0;
        sub_en    = 1'b0;
        shift_en  = 1'b0;
        dec_count = 1'b0;
        done      = 1'b0;
        next_state = state;

        case (state)
            IDLE: begin
                if (start) next_state = LOAD_S;
            end

            LOAD_S: begin
                load = 1'b1;
                next_state = CHECK;
            end

            CHECK: begin
                if (count_zero)
                    next_state = DONE_S;
                else begin
                    case ({q0, q_1})
                        2'b01, 2'b10: next_state = ARITH; // needs add or sub
                        default:      next_state = SHIFT_S; // 00 / 11 -> no-op, just shift
                    endcase
                end
            end

            ARITH: begin
                if (q0 == 1'b1 && q_1 == 1'b0)      sub_en = 1'b1; // 10 -> A = A - M
                else if (q0 == 1'b0 && q_1 == 1'b1) add_en = 1'b1; // 01 -> A = A + M
                next_state = SHIFT_S;
            end

            SHIFT_S: begin
                shift_en  = 1'b1;
                dec_count = 1'b1;
                next_state = CHECK;
            end

            DONE_S: begin
                done = 1'b1;
                if (!start) next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
