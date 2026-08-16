
// ---------------------------------------------------------------------
// TOP MODULE
// ---------------------------------------------------------------------
module booth_mult_top #(parameter N = 8) (
    input  logic             clk,
    input  logic             rst,
    input  logic             start,
    input  logic [N-1:0]     multiplicand,
    input  logic [N-1:0]     multiplier,
    output logic [2*N-1:0]   product,
    output logic             done
);

    logic load, add_en, sub_en, shift_en, dec_count;
    logic q0, q_1, count_zero;

    booth_controller u_ctrl (
        .clk        (clk),
        .rst        (rst),
        .start      (start),
        .q0         (q0),
        .q_1        (q_1),
        .count_zero (count_zero),
        .load       (load),
        .add_en     (add_en),
        .sub_en     (sub_en),
        .shift_en   (shift_en),
        .dec_count  (dec_count),
        .done       (done)
    );

    booth_datapath #(.N(N)) u_dp (
        .clk          (clk),
        .rst          (rst),
        .load         (load),
        .multiplicand (multiplicand),
        .multiplier   (multiplier),
        .add_en       (add_en),
        .sub_en       (sub_en),
        .shift_en     (shift_en),
        .dec_count    (dec_count),
        .q0           (q0),
        .q_1          (q_1),
        .count_zero   (count_zero),
        .product      (product)
    );

endmodule
