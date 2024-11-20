################################################################################
# lab3_synthesis.tcl                                                           #
################################################################################
remove_design -all

#####
# Add search paths for our technology libs.
################################################################################
set search_path "$search_path . ./verilog /w/apps2/public.2/tech/synopsys/32-28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm" 
set target_library "saed32rvt_tt1p05v25c.db saed32rvt_pg_tt1p05v25c.db"
set link_library   "* saed32rvt_tt1p05v25c.db saed32rvt_pg_tt1p05v25c.db dw_foundation.sldb"
set synthetic_library "dw_foundation.sldb"


#####
# Read in verilog and upf files.
################################################################################
analyze -format verilog {1_clk_mux.v}
analyze -format verilog {2_lfsr.v}
analyze -format verilog {3_seqdet.v}
analyze -format verilog {4_counter.v}
analyze -format verilog {5_bcd_convert.v}
analyze -format verilog {top.v}
set DESIGN_NAME top

elaborate $DESIGN_NAME
current_design $DESIGN_NAME
set upf_create_implicit_supply_sets false
load_upf lab3.upf


#####
# link verilog and upf files
################################################################################
link


#####
# Set Operating Conditions
################################################################################
set_operating_conditions tt1p05v25c


#####
# Set Operating Voltages for Power Domains
################################################################################
set_voltage 1.05 -object_list {VDD}
set_voltage 0.00 -object_list {VSS}

# ADD CODE HERE FOR PART 2: set_voltage (Vck_mx, Vlfsr, Vsd, Vcnt, Vbcd)
set_voltage 1.05 -object_list {Vck_mx}
set_voltage 1.05 -object_list {Vlfsr}
set_voltage 1.05 -object_list {Vsd}
set_voltage 1.05 -object_list {Vcnt}
set_voltage 1.05 -object_list {Vbcd}


#####
# Describe the clock waveform & setup operating conditions
################################################################################
set Tclk1 6.0
set Tclk2 8.0
set TCU  0.1
set IN_DEL 0.6
set IN_DEL_MIN 0.3
set OUT_DEL 0.6
set OUT_DEL_MIN 0.3
set ALL_IN_BUT_CLK [remove_from_collection [remove_from_collection [all_inputs] "clk1"] "clk2"]

create_clock -name "clk1" -period $Tclk1 [get_ports "clk1"]
create_clock -name "clk2" -period $Tclk2 [get_ports "clk2"]
set_fix_hold clk1
set_fix_hold clk2
set_dont_touch_network [get_clocks "clk1"]
set_clock_uncertainty $TCU [get_clocks "clk1"]
set_dont_touch_network [get_clocks "clk2"]
set_clock_uncertainty $TCU [get_clocks "clk2"]

set_input_delay $IN_DEL -clock "clk2" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN -clock "clk2" $ALL_IN_BUT_CLK
set_output_delay $OUT_DEL -clock "clk2" [all_outputs]
set_output_delay -min $OUT_DEL_MIN -clock "clk2" [all_outputs]


#####
# Describe which paths are false paths
################################################################################
set_false_path -from [get_ports ck_mx_sw_ctr]
set_false_path -from [get_ports lfsr_sw_ctr]
set_false_path -from [get_ports sd_sw_ctr]
set_false_path -from [get_ports cnt_sw_ctr]
set_false_path -from [get_ports bcd_sw_ctr]
set_false_path -from [get_ports iso1]
set_false_path -from [get_ports iso2]
set_false_path -from [get_ports iso3]
set_false_path -from [get_ports iso4]
set_false_path -from [get_ports iso5]


#####
# OPTIONS
################################################################################
set_max_area 0.0
set compile_preserve_subdesign_interfaces true


#####
# Enable Isolation Cells (uncomment to enable)
################################################################################
remove_attribute   saed32rvt_tt1p05v25c/ISO* dont_use
remove_attribute   saed32rvt_tt1p05v25c/ISO* dont_touch


#####
# Compile
################################################################################
compile_ultra


#####
# Reports
################################################################################
report_area -hierarchy > Design.area
report_power -hier -hier_level 2 > Design.power


#####
# Save Outputs
################################################################################
write -hierarchy -format verilog -output $DESIGN_NAME.vg
write_sdf -version 1.0 -context verilog $DESIGN_NAME.sdf
set_propagated_clock [all_clocks]
write_sdc $DESIGN_NAME.sdc
save_upf $DESIGN_NAME.synth.upf
