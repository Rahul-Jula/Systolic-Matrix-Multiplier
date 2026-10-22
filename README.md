# Systolic Matrix Multiplier - ADDV Lab 3, Fall 2026

The lab handout is the requirements authority.

| Directory | Purpose / state |
|---|---|
| baseline/ | Five untouched instructor baseline/template files |
| part1_fp8/ | Combinational e3m4 arithmetic, tests, documentation and report figures |
| part2_matmul4/ | FP8 4x4 integration, self-checking matrix tests, waveform evidence and synthesis reports |
| part3_matmul8/ | FP8 8x8 core, six-bank wrapper, verification, synthesis and actual Verdi captures |
| part4_apb/ | Reserved for 16-bit APB CSR integration |
| references/DSP48E1-FP/ | Archived handout-linked FP32 arithmetic sources |

Start with part1_fp8/README.md. From Apporto:

    cd ~/ADDV/LAB3
    git pull --ff-only
    cd part1_fp8
    make sim
    make exhaustive

See part1_fp8/docs/VERIFICATION.md for tests actually run and tool limits.
VCS/Verdi rerun instructions are in the Part I README.

Part II: see part2_matmul4/README.md and part2_matmul4/IMPORT_NOTES.md.
Earlier Part II/III handoff: handoffs/LAB3_PART2_WAVES_AND_PART3_AI_HANDOFF.md.

Part III: see part3_matmul8/README.md and part3_matmul8/IMPORT_NOTES.md.
Part IV teammate: see handoffs/LAB3_PART4_COMPLETE_LAB_AI_HANDOFF.md.
