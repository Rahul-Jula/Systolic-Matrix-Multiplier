SHELL := /bin/sh
VCS ?= vcs
IVERILOG ?= iverilog
VVP ?= vvp
PYTHON ?= python3
RTL := rtl/fp8_round_pack.sv rtl/fp8_adder.sv rtl/fp8_multiplier.sv
VCS_FLAGS ?= -full64 -sverilog -timescale=1ns/1ps -debug_access+all -kdb
FSDB_PLI_DIR ?= $(VERDI_HOME)/share/PLI/VCS/LINUX64

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

# Optional FSDB flow for Apporto/Verdi. The PLI path can be overridden.
fsdb: | build
	@test -f "$(FSDB_PLI_DIR)/novas.tab" -a -f "$(FSDB_PLI_DIR)/pli.a" || { echo "Set VERDI_HOME or FSDB_PLI_DIR to the installed Verdi VCS/LINUX64 PLI directory. make sim works without this."; exit 1; }
	$(VCS) $(VCS_FLAGS) +define+FSDB -P "$(FSDB_PLI_DIR)/novas.tab" "$(FSDB_PLI_DIR)/pli.a" $(RTL) tb/tb_fp8_adder.sv -top tb_fp8_adder -Mdir=build/csrc_adder_fsdb -o build/simv_adder_fsdb -l build/adder_fsdb_compile.log
	./build/simv_adder_fsdb -l build/adder_fsdb.log
	$(VCS) $(VCS_FLAGS) +define+FSDB -P "$(FSDB_PLI_DIR)/novas.tab" "$(FSDB_PLI_DIR)/pli.a" $(RTL) tb/tb_fp8_multiplier.sv -top tb_fp8_multiplier -Mdir=build/csrc_multiplier_fsdb -o build/simv_multiplier_fsdb -l build/multiplier_fsdb_compile.log
	./build/simv_multiplier_fsdb -l build/multiplier_fsdb.log

verdi-adder:
	@test -f build/fp8_adder.fsdb || { echo "Run make fsdb first."; exit 1; }
	verdi -sv $(RTL) tb/tb_fp8_adder.sv -top tb_fp8_adder -ssf build/fp8_adder.fsdb &

verdi-multiplier:
	@test -f build/fp8_multiplier.fsdb || { echo "Run make fsdb first."; exit 1; }
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
