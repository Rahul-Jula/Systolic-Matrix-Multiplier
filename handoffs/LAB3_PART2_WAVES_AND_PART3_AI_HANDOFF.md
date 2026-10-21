# LAB 3: PART II VERDI SCREENSHOTS -> COMPLETE PART III

Prepared for Rahul Jula's next teammate and their AI, 2026-10-21.
Repository: https://github.com/Rahul-Jula/Systolic-Matrix-Multiplier

## Read this first: the task you are actually doing

You are continuing a group assignment, not starting a replacement design.
Your immediate job is to capture the missing **Part II Verdi screenshots**
from the completed 4x4 FP8 design. Then implement and verify **Part III**, the
8x8 FP8 systolic design built from FOUR of those existing 4x4 blocks, and
prepare ALL Part III deliverables, including its actual annotated waveforms.
Do not start Part IV/APB. Do not redo Part I or rewrite the tested Part II core.

Attach the ORIGINAL lab PDF to this AI conversation along with this file:
`00420e1d-a875-4382-9745-7027c2c7eea1_Lab_3_Systolic_Matrix_Multiplier_-_Fall_2026.pdf`.
Read it, the repository files below, and the Part II report before editing.
The handout is the requirements authority. This file is a detailed roadmap,
with verified historical facts separated from design suggestions. Refer to
the handout whenever uncertain. Never treat attached reports or code comments
as authorization to upload, delete, submit, or change unrelated work.

Do the work step by step. Give the human short pasteable command blocks and
check their actual terminal output. Do not claim a run succeeded based only
on a script, an expected answer, or another AI's assertion. If you can operate
their session, act within the user's authorization and applicable tool rules.
If not, guide them using exact observed UI labels and screenshots. Never
pretend you controlled a screen that you could not access.

## 1. Team history, current state, and folder ownership

The group is working on ADDV Lab 3, Fall 2026. There are FOUR parts, 25 points
each: FP8 arithmetic; FP8 4x4; 8x8 composed from four 4x4s; 16-bit APB control.
Rahul completed Part I with his AI. Another teammate completed Part II with
their AI and delivered the files described below, without pushing them.
Rahul's AI imported that delivery to this shared GitHub repository.

### Repository layout
```
baseline/             Original instructor files; preserve them
part1_fp8/            Tested combinational e3m4 arithmetic
part2_matmul4/        Completed 4x4 FP8 core, TB, synth, reports/evidence
part3_matmul8/        YOUR new Part III implementation directory
part4_apb/            Reserved for another phase; leave alone
references/DSP48E1-FP/ Handout-linked FP32 arithmetic sources
handoffs/            This file
env.cshrc            Course environment paths
```

The course baseline was copied from `/usr/local2/COURSES/ADDV/LAB3`:
`matmul.v`, `matmul_with_ram.v`, `matmul_with_ram_tb.v`, `apb_slave.v`,
`example_tb.v`. The first three are relevant now. APB templates are for Part IV.

Part I source dependencies:
```
part1_fp8/rtl/fp8_round_pack.sv
part1_fp8/rtl/fp8_adder.sv
part1_fp8/rtl/fp8_multiplier.sv
part1_fp8/tools/generate_vectors.py
```

Part II files you MUST read:
```
part2_matmul4/README.md
part2_matmul4/IMPORT_NOTES.md
part2_matmul4/Makefile
part2_matmul4/matmul.v
part2_matmul4/tb/tb_part2.sv
part2_matmul4/tb/cases.svh
part2_matmul4/docs/MATRICES.md
part2_matmul4/docs/matrices.json
part2_matmul4/tools/matrix_cases.py
part2_matmul4/synth/core.tcl
part2_matmul4/output/pdf/Lab3_Part2_Report.pdf
baseline/matmul_with_ram.v
```

### What is already verified, and what is pending

- Part I: 22 directed adder and 18 directed multiplier cases passed locally;
  exhaustive result-and-all-flag checks passed for all 65,536 ordered pairs
  per operation, 131,072 total. Rahul's Apporto VCS exhaustive run also passed.
- Part I FSDB generation works. Rahul captured the adder view; the multiplier
  signals were arranged. Report table/annotations/final packaging are group
  report tasks, not a reason to rewrite arithmetic now.
- Part II supplied VCS logs show the original integer test passing; clean FP8
  passing 16/16 C bytes with flags00000; exceptional FP8 passing 16/16 with
  flags10001; and clean/exception/clean sequence passing48/48 with reset
  clearing sticky flags. We inspected these logs, not independently reran
  the teammate's licensed tools during import.
- Both actual Part II Design Compiler core runs and text reports are included.
  They have positive setup slack but residual hold/capacitance violations.
  Do not call this full timing closure.
- Part II includes plotted, annotated PNG waveforms and a 7-page report.
  The missing item requested by Rahul is ACTUAL VERDI GUI SCREENSHOTS.
- Existing FSDB/VCD files are in the preserved evidence archive, so you may
  open them immediately or regenerate them with the existing Makefile.
- Part III has not been implemented or verified at handoff time.

