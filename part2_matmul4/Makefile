SHELL := /bin/bash
VCS ?= vcs
PYTHON ?= python3
FP := ../part1_fp8/rtl/fp8_round_pack.sv ../part1_fp8/rtl/fp8_adder.sv ../part1_fp8/rtl/fp8_multiplier.sv
FLAGS := -full64 -sverilog -timescale=1ns/1ps -debug_access+all -kdb +incdir+tb
WRAPPER := ../baseline/matmul_with_ram.v
.PHONY: all vectors baseline sim fsdb synth-integer synth-fp8
all: baseline fsdb
build:
	mkdir -p build reports
vectors:
	$(PYTHON) tools/matrix_cases.py
baseline: | build
	$(VCS) $(FLAGS) +define+BASELINE ../baseline/matmul.v $(WRAPPER) tb/tb_part2.sv -top tb_part2 -Mdir=build/csrc_integer -o build/simv_integer -l build/integer_compile.log
	./build/simv_integer -l reports/integer_sim.log
sim: | build
	$(VCS) $(FLAGS) $(FP) matmul.v $(WRAPPER) tb/tb_part2.sv -top tb_part2 -Mdir=build/csrc_fp8 -o build/simv_fp8 -l build/fp8_compile.log
	./build/simv_fp8 -l reports/sequence_sim.log
fsdb: | build
	test -d "$(VERDI_HOME)"
	$(VCS) $(FLAGS) +define+FSDB $(FP) matmul.v $(WRAPPER) tb/tb_part2.sv -top tb_part2 -Mdir=build/csrc_fsdb -o build/simv_fsdb -l build/fsdb_compile.log
	./build/simv_fsdb +CASE=1 -l reports/clean_sim.log
	./build/simv_fsdb +CASE=2 -l reports/exception_sim.log
	./build/simv_fsdb -l reports/sequence_sim.log
	test -s build/clean.fsdb && test -s build/exception.fsdb && test -s build/sequence.fsdb
synth-integer: | build
	mkdir -p build/dc_integer reports/integer
	cd build/dc_integer && dc_shell -x 'set DESIGN_KIND integer; source ../../synth/core.tcl' > ../../reports/integer/dc.log 2>&1
synth-fp8: | build
	mkdir -p build/dc_fp8 reports/fp8
	cd build/dc_fp8 && dc_shell -x 'set DESIGN_KIND fp8; source ../../synth/core.tcl' > ../../reports/fp8/dc.log 2>&1
