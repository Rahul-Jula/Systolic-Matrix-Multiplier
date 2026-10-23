# Part IV — APB interface (report chapter draft)

The accelerator now exposes a 16-bit APB slave for software configuration,
start and status. The existing FP8 arithmetic, four 4×4 tiles, 8×8 core and
six RAM banks are retained. APB replaces the former host start/configuration
controller; dedicated 64-bit matrix-loading and RAM-readback ports remain.

The controller accepts a write-one START only while idle, clears previous
status, resets the arithmetic for one preparation clock, then holds the
core running through all eight result writes. Software done follows the
last committed write. Completed flags and done remain readable until reset
or another job. Busy configuration/start writes are ignored.

The complete register table and access semantics are in REGISTER_MAP.md.
The interface uses ten-bit byte addresses, always-ready transfers, and a
combinational read mux. Testbench read/write tasks are adapted from the
provided baseline tasks and sample reads at the completing rising edge.

Verification uses the team's three independent matrix datasets: all ones,
varied signed values at nonzero bases/nonunit strides, and a finite overflow
case. It also includes clean restart after overflow and reset during a job.
All 64 C entries are checked through real RAM reads for each completed job.

**Results pending:** local compilation/elaboration has passed; VCS simulation,
exception-case FSDB and annotated waveform figures must be added after actual
execution. Expected overflow is C[7][7]=0x70 with FLAGS=0x0011, not a measured
result yet. Figure requirements and capture procedure are in WAVEFORM_CAPTURE.md.

For the final combined report, include actual partner contributions and demo
schedule confirmation supplied by the group. This draft does not claim that
the lab has been submitted or that the whole-lab report is complete.
