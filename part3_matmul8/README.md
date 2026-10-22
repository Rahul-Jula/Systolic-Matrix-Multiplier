# Lab 3 Part III: FP8 8x8 systolic matrix multiplier

Four unchanged Part II `matmul_4x4_systolic` cores form a spatial 8x8 array.
Part I arithmetic and Part II RTL are dependencies, retained unchanged.
`MAT_MUL_SIZE` stays 4. Each tile accumulates eight separately rounded FP8
products. A moves right and B down; the output C chains shift right to left.
Two 32-bit banks store each matrix. Byte zero is the low byte of each word.

The new core ignores the inherited early done pulse, waits for count 26
capture, and enables exactly eight C writes. It generates C addresses itself
because the inherited early done also resets the tile's C address counter.
The new RAM wrapper samples configuration on an idle rising start, clears
all tiles during a preparation clock, then runs until the last C transfer.
Wrapper done is retained until reset or a newly accepted start. PE flags
stay visible at completion and clear before the next run. Host writes are
whole words and are blocked while busy; external C access is read-only.

## Course tools (tcsh)

From the repository root:

```tcsh
source env.cshrc
cd part3_matmul8
make sim
make fsdb
make synth
make verdi
```

`make vectors` regenerates three independently calculated datasets.
`make sim` checks all ones, varied signed operands with nonzero addresses
and strides, a finite overflow case, then clean after overflow. The last
three starts exercise automatic per-job reset without external reset.
The sequence must check 256 output bytes (64 each), eight writes per C
bank, all input streams, cross-tile lane-0 transfers, flags and retained
completion. `+CASE=1/2/3` selects one case for waveform viewing.

`make synth` synthesizes ONLY `matmul_8x8`, excluding wrapper/RAM/testbench.
Constraints match Part II. Raw reports go in `reports/fp8`; synthesis
databases go in ignored `build/dc_fp8`. `make source` packages this directory
and its unchanged Part I/II dependencies, excluding generated tool products.

## Verified server results

VCS W-2024.09-SP2-3 completed the four-operation sequence: 256/256 C bytes
matched, with flags 00000, 00000, 10001, 00000. Each run also checked input
RAM responses, inter-tile forwarding, addresses and exactly eight writes
per C bank. From first core run edge through final write there are 35
inclusive edges; accepted start to final write is 36 elapsed clock periods.

Design Compiler V-2023.12-SP5-1 mapped the arithmetic core: cell area
124066.023235 library units, setup slack 2.114082 ns at a 10 ns target.
Residual hold and capacitance violations remain. See `docs/ANALYSIS.md`
for comparison assumptions and limitations, and `reports/fp8/` for raw data.

`docs/viewers/ones_*.tcl` reproduces the four screenshot panels. For example,
from this directory after `make fsdb`:

```tcsh
nWave -ssf build/ones.fsdb -play docs/viewers/ones_outputs.tcl
```

Time values in these viewer scripts are ps. Widen the name column if needed.
`docs/MATRICES.md` gives complete input matrices and independent expectations.
`docs/VERIFICATION.md` records the checks and evidence. Partner contributions
are deliberately blank in the report, at the user's request.
