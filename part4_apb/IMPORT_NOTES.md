# Part IV import - 2026-10-22

Imported the delivered Part IV RTL, tests, documentation, course logs and
viewer presets from Systolic-Matrix-Multiplier.zip. Simulator executables,
Git metadata, runtime GUI state and duplicate WORKING_BACKUP were omitted.
The supplied FSDB/VCD databases are preserved in Lab3_Part4_Evidence.zip.

The README and VERIFICATION.md contain an older local-only status note.
The subsequently supplied VCS logs now record:
- Sequence: total_checked=320, protocol_checks=70, PASS.
- Individual ones, varied and exception: 64 results each, PASS.
- Exception FLAGS APB read=0011; C column7=7000000000000000.
No licensed simulator was independently rerun during this import.

No actual Part IV screenshot PNGs were present in this delivery; the FSDBs
and signal/viewer presets are present. Capture/report assembly status must
be established by the Part IV author; presets are not screenshot evidence.

Existing Parts I-III RTL and baseline files are unchanged.
