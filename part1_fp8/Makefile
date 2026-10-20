SHELL := /bin/sh
VCS ?= vcs
IVERILOG ?= iverilog
VVP ?= vvp
PYTHON ?= python3
RTL := rtl/fp8_round_pack.sv rtl/fp8_adder.sv rtl/fp8_multiplier.sv
VCS_FLAGS ?= -full64 -sverilog -timescale=1ns/1ps -debug_access+all -kdb

.PHONY: all sim sim-adder sim-multiplier vectors exhaustive sim-iverilog exhaustive-iverilog fsdb verdi-adder verdi-multiplier package clean help
all: sim

build:
	mkdir -p build

# Default: VCS directed tests; portable VCD output without a PLI dependency.
sim: sim-adder sim-multiplier

sim-adder: | build
	$(VCS) $(VCS_FLAGS) $(RTL) tb/tb_fp8_adder.sv -top tb_fp8_adder -Mdir=build/csrc_adder -o build/simv_adder -l build/adder_compile.log
	./build/simv_adder -l build/adder.log

sim-multiplier: | build
	$(VCS) $(VCS_FLAGS) $(RTL) tb/tb_fp8_multiplier.sv -top tb_fp8_multiplier -Mdir=build/csrc_multiplier -o build/simv_multiplier -l build/multiplier_compile.log
	./build/simv_multiplier -l build/multiplier.log

vectors: | build
	$(PYTHON) tools/generate_vectors.py --out build

exhaustive: vectors
	$(VCS) $(VCS_FLAGS) $(RTL) tb/tb_fp8_exhaustive.sv -top tb_fp8_exhaustive -Mdir=build/csrc_exhaustive -o build/simv_exhaustive -l build/exhaustive_compile.log
	./build/simv_exhaustive -l build/exhaustive.log

sim-iverilog: | build
	$(IVERILOG) -g2012 -s tb_fp8_adder -o build/adder.vvp $(RTL) tb/tb_fp8_adder.sv
	$(VVP) build/adder.vvp
	$(IVERILOG) -g2012 -s tb_fp8_multiplier -o build/multiplier.vvp $(RTL) tb/tb_fp8_multiplier.sv
	$(VVP) build/multiplier.vvp

exhaustive-iverilog: vectors
	$(IVERILOG) -g2012 -s tb_fp8_exhaustive -o build/exhaustive.vvp $(RTL) tb/tb_fp8_exhaustive.sv
	$(VVP) build/exhaustive.vvp

# Verdi 2024.09+: VCS loads the FSDB integration through VERDI_HOME.
# Do not add legacy -P novas.tab/pli.a options to this flow.
fsdb: | build
	@test -n "$(VERDI_HOME)" && test -d "$(VERDI_HOME)" || { echo "Load the course environment so VERDI_HOME points to the Verdi installation."; exit 1; }
	rm -f build/fp8_adder.fsdb build/fp8_multiplier.fsdb
	$(VCS) $(VCS_FLAGS) -debug_access+all +define+FSDB $(RTL) tb/tb_fp8_adder.sv -top tb_fp8_adder -Mdir=build/csrc_adder_fsdb_modern -o build/simv_adder_fsdb_modern -l build/adder_fsdb_compile.log
	./build/simv_adder_fsdb_modern -l build/adder_fsdb.log
	@test -s build/fp8_adder.fsdb || { echo "Adder FSDB was not generated; inspect build/adder_fsdb.log."; exit 1; }
	$(VCS) $(VCS_FLAGS) -debug_access+all +define+FSDB $(RTL) tb/tb_fp8_multiplier.sv -top tb_fp8_multiplier -Mdir=build/csrc_multiplier_fsdb_modern -o build/simv_multiplier_fsdb_modern -l build/multiplier_fsdb_compile.log
	./build/simv_multiplier_fsdb_modern -l build/multiplier_fsdb.log
	@test -s build/fp8_multiplier.fsdb || { echo "Multiplier FSDB was not generated; inspect build/multiplier_fsdb.log."; exit 1; }

verdi-adder:
	@test -s build/fp8_adder.fsdb || { echo "Run make fsdb first."; exit 1; }
	verdi -sv $(RTL) tb/tb_fp8_adder.sv -top tb_fp8_adder -ssf build/fp8_adder.fsdb &

verdi-multiplier:
	@test -s build/fp8_multiplier.fsdb || { echo "Run make fsdb first."; exit 1; }
	verdi -sv $(RTL) tb/tb_fp8_multiplier.sv -top tb_fp8_multiplier -ssf build/fp8_multiplier.fsdb &

package: | build
	$(PYTHON) tools/package_submission.py

clean:
	rm -rf build

help:
	@echo "make sim: VCS directed tests and VCD waveforms"
	@echo "make exhaustive: VCS, all 131072 input-pair/operation checks"
	@echo "make fsdb: VCS directed tests with Verdi FSDB output"
	@echo "make verdi-adder / verdi-multiplier: open FSDB in Verdi"
	@echo "make sim-iverilog / exhaustive-iverilog: open-source simulator"
	@echo "make package: source-only Part I ZIP in build/"
