# Server verification

Actual course VCS W-2024.09-SP2-3 runs completed on 2026-10-21. Simulation
clock period is 20 ns. The corrected FSDB run checks four operations:

| Sequence | Case | Address/stride mode | Result comparisons | Flags |
|---|---|---|---:|---|
| 1 | A=B=all FP8 ones | zero bases / unit stride | 64/64 | 00000 |
| 2 | deterministic varied signed operands | A base17 stride3; B base43 stride2; C base101 stride5 | 64/64 | 00000 |
| 3 | finite 8 x 2 overflow in PE[7][7] | zero bases / unit stride | 64/64 | 10001 |
| 4 | all ones after overflow | nonzero bases / nonunit stride | 64/64 | 00000 |

The sequence reports `PART3 SIMULATION PASS total_checked=256`.
Individual +CASE=1/2/3 runs each report 64 checked entries and generate
their own FSDB/VCD. After the initial run, operations restart without
external reset: wrapper preparation clears accumulators and sticky flags.

Each run verifies all 16 A bank words and all 16 B bank words loaded through
the external RAM write ports, all qualified full-word input responses,
32 lane-0 forwarding samples spanning all four tile links, eight exact
64-bit output transfers with correct addresses, every byte from synchronous
C RAM host readback, expected flags, and stable completion without extra
writes. Active controls and C write data are checked for unknowns. Local
per-run and global timeouts terminate a stalled computation.

The oracle is the unchanged Part I exact-rational model. It rounds each
multiply and add separately, in streamed k=0..7 order; it does not use one
host-float matrix multiply with a single final rounding. Full matrices in
decimal and FP8 hex appear in MATRICES.md and matrices.json (seed 320268).

Actual all-ones C bank words are all `60606060`; all C elements are 8.0.
The exceptional case has C[7][7]=`70` (+Inf); the other outputs are zero.
This controlled case verifies bottom-right reachability and exception OR.

A one-line testbench logging correction moved start_cycle sampling after
NBA to remove an active-region race; no DUT logic or expected values changed.
The final logs consistently measure 36 periods from accepted start through
final write, and 35 inclusive core run edges through final write.

Raw evidence: reports/*_sim.log, reports/fp8/*.rpt, and build/*.vcd/*.fsdb.
Source ZIP excludes the simulator/synthesis products; the separate evidence
archive retains the databases and reports. Four actual GUI panels, each with
an original and separate digital-pen copy, were saved and visually reviewed;
see WAVEFORM_CAPTURE.md for filenames and event mapping.
