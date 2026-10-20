# Part I: design description

## Reference conversion

The starting algorithms are the handout-linked FPAddSub and FPMult designs
by Fredrik Brosser. Their prepare/align/execute/normalize/round/exception
stages are reduced to e3m4 widths and connected without pipeline registers.
The two DUT ports are a[7:0], b[7:0], result[7:0], flags[4:0].
There is no clock, reset, enable, latency counter or sequential element inside
either arithmetic unit. The testbench waits 1 ns for event simulation to settle;
this is a testbench delay, not a claimed physical propagation delay.
In a later MAC, inputs may be launched and results captured within one cycle,
subject to synthesis timing. No Part I synthesis frequency is claimed.

## Adder

1. Unpack sign, three-bit exponent, and four-bit fraction; classify specials.
2. Compare magnitudes, choose the common exponent, and restore the hidden 1.
3. Right-shift the smaller significand by the exponent difference. Five
   significand bits plus eight extra bits preserve all information because
   supported input exponent differences are at most five.
4. Add magnitudes when signs agree; otherwise subtract smaller from larger
   and take the larger operand's sign.
5. Normalize a carry by shifting right and increasing exponent, or normalize
   cancellation by bounded left shifts and decreasing exponent.
6. Round and pack through fp8_round_pack; apply special-result priority.

## Multiplier

1. Unpack/classify operands and restore each five-bit normal significand.
2. XOR signs, add biased exponents and subtract bias 3.
3. Replace the FP32 DSP-oriented split product with a full 5x5 unsigned
   significand product. Its exact output is ten bits; this is internal only.
4. Select product bit 8 or 9 as the hidden bit and adjust the exponent.
5. Round and pack to an EIGHT-bit FP8 result; apply special-result priority.
   No external integer-product truncation is needed.

## Rounding and exceptions

fp8_round_pack shares the reference's ties-to-even decision:
increment = first_discarded_bit AND (any_later_discarded_bit OR retained_LSB).
It handles rounding carry, signed exponent range checks, normal packing,
overflow to infinity and the documented flush-to-zero underflow policy.
All combinational blocks initialize every temporary/output and use blocking
assignments. logic, always_comb, typed ports and sized casts provide the
SystemVerilog syntax required by the handout.

The full encoding table, signed-zero/NaN rules, and flag definitions are in
FP8_FORMAT.md. Upstream issues corrected during conversion are documented in
REFERENCE_ADAPTATION.md; blindly resizing the source would not meet the lab.
