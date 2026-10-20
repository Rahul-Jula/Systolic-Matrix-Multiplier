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

User-provided Apporto terminal screenshots show VCS W-2024.09-SP2-3 passing
18 directed multiplier cases and all 65,536 ADD plus 65,536 MUL exhaustive
result-and-flag checks. These are user-run results, not an agent-run remote
session. The supplied screenshots do not independently show the adder's
directed summary.

The initial FSDB target passed arithmetic checks but failed to dump because
Verdi 2024.09 rejects the legacy -P novas.tab integration. The corrected target
uses VERDI_HOME with -debug_access+all, fresh compilation directories, and
nonempty-file checks. Its FSDB output still needs confirmation on Apporto.
Retain the terminal results and Verdi screenshots. No synthesis, timing closure
or physical delay has been verified here; Part I does not require synthesis.

Generated VCD/FSDB, simulator executables, vector files and raw logs stay in
ignored build/. They are not source-code deliverables.
