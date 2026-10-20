`timescale 1ns/1ps
`default_nettype none
// Combinational e3m4 adaptation of reference FPMult:
// prepare -> significand multiply / sign and exponent -> normalize -> round.
// The FP32 DSP split product becomes one exact 5x5 product for e3m4.
module fp8_multiplier (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] result,
    output logic [4:0] flags
);
    localparam logic [7:0] QUIET_NAN = 8'h78;
    logic a_nan, b_nan, a_snan, b_snan, a_inf, b_inf;
    logic a_zero, b_zero, product_sign;
    logic [4:0] sig_a, sig_b;
    logic [9:0] product;
    logic [12:0] normalized_sig;
    logic signed [5:0] normalized_exp;
    logic [7:0] finite_result;
    logic [4:0] finite_flags;
    integer exp_work;

    // Prepare / exception classification. Subnormal inputs are DAZ.
    assign a_nan  = (&a[6:4]) && (|a[3:0]);
    assign b_nan  = (&b[6:4]) && (|b[3:0]);
    assign a_snan = a_nan && !a[3];
    assign b_snan = b_nan && !b[3];
    assign a_inf  = (&a[6:4]) && !(|a[3:0]);
    assign b_inf  = (&b[6:4]) && !(|b[3:0]);
    assign a_zero = !(|a[6:4]);
    assign b_zero = !(|b[6:4]);
    assign product_sign = a[7] ^ b[7];
    assign sig_a = {1'b1, a[3:0]};
    assign sig_b = {1'b1, b[3:0]};
    assign product = sig_a * sig_b;

    always_comb begin
        // Execute / normalize: product has 8 fractional bits. Select hidden
        // bit 8 or 9, compensate the exponent, retain all discarded bits.
        exp_work = int'({1'b0, a[6:4]}) +
                   int'({1'b0, b[6:4]}) - 3;
        if (product[9]) begin
            normalized_sig = {product, 3'b0};
            exp_work = exp_work + 1;
        end else begin
            normalized_sig = {product[8:0], 4'b0};
        end
        normalized_exp = 6'(exp_work);
    end

    fp8_round_pack round_pack (
        .sign(product_sign), .exponent(normalized_exp),
        .significand(normalized_sig), .result(finite_result),
        .flags(finite_flags)
    );

    always_comb begin
        result = finite_result;
        flags = finite_flags;
        if (a_nan || b_nan) begin
            result = QUIET_NAN;
            flags = {3'b0, (a_snan || b_snan), 1'b0};
        end else if ((a_inf && b_zero) || (b_inf && a_zero)) begin
            result = QUIET_NAN;
            flags = 5'b00010; // Zero times infinity is invalid.
        end else if (a_inf || b_inf) begin
            result = {product_sign, 3'b111, 4'b0};
            flags = 5'b0;
        end else if (a_zero || b_zero) begin
            result = {product_sign, 7'b0};
            flags = 5'b0;
        end
    end
endmodule
`default_nettype wire
