SHELL := /bin/bash
VCS ?= vcs
PYTHON ?= python3
FP := ../part1_fp8/rtl/fp8_round_pack.sv ../part1_fp8/rtl/fp8_adder.sv ../part1_fp8/rtl/fp8_multiplier.sv
RTL := $(FP) ../part2_matmul4/matmul.v ../part3_matmul8/rtl/matmul_8x8.sv ../part3_matmul8/rtl/matmul_with_ram_8x8.sv rtl/apb_matmul_control.sv rtl/matmul_apb_8x8.sv
FLAGS := -full64 -sverilog -timescale=1ns/1ps -debug_access+all -kdb +incdir+tb
.PHONY: all sim fsdb verdi source viewers
all: sim
build:
	mkdir -p build reports
sim: | build
	$(VCS) $(FLAGS) $(RTL) tb/tb_part4.sv -top tb_part4 -Mdir=build/csrc -o build/simv -l reports/compile.log
	set -o pipefail; ./build/simv -l reports/sequence_sim.log | tee build/sequence_stdout.txt
	grep -q 'PART4 SIMULATION PASS total_checked=320' reports/sequence_sim.log
fsdb: | build
	test -d "$(VERDI_HOME)"
	$(VCS) $(FLAGS) +define+FSDB $(RTL) tb/tb_part4.sv -top tb_part4 -Mdir=build/csrc_fsdb -o build/simv_fsdb -l reports/compile_fsdb.log
	./build/simv_fsdb +CASE=1 -l reports/ones_sim.log
	grep -q 'PART4 SIMULATION PASS total_checked=64' reports/ones_sim.log
	./build/simv_fsdb +CASE=2 -l reports/varied_sim.log
	grep -q 'PART4 SIMULATION PASS total_checked=64' reports/varied_sim.log
	./build/simv_fsdb +CASE=3 -l reports/exception_sim.log
	grep -q 'PART4 SIMULATION PASS total_checked=64' reports/exception_sim.log
	./build/simv_fsdb -l reports/sequence_sim.log
	grep -q 'PART4 SIMULATION PASS total_checked=320' reports/sequence_sim.log
	test -s build/ones.fsdb && test -s build/varied.fsdb && test -s build/exception.fsdb && test -s build/sequence.fsdb
	$(PYTHON) tools/make_viewers.py
viewers:
	$(PYTHON) tools/make_viewers.py
verdi:
	nWave -ssf build/exception.fsdb -play docs/viewers/exception_run.tcl &
source:
	$(PYTHON) tools/package_source.py