The imported source/evidence archives passed ZIP integrity checks, every
original source SHA256 manifest entry matched, overlapping archive members
were identical, and the PDF matched the separately supplied PDF exactly.
Part I/baseline/environment copies inside the archive matched the existing
repo after line-ending normalization and were NOT replaced. Part II working
text has LF endings for Linux; original archives remain byte-for-byte intact.

## 2. Get the checkout safely - exact startup steps

Rahul's server path is `~/ADDV/LAB3`, account `a25775_asu`; the previous
teammate's logs use a different account. YOUR account/home may differ.
Do not blindly copy somebody else's `/home/username` paths.

If you already have the shared repo:
```
cd ~/ADDV/LAB3
git status
git remote -v
git fetch origin
git pull --ff-only
```
Only pull on a clean, appropriate branch. If there are local modifications,
inspect and preserve them; do not reset/delete them. If the folder is not a
checkout, clone into a new dedicated directory, leaving existing files safe:
```
mkdir -p ~/ADDV
cd ~/ADDV
git clone https://github.com/Rahul-Jula/Systolic-Matrix-Multiplier.git LAB3_shared
cd LAB3_shared
```
Accept Rahul's collaborator invitation before expecting push permission.
Authenticate with YOUR credentials. Never ask Rahul to share his token, print
credentials, put a token in a remote URL, or commit credential/config files.

Check that the import exists:
```
ls part2_matmul4/matmul.v part2_matmul4/tb/tb_part2.sv
ls part2_matmul4/deliverables
ls handoffs/LAB3_PART2_WAVES_AND_PART3_AI_HANDOFF.md
```
Create a branch for YOUR Part III work:
```
git switch -c part3-fp8-matmul8
```
If that exact branch already exists, inspect it before switching; do not
recreate/reset it. Coordinate with Rahul before merging. Do not force-push.

### Load the course environment

The environment is tcsh/csh syntax, not Bash syntax:
```
tcsh
cd ~/ADDV/LAB3
source env.cshrc
which vcs
which verdi
which dc_shell
echo $VERDI_HOME
echo $PDK_DIR
```
Use YOUR checkout path instead of LAB3 if different. Starting tcsh creates a
new shell but keeps your current directory; you may source the script there.
If already in tcsh, you need not start another nested shell.

Known working installation paths:
```
VCS_HOME   /usr/local2/synopsys/vcs_2024/vcs/W-2024.09-SP2-3
VERDI_HOME /usr/local2/synopsys/verdi_2024.09/verdi_2024
DC bin     /usr/local2/synopsys/syn_2023.12-SP51/bin
PDK_DIR    /usr/local2/cadence/NCSU/SRC/FreePDK45
cell DB    $PDK_DIR/osu_soc/lib/files/gscl45nm.db
```
Use the existing institutional license environment. Do not alter OS security,
license services, or global server settings. `vcs: Command not found` means
PATH/environment needs loading; it is not an RTL problem.

## 3. PHASE A - capture the completed Part II waveforms FIRST

### Option A: regenerate from source (preferred reproducibility check)

From the repo root after loading env:
```
cd part2_matmul4
make fsdb
ls -lh build/clean.fsdb build/exception.fsdb build/sequence.fsdb
```
`make fsdb` compiles tb_part2 and runs +CASE=1, +CASE=2, then the sequence.
Verify the terminal/logs, not just file existence:
```
tail -n 20 reports/clean_sim.log
tail -n 20 reports/exception_sim.log
tail -n 20 reports/sequence_sim.log
```
Expect PART2 SIMULATION PASS, no fatal mismatches, 16 checked entries per
individual run, and the clean/exception/clean sequence. The sequence's
`checked_entries` resets each operation, so its waveform shows16 at the end
of each case, not a running48 counter. The logs show all48 comparisons.

### Option B: open the delivered databases without rerunning VCS

The tracked evidence archive is:
`part2_matmul4/deliverables/Lab3_Part2_Evidence.zip`.
It contains `Lab3_Part2/part2_matmul4/build/*.fsdb` and VCDs plus reports.
From part2_matmul4, extract into an isolated ignored build subdirectory:
```
mkdir -p build/provided_evidence
unzip -n deliverables/Lab3_Part2_Evidence.zip -d build/provided_evidence
verdi -ssf build/provided_evidence/Lab3_Part2/part2_matmul4/build/clean.fsdb &
```
`unzip -n` preserves any existing extracted files. Do not execute the old
pending-upload command in PART2_STATUS.txt: that note describes a previous
teammate session and is not needed after this GitHub import.

### Launch clean and exceptional viewers

After Option A, open the clean DB:
```
verdi -ssf build/clean.fsdb &
```
Then capture clean views before opening the second DB:
```
verdi -ssf build/exception.fsdb &
```
The `&` backgrounds the GUI in tcsh. There is NO `make verdi-clean` target
in the delivered Makefile. Do not invent existing targets. The simple
`verdi -ssf` command is enough for waveform viewing. If source navigation is
desired, pass the same RTL list/`+incdir+tb` used by the actual Makefile.

### Signals: exact names already present in tb_part2

Use the waveform Add/Get Signals control (blue waveform-plus icon), choose
scope `/tb_part2`, and add signals from that testbench. Prefer this scope,
not deeply nested guessed hierarchy. These aliases directly observe real DUT
signals; final_c words are actual RAM snapshots, not expected-value arrays.

