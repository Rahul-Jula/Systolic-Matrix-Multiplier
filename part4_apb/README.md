# Lab 3 Part IV — APB-controlled FP8 8×8 multiplier

The Part III arithmetic, four-tile core, and six RAM banks are reused unchanged.
The new top replaces the host start/configuration FSM with an APB slave and
job controller. See `docs/REGISTER_MAP.md` and `docs/DESIGN.md`.

## Current verification status

Local slang 12.0.0 compilation/elaboration passed with zero errors and warnings
on 2026-10-22. **VCS simulation and Verdi screenshots are still pending.**
The expected PASS strings below are acceptance criteria, not recorded results.

## Course run (tcsh, from the extracted source ZIP root)

```tcsh
source env.cshrc
cd part4_apb
make sim
make fsdb
make verdi
```

`make sim` compiles and runs five complete jobs: ones, varied signed,
overflow, clean after overflow without external reset, and clean after an
aborted job/reset. Expected final line begins:
`PART4 SIMULATION PASS total_checked=320`.
Every completed job checks 64 actual C RAM bytes, eight output writes and
their addresses/data, APB flags and retained done. Any failure calls `$fatal`.

The regression also checks reset defaults, START=0, SETUP-only traffic,
unselected PENABLE, reserved-bit masking, full address decode, odd/unmapped
addresses, read-only writes, back-to-back transfers, busy configuration/start
writes, and blocked host RAM writes. Completion is polled through APB.

`make fsdb` requires the configured `VERDI_HOME`. It builds with `FSDB` defined,
runs `+CASE=1`, `+CASE=2`, `+CASE=3`, then the full sequence. Each individual
run must report `total_checked=64`; the sequence must report 320. Output:
`build/{ones,varied,exception,sequence}.fsdb`. It also creates the four viewer
scripts from **measured timestamps** in `reports/exception_sim.log`.

```tcsh
nWave -ssf build/exception.fsdb -play docs/viewers/exception_writes.tcl
nWave -ssf build/exception.fsdb -play docs/viewers/exception_config.tcl
nWave -ssf build/exception.fsdb -play docs/viewers/exception_run.tcl
nWave -ssf build/exception.fsdb -play docs/viewers/exception_reads.tcl
```

Open one viewer at a time. `docs/WAVEFORM_CAPTURE.md` describes the required
captures and annotations. Viewer scripts are generated only after a passing
exception run. Without `FSDB`, the same cases produce VCD files instead.
Logs are under `reports/`; simulation executables remain under `build/`.

## Compilation and packaging

The Makefile compiles Part I round-pack, adder, multiplier, Part II `matmul.v`,
Part III core and RAM-wrapper file (for the single `part3_ram` definition),
then Part IV control, top and testbench. Top is `tb_part4`. The incomplete
baseline skeleton and reference task file are **not compiled**.

```tcsh
make source
```

Creates `deliverables/Lab3_Part4_Source.zip` and `SHA256SUMS.txt`. The ZIP is
self-contained for Part IV and contains unchanged dependency RTL with its
repository-relative paths. It excludes executables, FSDB/VCD, logs, `.git`,
old ZIPs and simulator working directories. It is not the combined four-part
submission. Extract into an empty folder and repeat `make sim` before delivery.

Reference provenance: `baseline/apb_slave.v`, `baseline/example_tb.v`, the
existing team Parts I–III, and the Arm APB specification linked in the lab.
The matrix vectors are copied unchanged from Part III's rational oracle output.
