# Handout FP32 reference snapshots

Source: https://github.com/fbrosser/DSP48E1-FP

Reference revision: 3bee71d52cc6ca4c421a43731d903420ed930a9d

Unmodified reference files are preserved under src/FPMult/ and src/FP_AddSub/.
They are for source lineage and review; they are NOT part of the FP8 build.
Original author headers are retained. Part I adaptation notes are at
../../part1_fp8/docs/REFERENCE_ADAPTATION.md.

| File | Original Git blob SHA |
|---|---|
| src/FPMult/FPMult.v | 4395bcbf32c8f18387214090e7686db70267c602 |
| src/FPMult/FPMult_ESExecuteModule.v | 1745dfd2f5eb6c5984c6c3c810ad96a18ee7b4c5 |
| src/FPMult/FPMult_ExceptionModule.v | c2af7399e57a8269ffb2b76197ceaf51d285584d |
| src/FPMult/FPMult_ExecuteModule.v | 0a7cbb2561c6f00cc130d11edee63ca44552bf02 |
| src/FPMult/FPMult_NormalizeModule.v | b55479b156196c69eeeac9e64b925bd65e9218bf |
| src/FPMult/FPMult_PrepModule.v | d81707522d00b40f65664c8a05e231d117ba23a3 |
| src/FPMult/FPMult_RoundModule.v | 424b8c62ef0eee56d493c2ddccbce9f8fee89296 |
| src/FP_AddSub/FPAddSub.v | 2991300d8efd8f3f5c06ce08d67a9e11870161a7 |
| src/FP_AddSub/FPAddSub_AlignModule.v | ffb95984b42c61056d87a2a23a2b4a0b44e3516f |
| src/FP_AddSub/FPAddSub_AlignShift1.v | 4758c38fce75c91e9e9d47fa6d63169730cd1193 |
| src/FP_AddSub/FPAddSub_AlignShift2.v | c2c98c82654d62aa1f3cd16b67d568ecf6821c4e |
| src/FP_AddSub/FPAddSub_ExceptionModule.v | a5b429ae6e024c5d620590600bd1fce052fa8fd6 |
| src/FP_AddSub/FPAddSub_ExecutionModule.v | 298a63b951fc48fc77f8f3b5b642874a4a460cde |
| src/FP_AddSub/FPAddSub_NormalizeModule.v | b758ddebe9ef118a1f345873d5ac73c7bab76d7f |
| src/FP_AddSub/FPAddSub_NormalizeShift1.v | aa28a0d94bee012006fc260ee10701f5b9ef25cb |
| src/FP_AddSub/FPAddSub_NormalizeShift2.v | fa052c47f4bc5e3e2bbf4085cc749c213a769350 |
| src/FP_AddSub/FPAddSub_PrealignModule.v | 12f7a8596e248f21faefc91bfc11380103974b2a |
| src/FP_AddSub/FPAddSub_RoundModule.v | cff6debdb4f7b78f5453b3965f7df02fd66e3bf7 |

