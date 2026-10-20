# Lab 3 Part I - Combinational FP8 arithmetic

Implements the Fall 2026 handout's e3m4 format: sign 1, exponent 3,
fraction 4, bias 3, implicit normal leading 1. The provided baseline remains
unchanged under ../baseline/. No Part II/III/IV RTL is implemented here.

## Files

- rtl/fp8_adder.sv: combinational signed floating-point addition.
- rtl/fp8_multiplier.sv: combinational floating-point multiplication.
- rtl/fp8_round_pack.sv: shared RNE/packing/overflow/underflow logic.
- tb/tb_fp8_adder.sv: 22 directed self-checking waveform cases.
- tb/tb_fp8_multiplier.sv: 18 directed self-checking waveform cases.
- tb/tb_fp8_exhaustive.sv: all 65,536 input pairs for each DUT.
- tb/directed_cases.json: readable list of directed stimulus/annotations.
- tools/generate_vectors.py: independent exact-rational reference model.
- tools/package_submission.py: submission ZIP excluding build products.
- docs/FP8_FORMAT.md: required representation/range table, including denormals.
- docs/DESIGN.md: design and rounding description.
- docs/REFERENCE_ADAPTATION.md: source lineage and conversion details.
- docs/VERIFICATION.md: checks actually performed and their limits.
- docs/WAVEFORMS.md and docs/*_CASES.md: waveform/report guidance.
- docs/figures/: annotated figures from actual RTL simulation.

## Apporto commands

Run from ~/ADDV/LAB3/part1_fp8 with your course VCS environment loaded:

    make sim
    make exhaustive

No Python packages are required; exhaustive vector generation uses Python 3
standard-library Fraction for exact arithmetic. VCS sim is 40 directed tests.
exhaustive compares BOTH result and all five flags for 131,072 operations.

For FSDB and Verdi, first ensure VERDI_HOME points at the installed Verdi:

    make fsdb
    make verdi-adder
    make verdi-multiplier

The FSDB flow targets the installed Verdi 2024.09: VCS uses VERDI_HOME and
-debug_access+all to load its integration automatically. Do not add legacy
-P novas.tab/pli.a options; this Verdi version rejects them. The target checks
that both nonempty FSDB files were produced. The default make sim writes VCD
dumps instead.

For native Icarus Verilog (2012 SystemVerilog):

    make sim-iverilog
    make exhaustive-iverilog

## Output / submission

All generated files stay in build/. Run make package to create
build/lab3_part1_fp8.zip with sources, tests, Makefile, README, tools and docs.
Waveform databases and simulator/compiler outputs are excluded.

Part I does not request synthesis. The final combined lab report still needs
the group contribution statement and demo confirmation specified by the
handout; do not invent either.

## Numerical contract

See docs/FP8_FORMAT.md. Normal rounding is nearest/ties-to-even. Unsupported
denormal inputs are signed zero; nonzero results below minimum normal are
flushed before rounding. Overflow produces signed infinity. Canonical quiet
NaN is 0x78. flags = {overflow, underflow, divide_by_zero, invalid, inexact}.
Arithmetic units have no internal pipeline registers, clock or reset.
