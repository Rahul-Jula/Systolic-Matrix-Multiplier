# Part I verification record - 2026-10-20

## Actually executed locally

Simulator: Icarus Verilog, WebAssembly build distributed by
@veriflow/iverilog-wasm 0.1.4, running inside Node.js 24.19.0.
Simulator source revision:
https://github.com/AlexMercer12138/iverilog/tree/75c777c993c2bbc6ffe7f9138f25a76e14db5325
SystemVerilog generation: 2012.

| Test | Result |
|---|---|
| tb_fp8_adder | PASS, 22 directed result-and-flag checks |
| tb_fp8_multiplier | PASS, 18 directed result-and-flag checks |
| tb_fp8_exhaustive ADD | PASS, all 65,536 ordered 8-bit input pairs |
| tb_fp8_exhaustive MUL | PASS, all 65,536 ordered 8-bit input pairs |
| Total exhaustive operations | 131,072, zero mismatches |

The independent oracle uses Python Fraction and nearest-encoding enumeration,
not the RTL alignment/multiplication/normalization implementation. It checks
the documented DAZ/FTZ policy, signed zero, all normal operands, all infinity
sign combinations, signaling/quiet NaNs, overflow, underflow and inexact.
Directed cases include ties that round both down and up.

Actual VCD dumps from the two directed HDL simulations were parsed and
rendered into the annotated report figures. The renderer checks that plotted
inputs match the case list and plotted outputs/flags match expected values.

## Tool messages and limits

Icarus prints nonfatal notices about constant bit selects in always_comb:
it broadens the sensitivity to the complete vector. Compilation and all tests
complete successfully. The source retains SystemVerilog always_comb.

VCS/Verdi commands and optional FSDB PLI integration are supplied for Apporto.
They have NOT been run on the user's live Apporto session in this change.
No claim is made that VCS, FSDB generation, synthesis, timing closure or
physical delay has been independently verified here. Part I does not require
synthesis. Run make sim and make exhaustive on Apporto as the course-tool
confirmation; retain its terminal output and Verdi screenshots.

Generated VCD/FSDB, simulator executables, vector files and raw logs stay in
ignored build/. They are not source-code deliverables.