**View A: load/start overview**
```
testcase_id
clk
resetn
pe_resetn
load_addr[9:0]
load_we[3:0]
load_a[31:0]
load_b[31:0]
start
core_start
done
exception_flags[4:0]
```
If input RAM contents are needed directly, expand `dut.matrix_A.ram` and
`dut.matrix_B.ram` and show words0..3. `$fsdbDumpMDA()` is in the TB, but GUI
memory display may require the memory browser. The load-port buses plus
RAM readback assertions/logs are also evidence of real writes. Do not label
`a_words`/`b_words` expected TB arrays as actual RAM contents.

**View B: results/flags/writeback**
```
clk
start
core_start
done
exception_flags[4:0]
pe33_product_flags[4:0]
pe33_flags[4:0]
pe33_add_flags[4:0]          optional additional detail
c_write_enable[3:0]
c_write_addr[9:0]
c_write_data[31:0]
final_c0[31:0]
final_c1[31:0]
final_c2[31:0]
final_c3[31:0]
checked_entries
```
`a_stream[31:0]`, `b_stream[31:0]`, `core_cycle[7:0]` are available for an
additional execution view if useful. Don't crowd one screenshot with signals
that make all labels unreadable. Widen the name column so names are not cut.

Radix: data and final C words HEX; flags BINARY (five bits); address/counts/
case ID unsigned decimal; clk/resets/start/done digital. Enable leading zeros
if available. `1_0001` is Verdi grouping for10001, not a different flag value.

### Exact Part II time windows and expected observations

These times apply to the INDIVIDUAL clean.fsdb and exception.fsdb runs,
not the combined sequence. Simulation clock period20ns. VCD/FSDB timescale
is1ps, so if ruler units are ps, multiply each ns value by1000.

| Screenshot | Window in ns | Window in ps |
|---|---:|---:|
| Complete operation | 0..720 | 0..720000 |
| RAM loading + start | 60..260 | 60000..260000 |
| Flag/output detail | 430..720 | 430000..720000 |

Use View -> Zoom -> Zoom Window; enter start/end appropriate to displayed
units. If needed, fit the whole trace first, then set the window. Never reuse
Part I's10..60ns window: that is a different testbench.

Events for BOTH individual cases:
- TB drives A/B words at80,100,120,140ns; actual rising-edge RAM writes occur
  at90,110,130,150ns. load_we=f. Reset remains asserted during loading.
- External start asserted200ns, then pulsed low. `core_start` is controller-
  generated and differs from external start; show the actual transition.
- C write edges550,570,590,610ns, addresses0,1,2,3, write enable=f.
- done asserts590ns. FINAL C WRITE IS610ns, ONE CLOCK AFTER DONE.
- TB waits, compares all16 bytes and captures actual RAM snapshots at640ns.
- After640ns, checked_entries=16. Prior-to-reset Xs are not computation
  failures; do not crop out genuine bad Xs after reset to hide problems.

**Clean case expected C RAM words (hex)**
```
final_c0 = 38b4a0a0
final_c1 = 54b4b800
final_c2 = 46a0b03c
final_c3 = 34a82810
exception_flags = 00000 throughout
```

**Exceptional case expected C RAM words (hex)**
```
final_c0 = c0b4a0a0
final_c1 = 6fb4b800
final_c2 = 64a0b03c
final_c3 = 70b03090
```
Combined flags become00001 at490ns, then10001 at510ns and stay set.
pe33_product_flags=10001 during490..510ns: A[3][3]=8 (`60`) multiplied
by B[3][3]=2 (`40`) overflows FP8 max15.5, yielding +Inf (`70`). The sticky
MAC flags capture the delayed product flags. C[3][2] also rounds9.75 to10,
contributing inexact. C[3][3] is final_c3[31:24]=70.

Waveform writes sample c_write_data immediately BEFORE the rising edge;
nonblocking updates can change the visible bus just AFTER that same edge.
Do not annotate a post-edge next-word value as the word just written.

RAM packing: A wordk = columnk, B wordk = rowk, C wordk = columnk.
Element0 is the least significant byte. All decimal/hex matrices are in
docs/MATRICES.md, not reconstructed from guesses.

### Save the actual screenshots, don't just say they are ready

Capture at least loading/start and output/flags views for each case; use an
overview as well if useful. Suggested new filenames:
```
part2_matmul4/docs/verdi_screenshots/clean_load_start.png
part2_matmul4/docs/verdi_screenshots/clean_results.png
part2_matmul4/docs/verdi_screenshots/exception_load_start.png
part2_matmul4/docs/verdi_screenshots/exception_results.png
```
Use the actual desktop screenshot/snipping facility and save real image
files. Crop to the waveform panel but preserve names, time ruler, all relevant
rows, and a caption identifying the DB/case. Retain originals before annotating.
Annotate input writes, start, done, final write and checks; for exception also
annotate the overflow product and retained10001. Link actual screenshots
from a short capture README and hand them to Rahul for the combined report.
Keep existing plotted PNGs/report unchanged unless asked to replace/update
them. They are plotted VCD evidence, not screenshots of Verdi.

If screenshots cannot be captured through your tools, guide the HUMAN to
capture them and verify the saved files. Mark this item pending until actual
files exist. Never fabricate screenshots or change signal values.

