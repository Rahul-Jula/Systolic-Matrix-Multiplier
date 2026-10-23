# Verification record — 2026-10-22

## Completed locally

- Read the live assignment's Part IV requirements and deliverables.
- Compiled/elaborated the complete `tb_part4` hierarchy with slang 12.0.0:
  zero errors and zero warnings.
- Extracted the source ZIP into a separate empty folder and compiled that
  self-contained hierarchy with slang: zero errors and zero warnings.
- Recomputed all 192 expected outputs across the three datasets using the
  existing exact-rational oracle; results/flags matched. Part IV's vector
  file is byte-identical to Part III's. This validates expectations, not RTL
  behavior under simulation.
- Existing Parts I–III source files were retained unchanged.

## Pending course execution

No Part IV VCS simulation PASS or new FSDB has been observed yet.
No Part IV Verdi screenshots or pen annotations have been captured yet.
The Windows Icarus package was blocked by Windows security and was not run;
the block was not bypassed. Slang compilation is not functional simulation.

The implemented regression checks five complete matrix jobs (320 C bytes)
plus reset during an active job. The expected matrix flags in order are
00000, 00000, 10001, 00000, 00000. These are expected values, not measured
results until the course simulation passes.

The exception inputs have A[7][7]=8 and B[7][7]=2, with all other entries zero.
Expected C[7][7] is positive infinity (0x70), all other entries zero. Final
packed column is 0x7000000000000000. The retained FLAGS CSR should read 0x0011.

After running `make sim` and `make fsdb`, retain compile logs, individual
case logs, sequence log and all four FSDBs as evidence. Record actual tool
version/date, final PASS counts, and timestamps. Extract the source ZIP to
an empty folder and run `make sim` there to verify functional self-containment.
Do not substitute a previous Part III log or archived FSDB for these checks.
