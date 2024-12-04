remove_design -all
source ./script/varSetup.tcl

# Setup technology library
source ./script/libSetup.tcl

# Read RTL design & do architectural mapping
analyze -format verilog {height_to_id.v}
analyze -format verilog {latency.v}
analyze -format verilog {least_strip.v}
analyze -format verilog {M216A_TopModule.v}
analyze -format verilog {p1_reg.v}
analyze -format verilog {strip_id_to_y.v}
set DESIGN_NAME M216A_TopModule

elaborate ${DESIGN_NAME}
current_design ${DESIGN_NAME}
link

# Setup design constraint
set_operating_conditions -min ff1p16vn40c -max ss0p95v125c
#set_wire_load_selection_group "predcaps"
#source ./script/constraints.tcl
#source ./SET_CON/T40GP_VarSetup.tcl
#set_false_path -from [get_ports ACLR_]

set CLK_PORT "clk_i"
create_clock -name $CLK_PORT -period $TCLK [get_ports $CLK_PORT]
set_fix_hold clk_i
set_dont_touch_network [get_clocks $CLK_PORT]
set_clock_uncertainty $TCU [get_clocks $CLK_PORT]

set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] $CLK_PORT]
set_input_delay -max $IN_DEL -clock $CLK_PORT $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN -clock $CLK_PORT $ALL_IN_BUT_CLK
set_output_delay -max $OUT_DEL -clock $CLK_PORT [all_outputs]
set_output_delay -min $OUT_DEL_MIN -clock $CLK_PORT [all_outputs]

# set_max_area 0.0
# set_max_total_power 0.0

ungroup -flatten -all
uniquify

# Compile design
compile -only_design_rule
compile -map high
compile -boundary_optimization
compile -only_hold_time

# compile_ultra -retime

# compile_ultra -no_autoungroup
# set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
# remove_unconnected_ports -blast_buses [get_cells -hier]

# Get reports
file mkdir ${REPORT_DIR}/${DESIGN_NAME}
report_timing -path full -delay min -max_paths 10 > ${REPORT_DIR}/${DESIGN_NAME}/design.holdtiming
report_timing -path full -delay max -max_paths 10 > ${REPORT_DIR}/${DESIGN_NAME}/design.setuptiming
report_area -hierarchy > ${REPORT_DIR}/${DESIGN_NAME}/design.area
report_power -hier -hier_level 2 > ${REPORT_DIR}/${DESIGN_NAME}/design.power
report_resources > ${REPORT_DIR}/${DESIGN_NAME}/design.resources
report_constraint -verbose > ${REPORT_DIR}/${DESIGN_NAME}/design.constraint
check_design > ${REPORT_DIR}/${DESIGN_NAME}/design.check_design
check_timing > ${REPORT_DIR}/${DESIGN_NAME}/design.check_timing

file mkdir ${SYNTH_DIR}/${DESIGN_NAME}
write -hierarchy -format verilog -output ${SYNTH_DIR}/${DESIGN_NAME}.vg
write_sdf -version 1.0 -context verilog ${SYNTH_DIR}/${DESIGN_NAME}.sdf
set_propagated_clock [all_clocks]
write_sdc ${SYNTH_DIR}/${DESIGN_NAME}.sdc

exit