## 4. Technical contract inherited from Parts I and II

FP8 is e3m4, sign1/exponent3/fraction4, bias3. Normal implicit leading1,
E=1..6; magnitude0.25..15.5. `30`=1, `40`=2, `50`=4, `60`=8;
`00`=+0, `80`=-0, `70`=+Inf, `f0`=-Inf, canonical qNaN=`78`.
Denormal inputs are signed zero (DAZ). Nonzero exact results below0.25
flush to signed zero before rounding (FTZ) with underflow+inexact.
Rounding is nearest/ties-to-even. Overflow returns signed infinity + OF/NX.
Flag order `{overflow,underflow,divide_by_zero,invalid,inexact}`.

Part I interfaces, confirm actual source:
```
fp8_multiplier(.a(a8), .b(b8), .result(result8), .flags(flags5))
fp8_adder     (.a(a8), .b(b8), .result(result8), .flags(flags5))
```
No clock/reset inside either unit. MAC is not fused: multiply and add round
SEPARATELY. All Part III expectations must match this contract.

Part II kept original registered MAC timing:
operand registers -> product register -> accumulator register.
Multiplier flags are registered alongside product; sticky MAC flags OR
previous flags, registered product_flags and current add_flags. Reset or PE
reset clears accumulator/flags. Sixteen MAC vectors OR to the core's new
`exception_flags[4:0]`. The Part II wrapper is unchanged; TB sees the core
flags hierarchically through `dut.u_matmul_4x4.exception_flags`.

The Part II matmul.v contains all six modules:
matmul_4x4_systolic, output_logic, systolic_data_setup,
systolic_pe_matrix, processing_element, seq_mac.
The ORIGINAL baseline matmul.v contains same-named integer modules. NEVER
compile the integer baseline and FP8 Part II matmul.v into one build: duplicate
module definitions/macros will collide. For Part III include Part II's core
ONCE, plus the three Part I arithmetic sources, your new8x8 core and wrapper.

## 5. PHASE B - exact Part III assignment requirements

Read Part III Tasks and Deliverables in the original PDF now. Checklist:
- Use SystemVerilog syntax.
- Build8x8 by instantiating/connect FOUR existing4x4 FP8 cores.
- Create a new core file, suggested `matmul_8x8.sv`.
- Do not modify Part II matmul.v. MAT_MUL_SIZE MUST REMAIN4.
- Set final_mat_mul_size, a_loc, b_loc correctly per tile.
- Connect a_data_out -> neighboring a_data_in; b_data_out -> neighboring
  b_data_in. Correct output C shift chaining is also necessary.
- Some tile a_addr/b_addr/c_addr outputs are unused. Tie all tiles' base
  addresses to the SAME corresponding values; same for each address stride.
