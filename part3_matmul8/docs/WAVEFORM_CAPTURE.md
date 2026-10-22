# Actual Verdi capture checklist

Open `verdi -ssf build/ones.fsdb` after `make fsdb`. Top: `/tb_part3`.
Use the all-ones trace for the required Part III events. Use varied trace
for easier visual identification of individual operands across tiles.

| View | Signals (exact TB aliases unless stated) | Evidence |
|---|---|---|
| Input loading | clk, resetn, load_we, load_addr_a, load_addr_b, load_a, load_b, loaded_a[0:7], loaded_b[0:7] | Four actual input RAM banks loaded |
| RAM read/neighbor | clk, internal_run, core_cycle, a_top_valid, a_bottom_valid, b_left_valid, b_right_valid, a_top_read, a_bottom_read, b_left_read, b_right_read, a00_to_01, a10_to_11, b00_to_10, b01_to_11 | Synchronous reads and registered tile propagation |
| Output transfer | clk, start, internal_run, tile_legacy_done, c_write_valid, c_write_addr, c_write_data, c_write_count, done, exception_flags | Eight columns committed before done |
| Output contents | done, final_c[0:7], checked_entries, total_checked | Actual C RAM readback: 64 elements |

`loaded_a`, `loaded_b` snapshot the actual four DUT RAMs after loading.
`final_c` snapshots actual synchronous C host-port responses after done.
Expected arrays are separate and must not be labeled as RAM observations.

Show actual leaf RAM memories if the memory browser is clearer. All bank
names are under `dut`: matrix_A_top, matrix_A_bottom, matrix_B_left,
matrix_B_right, matrix_C_top, matrix_C_bottom; each contains `ram[0:1023]`.

Save raw screenshots with readable names, values and time ruler, then
separate copies with hand/digital-pen arrows and short labels for each of
the handout's events a-e. Keep the original FSDB and viewer signal setup.
Do not substitute generated VCD plots for actual Verdi screenshots.

Signal values are sampled before the writing rising edge. NBA updates may
show the next column immediately after that edge; annotate the correct
pre-edge value. Time ruler is normally ps; logs print ns (multiply by 1000).

Capture status must be recorded alongside the actual images. File/database
existence alone does not establish screenshot or pen-annotation completion.

## Saved and reviewed captures

All four panels were captured from actual course Verdi nWave on 2026-10-21.
Original screenshots and separate digital-pen copies are in `verdi_screenshots/`:

| Stem | Window (ns) | Pen marks and required events |
|---|---|---|
| 02_inputs | 200..330 | A/B brackets identify all 16 actual input RAM snapshots (event d) |
| 03_neighbors | 320..650 | A: valid RAM response; B arrows: next tile operand arrivals, four PE steps later (events a, b) |
| 01_output_writes | 820..1080 | C: last committed C write at 1010 ns; D: done at 1030 ns (event c) |
| 04_results | 1200..1280 | E: eight actual C RAM readback words; arrow: checked_entries=64 (event e) |

Each stem has `_raw.png` and `_annotated.png`. Pen marks were drawn with
mouse/pen gestures on a local canvas displaying the unchanged raw screenshot;
they do not change any trace values. Signals/time intervals are reproduced
by `viewers/ones_*.tcl`. The zero-time cursor accounts for X/zero values in
the narrow cursor-value column; actual values in the displayed time window
are shown on the plotted traces. Unknown raw RAM responses outside valid
read windows are masked by the inherited setup logic.
