# Lab 3 - Part II: FP8 4x4 systolic matrix multiplier

## Scope and integration

This directory continues the supplied Part I implementation. Part I RTL is reused unchanged; its exhaustive tests are not rerun. The original integer design and RAM wrapper are unchanged. Parts III and IV are outside this deliverable.

`matmul.v` is a copy of the instructor baseline with only the MAC arithmetic and exception propagation changed. The 16 processing elements instantiate the existing combinational `fp8_multiplier` and `fp8_adder`. The original `a_flop`, `b_flop`, `mult`, and `out` pipeline boundaries remain. Multiply and add round separately; this is not a fused MAC. `NUM_CYCLES_IN_MAC` remains 3.

Each MAC registers multiplier flags alongside its product, then ORs those delayed flags and adder flags into a sticky five-bit register. All 16 MAC flag registers are bitwise-ORed into the core's new `exception_flags` output. Bit order is `{overflow, underflow, divide_by_zero, invalid, inexact}`. Existing reset/PE reset clears the accumulator and flags before every operation. Flags remain valid through completion. The unchanged wrapper does not expose an extra pin; the testbench observes the new core output hierarchically.

FP8 follows the supplied Part I E3M4, bias-3, round-to-nearest-even, DAZ/FTZ implementation. Normal finite magnitudes range from 0.25 to 15.5. `70` is positive infinity and `78` is canonical quiet NaN.

## Inputs and output layout

See `docs/MATRICES.md` for all matrices in decimal and hexadecimal. Seed 32026 selects varied signed clean operands. Case 2 changes A[3][3] to 8 (`60`) and B[3][3] to 2 (`40`). Expected values use the unchanged Part I exact-rational model, with each operation individually rounded.

RAM word k stores A column k, B row k, and C column k. Row/column element 0 is the low byte. The testbench writes both input RAMs through their real external ports and compares all 16 output bytes in C RAM.

## Reproduce on Apporto

From the repository root in a tcsh shell:

```tcsh
source env.cshrc
cd part2_matmul4
make fsdb
make synth-integer synth-fp8
```

`make baseline` optionally runs the instructor integer matrix sample for Part II reference. It is not a Part I arithmetic regression. `make vectors` regenerates expected matrices using Python 3. `make sim` runs the three-operation FP8 sequence and generates VCD without FSDB.

`make fsdb` generates clean, exception, and clean-after-exception sequence runs. `reports/*_sim.log` contains event timestamps and all byte comparisons. `build/*.fsdb` can be opened with `verdi -ssf build/clean.fsdb` or `verdi -ssf build/exception.fsdb`. Add `tb_part2.*` and zoom to the complete simulation. The directly observed aliases include start, core_start, done, exception_flags, c_write_addr/data/enable, pe33 flags, and checked_entries. `final_c0` through `final_c3` are snapshots of actual C RAM taken after comparison, not expected results.

For portable annotated plots, install matplotlib in a local Python environment and run `python tools/plot_waveforms.py` after copying the VCD files to `build/`. The included PNGs are plotted from actual VCS transitions, not illustrative waveforms.

## Observed simulation results

VCS W-2024.09-SP2-3, 20 ns clock. Both individual cases pass all 16 output comparisons; sequence clean -> exception -> clean passes all 48 comparisons and reset checks.

| Event | Time in individual runs |
|---|---:|
| A/B RAM writes (rising edges) | 90, 110, 130, 150 ns |
| External start asserted | 200 ns |
| C words 0, 1, 2, 3 written | 550, 570, 590, 610 ns |
| Done asserted | 590 ns |
| All 16 C RAM entries checked | 640 ns |

The baseline completion protocol asserts done one clock before the final C write. The testbench waits for that write before checking RAM. Write data in a waveform is sampled just before each rising edge, even when it changes immediately after the edge.

Clean flags stay `00000`. In the exception run, combined flags become `00001` at 490 ns, then `10001` at 510 ns and remain set through completion. The PE33 registered product flags show `10001` at 490 ns from 8 x 2 overflowing the maximum finite FP8 value. C[3][3] is `70` (+Inf). C[3][2] rounds 9.75 to 10, contributing inexact. Reset clears the sticky state for the subsequent clean operation.

## Synthesis comparison and interpretation

Both runs synthesize only `matmul_4x4_systolic` with the complete public interface, not the wrapper or RAMs. Both use Design Compiler V-2023.12-SP5-1, gscl45nm typical, `compile_ultra`, a 10 ns target clock, 0.10 ns uncertainty/transition, 1 ns input/output delays, 0.10 ns input transition, and 0.01 pF output load. No case-analysis constants specialize the integer or FP8 core.

See the report for the numeric comparison and `reports/{integer,fp8}/` for raw area, timing, units, QoR, and constraint reports. The frequency estimate is derived from the worst full-interface setup slack: period = 10 ns - slack; frequency = 1000 / period in MHz. It is a pre-layout setup estimate under fixed I/O budgets, not a routed frequency or a clock sweep. Positive setup slack does not mean complete timing closure: the raw reports also record hold and maximum-capacitance violations. They are disclosed in the report; no physical-design closure is claimed.

## Deliverables

- `matmul.v`, `tb/`, `Makefile`, `synth/core.tcl`: Part II implementation and reproducible runs.
- `docs/MATRICES.md`, `docs/matrices.json`, `tools/matrix_cases.py`: inputs and expected outputs.
- `docs/waveforms/*.png`: annotated actual simulation traces for both cases.
- `reports/`: real simulation and core synthesis evidence.
- `output/pdf/Lab3_Part2_Report.pdf`: integration, matrices, waveforms, results and synthesis comparison.

The source ZIP includes the unchanged baseline wrapper/integer core and the required unchanged Part I sources/model so it can be run independently. Generated simulator executables, synthesis databases and large build directories are excluded. The separate evidence ZIP retains the VCD/FSDB files and reports.
