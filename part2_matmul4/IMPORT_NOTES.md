# Part II teammate delivery - imported 2026-10-21

Rahul requested importing his teammate's Part II delivery to the shared repo.
The editable design, tests, scripts, matrices, reports and plotted waveforms
were taken from `Lab3_Part2_Source.zip`. Working text files use LF line endings
for Apporto; no RTL logic or testcase values were changed during import.

Original source/evidence ZIPs and `PART2_STATUS.txt` are preserved unchanged in
`deliverables/`. The PDF in `output/pdf/` is byte-identical to the separately
attached report. All original source manifest SHA-256 entries were validated;
the manifest describes the files INSIDE the original archive, not normalized
working copies. Every overlapping source/evidence archive member matched.

The baseline, Part I arithmetic/model and root environment script supplied
inside the archive match the existing repo after line-ending normalization.
Those existing repo files were left unchanged. `part2_matmul4/.gitkeep` was
replaced by the actual delivery.

Evidence includes actual VCS PASS logs for integer baseline, clean FP8,
exceptional FP8, and clean/exception/clean reset sequence; it also includes
both Design Compiler core runs. This import inspected that evidence but did
not independently rerun licensed VCS/DC. The report discloses residual hold
and maximum-capacitance violations; no full physical timing closure is claimed.

The included PNGs are annotated plots of VCD transitions, not Verdi GUI
screenshots. Capture the requested Verdi screenshots on Apporto next.
`make fsdb` regenerates the databases. Alternatively, extract the original
evidence ZIP in a separate directory to use its existing FSDBs immediately.
Generated build databases are retained in the evidence ZIP, not unpacked
into the tracked working source tree.

The status note's pending upload refers to the teammate's previous Apporto
workflow. It is historical, not a command to overwrite Rahul's current repo.
Use the shared GitHub checkout and `git pull --ff-only` instead.

See `handoffs/LAB3_PART2_WAVES_AND_PART3_AI_HANDOFF.md` for the next phase.
