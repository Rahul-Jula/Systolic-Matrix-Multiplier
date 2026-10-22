# Launch from part3_matmul8/build/dc_fp8. Match Part II constraints.
set TOP matmul_8x8
set ROOT [file normalize ../../..]
set OUT [file normalize ../../reports/fp8]
file mkdir $OUT
define_design_lib WORK -path ./WORK
set LIB "$env(PDK_DIR)/osu_soc/lib/files/gscl45nm.db"
set_app_var target_library [list $LIB]
set_app_var link_library [list * $LIB]
set_app_var hdlin_check_no_latch true
analyze -format sverilog [list $ROOT/part1_fp8/rtl/fp8_round_pack.sv $ROOT/part1_fp8/rtl/fp8_adder.sv $ROOT/part1_fp8/rtl/fp8_multiplier.sv $ROOT/part2_matmul4/matmul.v $ROOT/part3_matmul8/rtl/matmul_8x8.sv]
elaborate $TOP
current_design $TOP
if {![link]} {error "Core link failed"}
redirect $OUT/check_before.rpt {check_design}
create_clock -name core_clk -period 10.0 [get_ports clk]
set_clock_uncertainty 0.10 [get_clocks core_clk]
set_clock_transition 0.10 [get_clocks core_clk]
set_input_delay 1.0 -clock core_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1.0 -clock core_clk [all_outputs]
set_input_transition 0.10 [remove_from_collection [all_inputs] [get_ports clk]]
set_load 0.01 [all_outputs]
compile_ultra
redirect $OUT/check_after.rpt {check_design}
redirect $OUT/check_timing.rpt {check_timing}
redirect $OUT/area.rpt {report_area -hierarchy}
redirect $OUT/timing.rpt {report_timing -delay_type max -max_paths 10 -significant_digits 6 -nets -transition_time -capacitance}
redirect $OUT/reg_to_reg.rpt {report_timing -from [all_registers -output_pins] -to [all_registers -data_pins] -delay_type max -max_paths 5 -significant_digits 6}
redirect $OUT/constraints.rpt {report_constraint -all_violators -significant_digits 6}
redirect $OUT/qor.rpt {report_qor}
redirect $OUT/units.rpt {report_units}
write -format verilog -hierarchy -output mapped.v
write_sdc mapped.sdc
write -format ddc -hierarchy -output mapped.ddc
exit
