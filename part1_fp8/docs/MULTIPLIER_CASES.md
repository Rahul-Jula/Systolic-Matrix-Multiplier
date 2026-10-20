# FP8 multiplier waveform cases

| Case | a | b | Result | Flags | Meaning |
|---:|---|---|---|---|---|
| 1 | 0x38 | 0x40 | 0x48 | 00000 | positive normals: 1.5 * 2 = 3 |
| 2 | 0xb8 | 0x40 | 0xc8 | 00000 | negative times positive: -1.5 * 2 = -3 |
| 3 | 0x00 | 0x40 | 0x00 | 00000 | multiply by zero: +0 * 2 = +0 |
| 4 | 0x6f | 0x40 | 0x70 | 10001 | overflow: 15.5 * 2 -> +infinity |
| 5 | 0x00 | 0x70 | 0x78 | 00010 | invalid: zero * infinity -> quiet NaN |
| 6 | 0x31 | 0x31 | 0x32 | 00001 | inexact normal: 1.0625 squared -> 1.125 |
| 7 | 0x10 | 0x10 | 0x00 | 01001 | underflow: 0.25 squared -> +0 |
| 8 | 0x10 | 0x30 | 0x10 | 00000 | minimum normal preserved: 0.25 * 1 |
| 9 | 0x80 | 0x40 | 0x80 | 00000 | signed zero: -0 * 2 = -0 |
| 10 | 0xf0 | 0xb0 | 0x70 | 00000 | infinity sign: -infinity * -1 = +infinity |
| 11 | 0x78 | 0x30 | 0x78 | 00000 | quiet NaN propagation |
| 12 | 0x71 | 0x30 | 0x78 | 00010 | signaling NaN: invalid |
| 13 | 0x01 | 0x40 | 0x00 | 00000 | unsupported denormal input treated as zero |
| 14 | 0x3f | 0x31 | 0x40 | 00001 | normalization carry: 1.9375 * 1.0625 -> 2 |
| 15 | 0x6f | 0x31 | 0x70 | 10001 | overflow after multiplication |
| 16 | 0x90 | 0x10 | 0x80 | 01001 | negative underflow -> -0 |
| 17 | 0x70 | 0x00 | 0x78 | 00010 | invalid operation in reversed operand order |
| 18 | 0xb8 | 0xc0 | 0x48 | 00000 | two negative normals: -1.5 * -2 = 3 |
