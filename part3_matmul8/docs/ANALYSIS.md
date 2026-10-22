# Part III analysis and measured results

## Bandwidth

Peak useful input reads: two A banks x 32 bits + two B banks x 32 bits =
**128 bits/cycle = 16 bytes/cycle**. The all-ones simulation shows all four
streams valid together at core counts 6..9 (450..510 ns).
Peak output writes: two C banks x 32 bits = **64 bits/cycle = 8 bytes/cycle**,
for eight consecutive write edges (870..1010 ns). Internal PE forwarding is
not counted as additional RAM bandwidth; external testbench loading is excluded.
All four input banks have continuous physical read ports, but only the qualified
responses count as matrix operands. Invalid raw responses may contain X;
the unchanged core masks them to zero before the active PE inputs.

At the 20 ns simulation clock (50 MHz), peak read/write bandwidth is
800/400 MB/s. At the 10 ns synthesis target (100 MHz), it is 1.6/0.8 GB/s.
These are peak interface rates, not whole-operation average bandwidth.

## Cycles (actual all-ones FSDB/VCS run)

| Event | Time, ns | Explanation |
|---|---:|---|
| Accepted external start edge | 290 | Configuration sampled; TB prints after NBA at 291 ns |
| Preparation edge | 310 | All tile counters/PEs reset; run asserted after edge |
| First core run edge | 330 | Pre-edge core counter is 0 |
| First top/left operand consumption | 370 | Synchronous RAM response, core count 2 |
| First lower/right operand consumption | 450 | Core count 6; four-bank overlap begins |
| Legacy done pulse observed by monitor | 690 | Core count 18; intentionally ignored |
| Completed accumulators captured into C shift registers | 850 | Core count 26 |
| First committed C column | 870 | Core count 27 |
| Last committed C column | 1010 | Core count 34; eight writes per C bank |
| Wrapper done rises | 1030 | One cycle after last committed write |
| TB observes done | 1040 | Next falling edge, avoiding sampling races |

The compute-and-shift operation consumes **35 core run edges**, counting
the first at 330 ns through the final write at 1010 ns inclusively. There
are 27 edges through capture and eight output-transfer edges. From accepted
host start to final write, the elapsed time is 720 ns = **36 clock periods**,
including wrapper preparation. Done rises after 37 periods from accepted
start. State the convention with any quoted cycle count; they answer
different endpoints. The run sequence prints both 35 and 36 for every case.

## MAC work

64 dot products x 8 terms = **512 useful scalar MAC steps**. There are
**64 physical PE/MAC units** (four tiles x 16). Each MAC includes a multiply
and an add, so 512 MACs correspond to 1024 scalar arithmetic operations.
Zero padding during filling/flushing is not additional useful matrix work.

## Core-only synthesis comparison

| Metric | FP8 4x4 (provided Part II run) | FP8 8x8 (this server run) |
|---|---:|---:|
| Cell area, library units | 33,263.044845 | 124,066.023235 |
| Leaf cells | 11,045 | 40,929 |
| Sequential cells | 955 | 3,522 |
| Worst full-interface setup slack, ns | 4.936644 | 2.114082 |
| Setup-limited period estimate, ns | 5.063356 | 7.885918 |
| Estimated full-interface frequency, MHz | 197.50 | 126.81 |
| Register-to-register slack, ns | 6.0695 (approximately) | 5.837700 |
| Register-to-register frequency estimate, MHz | 254.42 | 240.25 |
| Hold violations | 461 | 1,704 |
| Maximum capacitance violations | 3,657 | 14,669 |

Both runs use Design Compiler V-2023.12-SP5-1, gscl45nm typical,
compile_ultra, 10 ns clock, 0.10 ns clock uncertainty and transition,
1 ns input/output delays, 0.10 ns input transition and 0.01 pF output load.
Neither includes the RAM wrapper, its FSM, memories, or testbench.
8x8 area is about 3.73 times the provided 4x4 area. Area is reported in
library units because the delivered unit reports do not establish area units.

The estimates use T_est = 10 ns - setup slack and f_MHz = 1000/T_est.
They are pre-layout setup estimates under fixed I/O budgets, not a routed
Fmax or measured clock sweep. The 8x8 worst path is pe_reset input to a PE
accumulator register, reflecting reset fanout. The 4x4 worst path is the
final_mat_mul_size input to a C address register. Part II's public tile
locations/final size are unconstrained inputs; the required 8x8 composition
specializes those constants and adds output sequencing. These interfaces
are not identical, so the comparison includes that architectural difference.

Both have positive setup slack and unresolved hold/capacitance violations.
The 8x8 worst reported hold slack is -0.066914 ns. Full timing closure is
not claimed. The mapped 8x8 has zero macro/black-box area; check_design only
reports the expected constant divide-by-zero flag output (no division units).
check_timing reports no unconstrained endpoints, loops or missing input delays;
it warns about a high-fanout net. All raw reports are retained for review.