- Tie validity masks to default/all-enabled values (4'b1111).
- Make a NEW Part III version of matmul_with_ram: instantiate8x8 core and
  TWO RAM BANKS PER MATRIX (two A, two B, two C = six total RAMs).
- Make a new version of the RAM testbench; initialize8x8 data, simulate at
  least TWO different A/B sets. All-ones is explicitly suggested as a first test.
- Synthesize ONLY the8x8 arithmetic core, not wrapper/control/memories.

Part III deliverables, ALL required:
1. Microarchitecture diagram of the four4x4 blocks, data connections and RAMs.
2. Actual waveform screenshots for at least ONE testcase showing:
   a. RAM data read into a matmul;
   b. matmul data moving into its neighboring matmul;
   c. matmul result written to RAM;
   d. input matrices in input RAMs;
   e. output matrix in output RAMs after computation finishes.
   IMPORTANT: handout explicitly says annotate BY HAND or STYLUS/DIGITAL PEN
   for Part III. Typed plot captions alone are not this requested annotation.
3. Table comparing area/frequency of FP8 4x4 vs FP8 8x8 cores.
4. Answers: peak read bandwidth; peak write bandwidth; total cycles to
   compute AND shift out result; number of MACs evaluated in8x8 multiply.
5. Source ZIP: design, TB, Makefiles if used, README (group packaging later).

Do not mistake Part II's one erroneous "8x8" task heading for an already
completed8x8. Existing core is4x4; YOUR work creates the8x8 composition.

## 6. Derive the tile wiring from the actual core, not the comments alone

Read Part II matmul.v in full. Important observation: some baseline comments
around a_loc/b_loc contradict the implemented muxes. The code does:
```
a inputs = (b_loc == 0) ? local A memory/setup : a_data_in;
b inputs = (a_loc == 0) ? local B memory/setup : b_data_in;
```
Thus use a_loc as TILE ROW and b_loc as TILE COLUMN:
```
                    top edge B banks
                 B_left        B_right
                    |             |
 A_top --> T00 (0,0) ----A----> T01 (0,1)
                    | B           | B
 A_bottom->T10 (1,0) ----A----> T11 (1,1)
```
Coordinates above are (a_loc,b_loc), not global PE coordinates.
All four final_mat_mul_size ports =8'd8. a_loc/b_loc are0 or1, NOT0 or4:
the existing setup logic shifts the location by LOG2_MAT_MUL_SIZE=2.

Connection table to verify against source:
| Tile | a_loc | b_loc | Effective A origin | Effective B origin |
|---|---:|---:|---|---|
| T00 upper-left | 0 | 0 | top A bank | left B bank |
| T01 upper-right | 0 | 1 | T00.a_data_out | right B bank |
| T10 lower-left | 1 | 0 | bottom A bank | T00.b_data_out |
| T11 lower-right | 1 | 1 | T10.a_data_out | T01.b_data_out |

Forwarded buses are32 bits each, four FP8 lanes. Preserve lane ordering:
the provided a_data_out packs local rows0..3 low-to-high; b_data_out packs
local columns0..3 low-to-high. Use named ports, no positional port guesses.
Tie truly unused boundary inputs to explicit zero. Do not tie used
neighbor-forwarding inputs to zero. Do not insert extra delay registers unless
the existing source timing proves necessary; it already registers/skews data.

Input memory addresses: a_mem setup starts based on a_loc*4; b_mem setup
starts based on b_loc*4. Therefore different bank address streams need not
change on identical cycles. Use left-edge tile A addresses for each A bank
and top-edge tile B addresses for each B bank. Do NOT wire multiple output
drivers onto one address net. List unused tile address outputs explicitly.

### C result extraction is NOT arithmetic partial-sum forwarding

Each PE's accumulator already computes its full8-term dot product through
streaming. C chaining serializes columns; do not add neighboring tile outputs
together as if this were four sequential block matrix multiplications.

output_logic captures four local column words, then shifts them through four
register positions and receives c_data_in at the tail. For a natural scheme:
- Feed T01.c_data_out -> T00.c_data_in (top-half rows).
- Feed T11.c_data_out -> T10.c_data_in (bottom-half rows).
- Right-edge c_data_in tied0.
- Write top C bank from T00.c_data_out, bottom C bank from T10.c_data_out.
This produces local left columns then forwarded right columns IF timing is
aligned; prove it with actual waveforms and all64 output comparisons. Do not
write memory from both ends of the same chain and duplicate columns.

### CRITICAL existing-core completion trap - inspect before copying the FSM

The unchanged core currently hardcodes:
`cycles_for_matmul = 8'd14`, then done threshold=14+NUM_CYCLES_IN_MAC=17.
But result latch uses:
`clk_cnt == (final_mat_mul_size*4 - final_mat_mul_size - 1 + 3)`.
For final size8, that expression is26, later than the legacy done pulse.
The old4x4 RAM wrapper drops start_mat_mul on done. Copying that behavior
into8x8 would reset core counters/output logic BEFORE valid8x8 capture.

You must solve global completion/control IN THE NEW8x8 CORE/WRAPPER while
leaving Part II matmul.v unchanged, as the handout requests. Keep internal
start/run active long enough for the actual capture and all8 column writes;
derive global done from valid completed output transfers / documented cycle
schedule. Do not AND the four legacy done pulses and call that8x8 done.
Do not end simulation on an early done that precedes the last write.

The output_logic c_data_available may remain high until start resets; gate
writes to the intended eight columns per bank so extra shifted zeros do not
overwrite memory. Count genuine valid transfers and assert completion after
the final committed memory write. Define the precise edge convention and
whether global done is a pulse or a retained status; test it explicitly.
The legacy early done branch may reset output registers BEFORE capture26,
which is distinct from the later valid capture; simulate rather than assume
that branch alone proves impossibility. Do not change the core just to skip
understanding its schedule. If evidence proves another core defect prevents
the handout architecture, show that evidence and request course clarification
before violating a stated constraint.

### Six RAMs, expected bank layout

Keep each provided RAM32 bits wide (four FP8 values), with its synchronous
read latency. Suggested mapping, confirm with controller/addresses:
- A_top[k] = {A[3][k],A[2][k],A[1][k],A[0][k]}, k=0..7.
- A_bottom[k] = {A[7][k],A[6][k],A[5][k],A[4][k]}.
- B_left[k] = {B[k][3],B[k][2],B[k][1],B[k][0]}.
- B_right[k] = {B[k][7],B[k][6],B[k][5],B[k][4]}.
- C_top[k] = {C[3][k],C[2][k],C[1][k],C[0][k]}.
- C_bottom[k] = {C[7][k],C[6][k],C[5][k],C[4][k]}.
Use byte0 in bits7:0; explicitly document endianness. External load/read
ports can be widened/split in YOUR new wrapper with clear bank naming; do
not change4x4 macros globally to make RAM buses8-wide by accident.

The baseline RAM's write enables behave as whole-word enables (`if (|we)`),
not independent byte masking. Use full-word writes consistently; if adding
byte-enable behavior, justify/document the wrapper/RAM change and test it.
Avoid multiple unguarded drivers, same-address dual-port write collisions,
uninitialized control inputs, and unintended RAM reads of uninitialized words.

Combine all four core exception_flags vectors with BITWISE OR. Preserve
category bits, reset all tiles coherently before each run, and keep sticky
flags visible through global completion for future APB integration.

## 7. PHASE C - implementation files and build targets

Use a clean structure such as:
```
part3_matmul8/
  rtl/matmul_8x8.sv
  rtl/matmul_with_ram_8x8.sv
  tb/tb_part3.sv
  tb/cases.svh
  tools/matrix_cases.py
  synth/core.tcl
  Makefile
  README.md
  .gitignore
  docs/ARCHITECTURE.md
  docs/MATRICES.md
  docs/VERIFICATION.md
  docs/WAVEFORM_CAPTURE.md
  docs/ANALYSIS.md
  docs/figures/
  docs/verdi_screenshots/
  reports/
  build/                     ignored
```
These Part III filenames/targets are a proposed layout, NOT files that
already exist. Actually create and test them before telling the human to run.
Keep one definition of RAM: if a new wrapper defines it, do not also compile
baseline/matmul_with_ram.v unless separated/renamed to avoid duplicate tops.

New Makefile should offer real, documented targets for two-case simulation,
FSDB generation, opening the appropriate viewer, vector generation, core
synthesis, and source packaging. Relative dependencies should refer to
Part I arithmetic and Part II matmul.v. Use separate output directories from
Part II so a stale simv or dump cannot masquerade as new evidence.

Modern VCS/Verdi flags used successfully:
`-full64 -sverilog -timescale=1ns/1ps -debug_access+all -kdb`.
Add correct include directories and explicit top. FSDB requires VERDI_HOME
loaded BEFORE compile. Do NOT add legacy `-P novas.tab pli.a`: Verdi2024.09
rejected that in Part I even when arithmetic tests passed. Use modern auto
integration and nonempty-file checks after each run. Dump memories using
`$fsdbDumpMDA()` if needed; expose direct RAM readback aliases for easier GUI
viewing without relabeling expected arrays as actual state.

If VCS shows an ASLR re-execution information message, that alone isn't an
error. If Verdi falls back from Elite to Apex but opens, view the waves.
Actual missing tools/licenses are blockers to report, not an excuse to invent
passing output. You can finish code/docs while arranging a real course run.

## 8. PHASE D - self-check both8x8 tests and timing

### First test: all ones

Load all64 A and64 B elements as FP8 ONE=`8'h30`, NOT integer01.
Each C element should be8, FP8=`8'h60`; all64 entries must match and
combined flags should stay00000. This tests streaming across tile boundaries,
eight products per PE, and complete result extraction. A4-term answer4
(`50`) would expose an incorrect tile/loop configuration.

### Second test: distinct values that detect mapping errors

Use a deterministic varied case with different values across rows/columns,
including quadrants, so transposes/bank swaps/missingright tiles fail checks.
An identity-only test may be useful additionally but is weak as the only
second case. Log encoded and decoded A/B/C and the random seed if used.
A controlled exceptional testcase is a useful additional test for future APB,
but Part III itself requires TWO different sets, not explicitly one flagged.
Avoid unintended UF/OF/inexact in a claimed clean case: inexact IS a flag.

Use the exact Part I oracle or independently verified equivalent:
```
for i in 0..7:
  for j in 0..7:
    acc = FP8(+0)
    flags = 0
    for k in the actual streamed order:
      product, mf = fp8_mul(A[i][k], B[k][j])
      acc, af = fp8_add(acc, product)
      flags |= mf | af
    C[i][j] = acc
```
Do not use host-float matrix multiply with one final rounding; these are
separate rounded FP8 operations. Match the actual k order; FP8 addition is
not generally associative. Inspect Part II matrix_cases.py to reuse its import
of the Part I model. Do not assume its current fixed4 loops handle8 already.

Assertions/checks must include:
- all A/B RAM words really loaded into BOTH banks;
- no unknown active control/address/write data after reset;
- correct streaming into top/left edge and across both tile boundaries;
- exactly8 committed C writes per output bank, intended addresses/strides;
- global done after the final committed C transfer, no premature stop;
- all64 C elements checked against independent expected values for EACH run;
- correct combined flags, clean reset between operations;
- repeated start/reset behavior and finite timeout.
Record start edge, RAM read edges, neighbor-transfer examples, capture edge,
first/last C writes and done. Log both simulation time AND clock counts so
bandwidth/cycle answers are auditable. At a posedge, sample after NBA updates
when checking newly written memory (e.g. #1 or next negedge), not a race.

Do not change expected values to match a failing DUT. Diagnose whether a
failure is numerical, packing, address, skew, schedule, or extraction. Check
intermediate PE accumulators only to locate the bug, not as a replacement
for validating real output RAM contents.

## 9. PHASE E - Part III Verdi capture and pen annotations

Only after simulation checks pass, open the actual Part III FSDB. Read the
NEW testbench to identify its real top/hierarchy; do not paste tb_part2 paths
into an unrelated module. Create easy aliases in the testbench for:
```
testcase_id, clk, resets, external_start, internal_run, global_done
tile00/01/10/11 legacy_done and core_cycle (diagnostic)
combined exception_flags and per-tile flags
A_top/bottom load/write addresses, data, enables
B_left/right load/write addresses, data, enables
actual A/B RAM read data and actual edge tile inputs
T00.a_data_out and T01.a_data_in
T10.a_data_out and T11.a_data_in
T00.b_data_out and T10.b_data_in
T01.b_data_out and T11.b_data_in
C top/bottom write address, data, enables
C write counters
actual final C RAM snapshots / RAM browser entries
checked_entries and independent expected values if useful
```
Adapt alias spellings to your source; list exact paths in WAVEFORM_CAPTURE.md.

Capture multiple legible panels rather than an unreadable list of128 elements:
1. Input-load view with both A banks, both B banks, load words/addresses and
   actual RAM contents or verified snapshots.
2. RAM-to-array read view: synchronous RAM read response and edge tile input,
   with one specific word/lane identified.
3. Neighbor-transfer view: a selected A value travels left->right and a B
   value top->bottom. Include clk and a time interval showing actual changes.
   If connected wires are identical at the boundary, explain that boundary
   connection versus the registered propagation through the source4x4 tile.
4. Result-write view showing BOTH C banks, addresses/enables/data, final
   write and global done with clear edge ordering.
5. Finished-output view proving all64 actual C values, possibly two memory
   tables/snapshots plus checked_entries=64. All-ones results should be60.

Use measured time windows from the NEW log; Part II's550..610ns output times
do not automatically apply. Put unit labels on every captured ruler/caption.
Save raw screenshots and a separate annotated copy, plus viewer settings.

The handout specifically requests hand/stylus/digital-pen annotations for
Part III. Have the human use Paint/Snipping Tool/OneNote or another available
pen tool to draw arrows/circles and handwritten short labels for events a-e.
If the AI can operate a pen/canvas through permitted tools, it may assist;
otherwise give the human exact coordinates/events and wait for actual saved
annotation files. Typed text-only plot annotations are supplemental, not a
reason to silently ignore the wording. Do not claim this deliverable finished
until annotated images actually exist and are checked for readability.

Use a save checklist: filenames, testcase, time window, displayed signals,
what each arrow proves, numerical value/lane, and origin FSDB. This makes
the images usable in Rahul's combined report and the5-minute demonstration.

## 10. PHASE F - core-only synthesis and honest comparison

Part II baseline measurements (imported raw reports, not freshly rerun here):
| Metric | Integer4x4 | FP8 4x4 |
|---|---:|---:|
| Cell area, library units | 19110.834 | 33263.045 |
| Worst full-interface setup slack, ns | 5.092169 | 4.936644 |
| Estimated setup-limited period, ns | 4.907831 | 5.063356 |
| Estimated full-interface MHz | 203.76 | 197.50 |
| Register-to-register estimated MHz | 268.88 | 254.42 |

The Part III table compares **FP8 4x4 vs FP8 8x8**, NOT integer4x4 vs8x8.
Use Part II `synth/core.tcl` as the reference for matching constraints:
gscl45nm typical; target10ns; uncertainty0.10ns; clock transition0.10ns;
input/output delay1ns; input transition0.10ns; output load0.01pF; compile_ultra.
Check raw units/report paths. Do not automatically label area um^2 without
confirming library area units. Both comparisons are pre-layout estimates.

Create a NEW synthesis script/top for your8x8 core and include Part I+Part II
dependencies; exclude all RAMs and wrapper/FSM. Check link/check_design,
timing/QoR/all constraints at sufficient precision, and preserve raw reports.
Do not synthesize a top full of black boxes. Do not include BOTH duplicate
integer and FP8 cores. Do not include testbench/model in synthesis sources.

Be careful about comparable public interfaces. Part II measured the full
4x4 public configuration ports without case-analysis constants; a naturally
composed8x8 hardcodes tile locations/final size as required. State this
specialization and interface difference, or add a clearly separate matched
4x4 wrapper measurement if appropriate. Never silently replace the provided
4x4 number with an unmatched specialization or claim area exactly4x.

Part II frequency column is an estimate: T_est=10ns - full-interface setup
slack; MHz=1000/T_est under FIXED I/O/uncertainty settings, not a routed Fmax
or actual clock sweep. Worst full-interface paths were configuration-input
to output address register. Report register-only timing separately when
useful, and compare like with like. For8x8 the worst path/type may differ:
inspect it before deriving any period. Do not invert arrival time alone and
ignore setup, uncertainty, skew, or I/O budgets.

Part II still has hold violations (integer556, FP8461, worst about-0.064ns)
and max-capacitance violations (integer1294, FP83657). Those do not vanish
because setup slack is MET. Report equivalent8x8 limitations accurately;
never hide them by deleting constraints or calling rounding noise harmless.
The task is an honest mapped-core comparison; do not claim physical closure.

## 11. PHASE G - diagram, bandwidth, cycles, useful MAC count

### Diagram
Show all four named4x4 tiles/coordinates/final size8, two A banks, two B banks,
two C banks,32-bit A/B neighbor buses, direction of horizontal A and vertical
B flow, C right->left shift chains, global clock/reset/run/done and flags OR.
Label addresses/strides and which tile owns each external memory address.
Diagram must match actual RTL, not an abandoned architecture.

### Bandwidth: derive from actual bank activity and state assumptions
For the proposed six32-bit-bank design, the natural peak simultaneous input
read interface is2 A banks x32 bits +2 B banks x32 bits =128 bits/cycle
(16 bytes/cycle), when all four input banks are active together.
The natural output write interface is2 C banks x32 bits =64 bits/cycle
(8 bytes/cycle), when both write together. Verify these peaks from your
schedule, rather than count every PE-internal operand transfer as a RAM read.
At frequency f, multiply bytes/cycle by f cycles/s for B/s. State whether
reporting peak or average and exclude/include testbench load traffic explicitly.
The simulator clock may be20ns/50MHz; keep this distinct from synthesis target
100MHz and any timing-derived estimate. Do not mix units.

### Cycles
Measure and show the edge convention from accepted start/internal first run
to final committed output write. Include compute pipeline fill and output
shift; optionally separate phase counts. Global done should follow your
documented completion definition. Do not quote17 from legacy4x4 done or use
a generic3N-2 formula without reconciling the actual pipeline/RAM/shift edges.
Handout asks total cycles to calculate product AND shift results out.

### MACs
Useful8x8 matrix multiplication has8*8*8=512 scalar multiply-accumulate
steps (64 dot products, each8 terms). There are64 physical PEs/MAC units,
not512 physical MACs. Extra zero-padding operations during pipeline flush
are not additional useful matrix-product MACs; if discussing executed padded
hardware activity, count and label it separately. A MAC means multiply+add,
not a count of each as two MACs.

## 12. Reports, packaging, collaboration, and completion gate

Create a Part III report/section that includes implementation/control timing,
microarchitecture diagram, both testcase matrices and actual results,
verification summaries, required pen-annotated waveform screenshots, synthesis
table/assumptions/limitations, and all four numerical analysis answers.
Do not invent partner contributions. The complete group report needs a
truthful contribution summary (20-point penalty if absent) and demo booking
confirmation when the course publishes scheduling. PDF currently saysTBD;
do not invent an appointment or publish a link on your own.

Final source packaging is planned at the end by Rahul. Still ensure scripts
are reproducible and packages are self-contained: include unchanged Part I
and Part II dependencies if Makefile references them, with proper paths.
Do not submit csrc/, simv*, *.daidir, *.ddc, FSDB/VCD/compiler products in the
SOURCE ZIP. Evidence databases can be kept separately, like Part II.
Useful text reports and screenshots belong in report/evidence deliverables.

Keep new Part III outputs under part3_matmul8. Preserve Part I, Part II RTL,
baseline originals, and their measured reports. Add Part II screenshots in
their designated docs subfolder. Before committing review exact paths:
```
git status --short
git diff --stat
git diff -- part1_fp8 part2_matmul4/matmul.v baseline
```
The last diff should be empty unless a separately authorized correction is
needed. Do not blanket-stage ignored simulation outputs or credentials.
Commit selected Part III files and Part II screenshots/capture guide, then:
```
git add part3_matmul8 part2_matmul4/docs/verdi_screenshots
git commit -m "Complete Part III 8x8 FP8 array and capture Part II waves"
git push -u origin part3-fp8-matmul8
```
Adjust paths only to files actually created. Do not push a false "complete"
commit if synthesis/annotations remain pending. Give Rahul branch/commit
or PR link and the exact reproducible commands; coordinate merge first.

### Definition of done - verify each item before saying complete
- Part II clean/exception REAL Verdi screenshot files saved and reviewed.
- Four4x4 FP8 instances, MAT_MUL_SIZE4 unchanged, Part II matmul.v unchanged.
- Correct locations and A/B neighbor connections; C shift chains proven.
- Six RAMs; correct8x8 packing, addresses and byte lanes.
- New global run/done handles the hardcoded legacy done trap correctly.
- At least two8x8 sets pass ALL64 C RAM element comparisons each.
- Reset/restart/flag behavior and finite timeout tested.
- Real FSDBs generated; required Part III screenshot events a-e captured.
- Actual handwritten/digital-pen annotations completed and readable.
- Core-only8x8 DC run completed; raw area/timing/constraints available.
- FP84x4 vs FP88x8 table honest, conditions and remaining violations stated.
- Diagram and bandwidth/cycle/MAC answers agree with RTL and measured traces.
- README lists actual tool setup/targets, expected results and report paths.
- Source dependencies complete and no forbidden generated files in source ZIP.
- Changes committed/pushed safely; Rahul gets exact files and status.

If any item is blocked by tools/license/access or missing human annotation,
say precisely which item remains and finish everything else possible. Do not
claim a missing screenshot exists because a waveform database exists.

## First reply/work sequence for the receiving AI

1. Confirm you read the PDF, this file, Part II README/Makefile/TB/core and
   baseline wrapper. Inventory actual repository state and tool access.
2. Get the checkout/env ready; regenerate or extract Part II FSDBs.
3. Help the human capture/save clean and exception Verdi views using the
   exact signal lists, timestamps and expected values above.
4. Explain the4x4 legacy done trap and your8x8 control plan BEFORE coding.
5. Implement ONLY new Part III files; keep tested dependencies intact.
6. Run self-checking all-ones and varied8x8 tests, diagnose failures honestly.
7. Capture real Part III waveforms and finish required pen annotations.
8. Run core-only synthesis, complete diagram/analysis/report/README.
9. Review diff, commit/push the branch, and hand Rahul an evidence checklist.

This roadmap is intended to carry you from the missing Part II GUI evidence
through all Part III deliverables. Follow the original handout whenever a
choice or doubt arises; do not replace verification with confident prose.
