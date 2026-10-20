`timescale 1ns/1ps
`default_nettype none
// Combinational e3m4 adaptation of the reference FPAddSub pipeline:
// prealign -> align -> signed execution -> normalize -> round -> exceptions.
// Only addition is required. Opposite operand signs perform subtraction.
// Pipeline registers, clk and rst are intentionally removed for Lab 3 Part I.
module fp8_adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] result,
    output logic [4:0] flags
);
    localparam logic [7:0] QUIET_NAN = 8'h78;
    logic a_nan, b_nan, a_snan, b_snan, a_inf, b_inf;
    logic a_zero, b_zero;
    logic [7:0] larger, smaller;
    logic [12:0] large_sig, small_sig, normalized_sig;
    logic [13:0] magnitude_sum;
    logic signed [5:0] normalized_exp;
    logic [7:0] finite_result;
    logic [4:0] finite_flags;
    logic result_sign;
    integer shift_amount, exp_work;

    // Reference Prealign stage: unpack and classify. Exponent-zero operands
    // (including unsupported denormals) are treated as signed zeros (DAZ).
    assign a_nan  = (&a[6:4]) && (|a[3:0]);
    assign b_nan  = (&b[6:4]) && (|b[3:0]);
    assign a_snan = a_nan && !a[3];
    assign b_snan = b_nan && !b[3];
    assign a_inf  = (&a[6:4]) && !(|a[3:0]);
    assign b_inf  = (&b[6:4]) && !(|b[3:0]);
    assign a_zero = !(|a[6:4]);
    assign b_zero = !(|b[6:4]);

    always_comb begin
        // Align stage: choose the larger magnitude and its common exponent.
        larger = (a[6:0] >= b[6:0]) ? a : b;
        smaller = (a[6:0] >= b[6:0]) ? b : a;
        shift_amount = int'({1'b0, larger[6:4]}) -
                       int'({1'b0, smaller[6:4]});
        large_sig = {1'b1, larger[3:0], 8'b0};
        small_sig = {1'b1, smaller[3:0], 8'b0} >> shift_amount;

        // Eight extra alignment bits preserve the complete smaller operand:
        // the largest exponent difference between normal e3m4 values is 5.
        // Execution stage: same signs add; opposite signs subtract magnitudes.
        if (larger[7] == smaller[7])
            magnitude_sum = {1'b0, large_sig} + {1'b0, small_sig};
        else
            magnitude_sum = {1'b0, large_sig} - {1'b0, small_sig};
        result_sign = larger[7];
        exp_work = int'({1'b0, larger[6:4]});

        // Normalize stage: handle carry, or left shift after cancellation.
        normalized_sig = magnitude_sum[12:0];
        if (magnitude_sum[13]) begin
            normalized_sig = magnitude_sum[13:1];
            normalized_sig[0] = normalized_sig[0] | magnitude_sum[0];
            exp_work = exp_work + 1;
        end else begin
            for (int i = 0; i < 12; i = i + 1) begin
                if ((normalized_sig != 0) && !normalized_sig[12]) begin
                    normalized_sig = normalized_sig << 1;
                    exp_work = exp_work - 1;
                end
            end
        end
        normalized_exp = 6'(exp_work);
    end

    fp8_round_pack round_pack (
        .sign(result_sign), .exponent(normalized_exp),
        .significand(normalized_sig), .result(finite_result),
        .flags(finite_flags)
    );

    // Exception stage: do not reuse the reference's incomplete special-value
    // output handling. Quiet NaNs propagate; signaling NaNs raise invalid.
    always_comb begin
        result = finite_result;
        flags = finite_flags;
        if (a_nan || b_nan) begin
            result = QUIET_NAN;
            flags = {3'b0, (a_snan || b_snan), 1'b0};
        end else if (a_inf && b_inf && (a[7] != b[7])) begin
            result = QUIET_NAN;
            flags = 5'b00010; // +infinity + -infinity is invalid.
        end else if (a_inf || b_inf) begin
            result = a_inf ? a : b;
            flags = 5'b0;
        end else if (a_zero && b_zero) begin
            result = {a[7] & b[7], 7'b0}; // Only -0 + -0 produces -0.
            flags = 5'b0;
        end else if (a_zero || b_zero) begin
            result = a_zero ? b : a;
            flags = 5'b0;
        end else if (magnitude_sum == 0) begin
            result = 8'h00; // Exact cancellation is +0 under ties-to-even.
            flags = 5'b0;
        end
    end
endmodule
`default_nettype wire
