# Part I: FP8 e3m4 representation table

This is the format defined by the Fall 2026 Lab 3 handout, not an assumption
about a different commercial FP8 format. Bits are s[7], E[6:4], F[3:0].
The bias is 3. Normal value = (-1)^s * (1 + F/16) * 2^(E-3).
The stored fraction has four bits; the normal significand has five bits
including the implicit leading 1.

| Category | Sign / exponent / fraction | Hex encoding(s) | Mathematical value or range |
|---|---|---|---|
| Positive zero | 0 / 000 / 0000 | 00 | +0 |
| Negative zero | 1 / 000 / 0000 | 80 | -0 |
| Positive infinity | 0 / 111 / 0000 | 70 | +infinity |
| Negative infinity | 1 / 111 / 0000 | f0 | -infinity |
| NaNs | either / 111 / nonzero | 71..7f, f1..ff | No real numeric value |
| Positive normals | 0 / 001..110 / 0000..1111 | 10..6f | +0.25 through +15.5 (discrete values) |
| Negative normals | 1 / 001..110 / 0000..1111 | 90..ef | -15.5 through -0.25 (discrete values) |
| Positive denormals | 0 / 000 / 0001..1111 | 01..0f | +1/64 through +15/64 = +0.015625 through +0.234375 |
| Negative denormals | 1 / 000 / 0001..1111 | 81..8f | -15/64 through -1/64 = -0.234375 through -0.015625 |

For denormals the implicit leading bit is 0: (-1)^s * (F/16) * 2^(1-3).
They are included in this table because the deliverable explicitly requires
their representations, even though their arithmetic need not be implemented.
There are 192 normal encodings, 30 denormal encodings, 30 NaN encodings,
two zeros and two infinities: 256 encodings total.

## Implemented policies

- Rounding for supported normal results: round to nearest, ties to even (RNE).
- Exponent-zero input encodings are treated as signed zero (DAZ). The fraction
  of an unsupported denormal input is ignored; DAZ itself raises no flag.
- Any exact, nonzero finite result with magnitude below 0.25 is flushed to
  signed zero BEFORE normal-result rounding. It raises underflow and inexact.
  This is an explicit no-denormal policy, not gradual-underflow IEEE arithmetic.
- Overflow after normal-result rounding returns signed infinity and raises
  overflow and inexact. The positive RNE overflow boundary is 15.75.
- Exact opposite-sign cancellation returns +0. -0 + -0 returns -0.
  Multiplication uses the XOR of input signs, including zero results.
- A NaN has E=111 and F!=0. F[3]=1 denotes quiet; F[3]=0 denotes signaling.
  All NaN results are canonical quiet NaN 0x78. Signaling NaN inputs raise
  invalid; quiet NaNs propagate without invalid. Opposite infinities in
  addition and zero times infinity raise invalid and return 0x78.
- Infinity propagation alone raises no exception.

## Exception flags

The five-bit ordering follows the reference adder's documented port:

| Bit | Name | Behavior in these units |
|---:|---|---|
| 4 | Overflow | Finite arithmetic overflows the representable normal range |
| 3 | Underflow | Exact nonzero result is flushed below minimum normal |
| 2 | Divide by zero | Always 0: neither unit performs division |
| 1 | Invalid | Signaling NaN, opposite infinities in ADD, or zero times infinity |
| 0 | Inexact | Rounding discards nonzero bits, or overflow/underflow occurs |

Each flag describes the CURRENT input pair. Flags are combinational, not sticky.
Part II will combine flags at MAC/array level as specified by the handout.
