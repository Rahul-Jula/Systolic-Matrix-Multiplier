# Part I: waveform deliverables

The handout requires at least one annotated adder waveform and one annotated
multiplier waveform, each showing at least five cases.

The first five directed tests deliberately cover positive normals, negative
normals, zero, finite overflow to infinity, and an invalid operation returning
NaN. Cases 1..5 run at 10..20, 20..30, 30..40, 40..50 and 50..60 ns.
All 22/18 cases are checked by assertions. Later cases exercise underflow,
rounding, infinity propagation and both quiet/signaling NaNs.

## On Apporto

1. Run make sim for VCS tests and VCD dumps, or make fsdb for FSDB dumps.
2. With the installed Verdi PLI directory configured, make fsdb produces
   build/fp8_adder.fsdb and build/fp8_multiplier.fsdb.
3. Run make verdi-adder and make verdi-multiplier.
4. Add the top testbench's case_id, a, b, result, flags, expected_result,
   expected_flags. Set eight-bit data buses to hex and flags to binary.
5. Zoom to 10..60 ns to show the required first five cases clearly.
6. Annotate each interval with its arithmetic, encoded result and flags.
   ADDER_CASES.md and MULTIPLIER_CASES.md give all expected values.
7. Retain screenshots for the final report. Do not include FSDB/VCD, simv,
   csrc or other compiler outputs in the submission ZIP.

## Included figures

figures/fp8_adder_annotated.png and figures/fp8_multiplier_annotated.png are
annotated bus-timing plots rendered from the ACTUAL locally simulated VCD
events for directed cases 1..5. They are not mocked waveform values.
Their SVG versions allow zooming. No propagation delay is inferred from
zero-delay RTL simulation. Use Apporto Verdi screenshots as additional
course-tool evidence after rerunning there.
