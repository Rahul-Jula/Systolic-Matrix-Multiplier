`timescale 1ns/1ps
`default_nettype none
// FP8 e3m4 normalization/rounding/output stage, shared by add and multiply.
// Adapted from the Normalize/Round/Exception stages of the lab's
// fbrosser/DSP48E1-FP references. See docs/REFERENCE_ADAPTATION.md.
// flags[4:0] = {overflow, underflow, divide_by_zero, invalid, inexact}.
module fp8_round_pack (
    input  logic              sign,
    input  logic signed [5:0] exponent,    // Biased normalized exponent.
    input  logic [12:0]       significand,// Hidden 1 at bit 12; 8 rounding bits.
    output logic [7:0]        result,
    output logic [4:0]        flags
);
    logic [5:0] rounded;
    logic increment;
    integer adjusted_exp;

    always_comb begin
        result = {sign, 7'b0};
        flags = 5'b0;
        rounded = 6'b0;
        adjusted_exp = int'($signed(exponent));
        increment = significand[7] &&
                    ((|significand[6:0]) || significand[8]);

        if (significand != 13'b0) begin
            // No subnormal arithmetic: flush any exact nonzero result below
            // the minimum normal magnitude (0.25) to signed zero.
            if (adjusted_exp < 1) begin
                flags = 5'b01001; // Underflow and inexact.
            end else begin
                rounded = {1'b0, significand[12:8]} + {5'b0, increment};
                if (rounded[5]) begin
                    rounded = rounded >> 1;
                    adjusted_exp = adjusted_exp + 1;
                end
                if (adjusted_exp >= 7) begin
                    result = {sign, 3'b111, 4'b0000};
                    flags = 5'b10001; // Overflow to infinity, inexact.
                end else begin
                    result = {sign, 3'(adjusted_exp), rounded[3:0]};
                    flags[0] = |significand[7:0];
                end
            end
        end
    end
endmodule
`default_nettype wire
