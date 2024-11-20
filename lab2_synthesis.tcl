################################################################################
# DESIGN COMPILER:  Logic Synthesis Tool                                       #
################################################################################
remove_design -all

# Add search paths for our technology libs.
set search_path "$search_path . ./verilog /w/apps2/public.2/tech/synopsys/32-28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm" 
set target_library "saed32rvt_ff1p16vn40c.db saed32rvt_ss0p95v125c.db"
set link_library "* saed32rvt_ff1p16vn40c.db saed32rvt_ss0p95v125c.db dw_foundation.sldb"
set synthetic_library "dw_foundation.sldb"

# Define work path (note: The work path must exist, so you need to create a folder WORK first)
define_design_lib WORK -path ./WORK
#define_design_lib work -path ./work

set alib_library_analysis_path “./alib-52/”

# Read the gate-level verilog files

read_file {M216A_TopModule.v latency.v least_strip.v p1_reg.v height_to_id.v strip_id_to_y.v} -autoread -format verilog -top MyTopModule
set DESIGN_NAME M216A_TopModule

elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link


set_operating_conditions -min ff1p16vn40c -max ss0p95v125c


# Describe the clock waveform & setup operating conditions
set Tclk 8.0
set TCU  0.1
set IN_DEL 0.6
set IN_DEL_MIN 0.3
set OUT_DEL 0.6
set OUT_DEL_MIN 0.3

set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk_i"]
create_clock -name "clk_i" -period $Tclk [get_ports "clk_i"]
 
set_fix_hold clk_i
set_dont_touch_network [get_clocks "clk_i"]
set_clock_uncertainty $TCU [get_clocks "clk_i"]

set_input_delay $IN_DEL -clock "clk_i" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN -clock "clk_i" $ALL_IN_BUT_CLK
set_output_delay $OUT_DEL -clock "clk_i" [all_outputs]
set_output_delay -min $OUT_DEL_MIN -clock "clk_i" [all_outputs]





set_max_area 0.0


ungroup -flatten -all
uniquify

compile -only_design_rule
compile -map high
compile -boundary_optimization
compile -only_hold_time

report_timing -path full -delay min -max_paths 10 -nworst 2 > Design.holdtiming
report_timing -path full -delay max -max_paths 10 -nworst 2 > Design.setuptiming
report_area -hierarchy > Design.area
report_power -hier -hier_level 2 > Design.power
report_resources > Design.resources
report_constraint -verbose > Design.constraint
check_design > Design.check_design
check_timing > Design.check_timing

write -hierarchy -format verilog -output $DESIGN_NAME.vg
write_sdf -version 1.0 -context verilog $DESIGN_NAME.sdf
set_propagated_clock [all_clocks]
write_sdc $DESIGN_NAME.sdc
