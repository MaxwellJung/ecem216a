# Setup technology library
remove_design -all
source ./SET_CON/T40GP_LibSetup.tcl
lappend search_path ./HDL ./SYN

# Read RTL design & do architectural mapping
analyze -format verilog Adder.v
set PROCESS _T40GP
set DESIGN_NAME ADD
elaborate $DESIGN_NAME
link

# Setup design constraint
set_operating_conditions -min ff1p16vn40c -max ss0p95v125c
set_wire_load_selection_group "predcaps"
set TCLK 1.9
set TCU 0.1
source ./SET_CON/T40GP_VarSetup.tcl
set_false_path -from [get_ports ACLR_]

# Compile design
uniquify
compile -only_design_rule
compile_ultra -no_autoungroup
compile -inc -only_hold_time
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
remove_unconnected_ports -blast_buses [get_cells -hier]

# Get reports
report_timing -path full -delay min -max_paths 10 > $LOGPATH$TOPLEVEL$PROCESS.holdtiming
report_timing -path full -delay max -max_paths 10 > $LOGPATH$TOPLEVEL$PROCESS.setuptiming
report_area -hierarchy > $LOGPATH$TOPLEVEL$PROCESS.area
report_power -hier -hier_level 2 > $LOGPATH$TOPLEVEL$PROCESS.power