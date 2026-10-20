# FP8 adder waveform cases

| Case | a | b | Result | Flags | Meaning |
|---:|---|---|---|---|---|
| 1 | 0x30 | 0x38 | 0x44 | 00000 | positive normals: 1 + 1.5 = 2.5 |
| 2 | 0xb8 | 0xb0 | 0xc4 | 00000 | negative normals: -1.5 + -1 = -2.5 |
| 3 | 0x00 | 0x38 | 0x38 | 00000 | zero identity: +0 + 1.5 = 1.5 |
| 4 | 0x6f | 0x6f | 0x70 | 10001 | overflow: 15.5 + 15.5 -> +infinity |
| 5 | 0x70 | 0xf0 | 0x78 | 00010 | invalid: +infinity + -infinity -> quiet NaN |
| 6 | 0x38 | 0xb0 | 0x20 | 00000 | opposite signs: 1.5 - 1 = 0.5 |
| 7 | 0x30 | 0xb0 | 0x00 | 00000 | exact cancellation: 1 - 1 = +0 |
| 8 | 0x80 | 0x80 | 0x80 | 00000 | signed zeros: -0 + -0 = -0 |
| 9 | 0x00 | 0x80 | 0x00 | 00000 | signed zeros: +0 + -0 = +0 |
| 10 | 0x70 | 0x30 | 0x70 | 00000 | infinity propagation: +infinity + 1 |
| 11 | 0xf0 | 0x30 | 0xf0 | 00000 | infinity propagation: -infinity + 1 |
| 12 | 0x78 | 0x30 | 0x78 | 00000 | quiet NaN propagates without invalid |
| 13 | 0x71 | 0x30 | 0x78 | 00010 | signaling NaN is quieted; invalid |
| 14 | 0x30 | 0x10 | 0x34 | 00000 | different exponents: 1 + 0.25 = 1.25 |
| 15 | 0x30 | 0x01 | 0x30 | 00000 | unsupported denormal input treated as zero |
| 16 | 0x11 | 0x90 | 0x00 | 01001 | underflow: 0.265625 - 0.25 -> +0 |
| 17 | 0x30 | 0x12 | 0x34 | 00001 | round-to-even tie down: 1 + 0.28125 -> 1.25 |
| 18 | 0x31 | 0x12 | 0x36 | 00001 | round-to-even tie up: 1.0625 + 0.28125 -> 1.375 |
| 19 | 0x4f | 0x10 | 0x50 | 00001 | post-normalization tie: 3.875 + 0.25 -> 4 |
| 20 | 0x6f | 0x18 | 0x70 | 10001 | rounding overflow: 15.5 + 0.375 -> +infinity |
| 21 | 0x10 | 0x10 | 0x20 | 00000 | smallest normals: 0.25 + 0.25 = 0.5 |
| 22 | 0xa0 | 0x10 | 0x90 | 00000 | negative result: -0.5 + 0.25 = -0.25 |
