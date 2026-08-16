// =====================================================================
// Nexys Board Wrapper for Booth Multiplier
// Maps physical switches/buttons/LEDs to the booth_mult_top ports.
//
// SW[15:8]  -> multiplicand (8-bit signed)
// SW[7:0]   -> multiplier   (8-bit signed)
// BTNC      -> start
// BTNU      -> rst
// LED[15:0] -> product (16-bit signed result)
// LED16_G / RGB LED (if available on your board) -> done
//
// NOTE: Port names here (CLK100MHZ, BTNC, BTNU, SW, LED) match the
// standard names used in Xilinx/Digilent's official Nexys4 DDR
// "Master XDC" file. If your board's master XDC uses slightly
// different names (e.g. sysclk, or a different button naming), just
// rename the ports below to match your board's master XDC exactly.
// =====================================================================
module nexys_wrapper (
    input  logic        CLK100MHZ,
    input  logic         BTNC,   // start
    input  logic         BTNU,   // rst
    input  logic [15:0]  SW,
    output logic [15:0]  LED
);

    logic [15:0] product_full;
    logic        done_sig;

    booth_mult_top #(.N(8)) u_booth (
        .clk          (CLK100MHZ),
        .rst          (BTNU),
        .start        (BTNC),
        .multiplicand (SW[15:8]),
        .multiplier   (SW[7:0]),
        .product      (product_full),
        .done         (done_sig)
    );

    // Show the product on the LEDs. Bit 15 briefly doubles as a
    // "computation happened" indicator via done is optional -- here
    // we just show the raw 16-bit product value directly.
    assign LED = product_full;

endmodule
