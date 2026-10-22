SHELL := /bin/bash
VCS ?= vcs
PYTHON ?= python3
FP := ../part1_fp8/rtl/fp8_round_pack.sv ../part1_fp8/rtl/fp8_adder.sv ../part1_fp8/rtl/fp8_multiplier.sv
RTL := $(FP) ../part2_matmul4/matmul.v rtl/matmul_8x8.sv rtl/matmul_with_ram_8x8.sv
FLAGS := -full64 -sverilog -timescale=1ns/1ps -debug_access+all -kdb +incdir+tb
.PHONY: all vectors sim fsdb synth verdi source
all: sim
build:
	mkdir -p build reports
vectors:
	$(PYTHON) tools/matrix_cases.py
sim: | build
	$(VCS) $(FLAGS) $(RTL) tb/tb_part3.sv -top tb_part3 -Mdir=build/csrc -o build/simv -l reports/compile.log
	set -o pipefail; ./build/simv -l reports/sequence_sim.log | tee build/sequence_stdout.txt
	grep -q 'PART3 SIMULATION PASS total_checked=256' reports/sequence_sim.log
fsdb: | build
	test -d "$(VERDI_HOME)"
	$(VCS) $(FLAGS) +define+FSDB $(RTL) tb/tb_part3.sv -top tb_part3 -Mdir=build/csrc_fsdb -o build/simv_fsdb -l reports/compile_fsdb.log
	./build/simv_fsdb +CASE=1 -l reports/ones_sim.log
	./build/simv_fsdb +CASE=2 -l reports/varied_sim.log
	./build/simv_fsdb +CASE=3 -l reports/exception_sim.log
	./build/simv_fsdb -l reports/sequence_sim.log
	grep -q 'PART3 SIMULATION PASS total_checked=256' reports/sequence_sim.log
	test -s build/ones.fsdb && test -s build/varied.fsdb && test -s build/exception.fsdb && test -s build/sequence.fsdb
verdi:
	verdi -ssf build/ones.fsdb &
synth: | build
	mkdir -p build/dc_fp8 reports/fp8
	cd build/dc_fp8 && dc_shell -f ../../synth/core.tcl > ../../reports/fp8/dc.log 2>&1
	test -s reports/fp8/area.rpt && test -s reports/fp8/timing.rpt
source:
	$(PYTHON) tools/package_source.py
