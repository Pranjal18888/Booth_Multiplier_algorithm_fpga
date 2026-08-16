// ---------------------------------------------------------------------
// DATAPATH
// ---------------------------------------------------------------------
module booth_datapath #(parameter N = 8) (
    input  logic             clk,
    input  logic             rst,
    input  logic             load,
    input  logic [N-1:0]     multiplicand,
    input  logic [N-1:0]     multiplier,
    input  logic             add_en,
    input  logic             sub_en,
    input  logic             shift_en,
    input  logic             dec_count,
    output logic             q0,
    output logic             q_1,
    output logic             count_zero,
    output logic [2*N-1:0]   product
);

    localparam CW = $clog2(N+1);

    // NOTE: A_reg and M_reg are (N+1) bits wide -- one extra "guard" bit.
    // This fixes a classic Booth's-algorithm corner case: when the
    // multiplicand equals the most-negative N-bit value (e.g. -128 for
    // N=8), computing A = A - M requires representing -M = +128, which
    // does NOT fit in an N-bit signed register and silently overflows.
    // Widening A/M by 1 sign-extended bit lets that intermediate value
    // be represented correctly; the extra bit is dropped when forming
    // the final product.
    logic [N:0]   M_reg;
    logic [N:0]   A_reg;
    logic [N-1:0] Q_reg;
    logic         Q_1_reg;
    logic [CW-1:0] count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            M_reg   <= '0;
            A_reg   <= '0;
            Q_reg   <= '0;
            Q_1_reg <= 1'b0;
            count   <= '0;
        end
        else if (load) begin
            M_reg   <= {multiplicand[N-1], multiplicand}; // sign-extend to N+1 bits
            Q_reg   <= multiplier;
            A_reg   <= '0;
            Q_1_reg <= 1'b0;
            count   <= N[CW-1:0];
        end
        else begin
            // Add / Subtract stage ((N+1)-bit arithmetic -- no overflow)
            if (add_en)
                A_reg <= A_reg + M_reg;
            else if (sub_en)
                A_reg <= A_reg - M_reg;

            // Arithmetic right shift stage: {A,Q,Q-1} >>> 1
            if (shift_en)
                {A_reg, Q_reg, Q_1_reg} <= {A_reg[N], A_reg, Q_reg};

            // Iteration counter
            if (dec_count)
                count <= count - 1'b1;
        end
    end

    assign q0         = Q_reg[0];
    assign q_1        = Q_1_reg;
    assign count_zero = (count == '0);
    assign product     = {A_reg[N-1:0], Q_reg}; // drop the guard bit

endmodule
