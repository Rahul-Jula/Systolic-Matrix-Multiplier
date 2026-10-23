# APB register map

PCLK clocks the APB slave, core and RAM. PRESETn is active low. PADDR is a
10-bit **byte offset**; PWDATA and PRDATA are 16 bits. PREADY is always 1.
Writes complete only at a rising edge with PSEL, PENABLE and PWRITE all high.
The combinational read mux is valid before the completing read edge.

| Byte offset | Register | Access | Implemented fields | Reset |
|---|---|---|---|---|
| 0x000 | START | command/read | bit 0: one-clock accepted-start pulse | 0 |
| 0x002 | ADDRESS_MAT_A | RW idle | bits 9:0: A RAM word base | 0 |
| 0x004 | ADDRESS_MAT_B | RW idle | bits 9:0: B RAM word base | 0 |
| 0x006 | ADDRESS_MAT_C | RW idle | bits 9:0: C RAM word base | 0 |
| 0x008 | ADDRESS_STRIDE_A | RW idle | bits 7:0: A word stride | 1 |
| 0x00A | ADDRESS_STRIDE_B | RW idle | bits 7:0: B word stride | 1 |
| 0x00C | ADDRESS_STRIDE_C | RW idle | bits 7:0: C word stride | 1 |
| 0x00E | STATUS | RO | bit 15: done; bit 14: busy | 0 |
| 0x010 | FLAGS | RO | bits 4:0: retained exception flags | 0 |

All other bits read zero. Configuration writes mask unimplemented upper bits.
Odd or unmapped addresses read zero and ignore writes; all ten address bits
are decoded. Writes to STATUS and FLAGS are ignored. There is no PSLVERR pin.

START=1 while idle clears done and flags, emits one start pulse, and enters
PREPARE. START=0 is inert. During busy, all start/configuration writes are
ignored, with no queued job. CSRs therefore remain stable for the active job.
Later START reads normally return zero; software does not need to clear START.

Done asserts only after the core reports completion following the eighth C
write. Flags are captured at that completion. Both remain until reset or a
new accepted START; reads do not clear them. Poll `(status & 16'h8000) != 0`.
Busy reads as 0x4000 during work; completed status reads as 0x8000.

FLAGS[4:0] = {overflow, underflow, divide_by_zero, invalid, inexact}.
The exception case expects 0x0011: overflow and inexact. Divide-by-zero is
always zero because no division operation is present.

RAM addresses are **word addresses**, unrelated to APB byte offsets. Each
matrix word is 64 bits split across two banks. Software should choose bases
and strides satisfying base + 7*stride <= 1023; address-overflow checking is
not provided. Reset aborts a job and restores CSR defaults without clearing
RAM. Output RAM from an aborted job must not be treated as a completed result.
