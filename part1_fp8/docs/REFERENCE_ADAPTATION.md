# Conversion from the handout's FP32 reference code

Author of upstream reference: Fredrik Brosser.
Repository: https://github.com/fbrosser/DSP48E1-FP
Revision inspected: 3bee71d52cc6ca4c421a43731d903420ed930a9d

The 18 unmodified source files and original blob IDs are archived under
../../references/DSP48E1-FP/. Those FP32 files are not compiled with our FP8
units. No alternate arithmetic implementation repository was substituted.

## Stage mapping

| Handout-linked FP32 stage | FP8 adaptation |
|---|---|
| FPAddSub top pipe_1..pipe_9 | Removed all pipeline state and clk/rst ports; combinational wires/always_comb connect stage calculations |
| FPAddSub_PrealignModule | fp8_adder input classification, sign/exponent/fraction extraction |
| FPAddSub_AlignModule / AlignShift1 / AlignShift2 | Magnitude ordering and one smaller-operand alignment shift; 5-bit significands and 8 exact extension bits |
| FPAddSub_ExecutionModule | Same effective sign-controlled magnitude addition/subtraction, scaled to e3m4 |
| FPAddSub_NormalizeModule / NormalizeShift1 / NormalizeShift2 | Bounded leading-bit search/left shifts or carry right shift, with signed exponent adjustment |
| FPAddSub_RoundModule | fp8_round_pack ties-to-even increment, rounding carry and exponent adjustment |
| FPAddSub_ExceptionModule | Explicit special-value result mux and named five-flag ordering |
| FPMult top pipe_0..pipe_4 | Removed all pipeline registers and clock/reset ports |
| FPMult_PrepModule | Classify operands; replace 24-bit significands with five-bit significands |
| FPMult_ExecuteModule / ESExecuteModule | Exact 5x5 multiply, sign XOR, exponent addition with bias 3; no FP32 DSP split multiplication is needed |
| FPMult_NormalizeModule | Select the product leading bit and adjust exponent |
| FPMult_RoundModule / ExceptionModule | Shared RNE packer plus complete output special-value handling |

The FP8 conversion collapses small barrel-shift submodules into bounded
combinational expressions. It preserves the reference algorithmic stages;
it is not a literal search-and-replace of FP32 bit slices.

## Necessary corrections found in upstream

The handout says the required cases must remain correct after conversion.
The linked source cannot safely be reused without reviewing its details:

- FPMult_PrepModule's A NaN test checks exponent bits twice, and its infinity
  tests also use exponent bits where fraction bits are required.
- FPMult_ExceptionModule contains the comment "Add error checking here";
  FPMult_RoundModule forwards an internal input-classification vector as Flags
  instead of producing the final five exception flags used by the adder.
- FPAddSub_AlignShift stages discard bits before its later rounding stages;
  the FP8 adaptation instead retains all bits for supported exponent gaps.
- The reference adder's exception logic includes infinity in overflow/invalid
  decisions. The FP8 version distinguishes propagated infinity from finite
  overflow and invalid operations.

The implemented behavior is specified in FP8_FORMAT.md and checked against
an independent exact-rational enumeration model for every input encoding.
The rounding choice remains round-to-nearest, ties-to-even, as described in
the reference FPAddSub_RoundModule.
