# Required exception-case waveform evidence

Status: capture pending. Run `make fsdb` first. It generates viewer scripts
and `CAPTURE_WINDOWS.md` from actual exception-case log events. Do not use
Part III timestamps. nWave zoom values are ps (1 ns = 1000 ps).

Save raw captures to `docs/verdi_screenshots/`, then create separate
`_annotated.png` copies using hand/digital-pen strokes. Do not redraw signal
values. Each panel needs a readable time ruler, PCLK and full signal names.

| Panel | Script | Required visible evidence and pen marks |
|---|---|---|
| 01_apb_writes | exception_writes.tcl | Six configuration writes and START=1; label SETUP and completed ACCESS edge; identify address/value |
| 02_config_run | exception_config.tcl | Configured bases/strides, short start_pulse and sustained core_run; configuration stable during RUN |
| 03_exception_done | exception_run.tcl | Live overflow/inexact, final C write, write count 8, retained done/flags; distinguish live flags from completion snapshot |
| 04_apb_reads | exception_reads.tcl | PWRITE=0 and completed reads of STATUS 0x00E returning 0x8000 and FLAGS 0x010 returning 0x0011 |

Use extra close-ups when all signal names/values cannot fit legibly. Hex radix
is appropriate for PADDR, PWDATA, PRDATA and packed C data. Mark actual rising
completion edges. For flags, expand bits 4 and 0 if needed. A raw done signal
alone does not demonstrate the required APB status read.

Viewer scripts and databases are preparation aids; neither is a screenshot.
Record the exact FSDB path, simulation case, capture ranges and filenames
when actual captures are completed. Regenerate simulation data after changes.
