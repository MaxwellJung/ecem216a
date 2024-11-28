################################################################################
# PRIMETIME: Static Timing Analysis Tool                                       #
################################################################################
remove_design -all

# Setup Various Paths to Store Files 
#(For example, I have these folders under my working directory)
set LOGPATH    "LOG/"
set LIBPATH    "LIB/"
set OUTPATH    "SYN/"
set WORKPATH   "WORK/"
set DESIGNPATH "HDL/"
set SYNOPEND   ".db"

# Add search paths for ptpx to find our technology libs.
set search_path "$search_path . ./verilog /w/apps2/public.2/tech/synopsys/32-28nm/SAED32_EDK/lib/stdcell_rvt/db_nldm" 

set target_library "saed32rvt_tt1p05v25c.db"
set link_library   "* saed32rvt_tt1p05v25c.db"




# Read the gate-level verilog files
read_verilog {./build/synth/M216A_TopModule.vg}

set DESIGN_NAME M216A_TopModule
current_design $DESIGN_NAME
link_design $DESIGN_NAME

# Describe the clock waveform & setup operating conditions
set TCLK 8.0
set TCU  0.1
set IN_DEL 0.6
set IN_DEL_MIN 0.3
set OUT_DEL 0.6
set OUT_DEL_MIN 0.3

set CLK_PORT "clk_i"
set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] $CLK_PORT]

create_clock -name $CLK_PORT -period $TCLK [get_ports $CLK_PORT]
set_clock_uncertainty $TCU [get_clocks $CLK_PORT]
set_propagated_clock [all_clocks]
set_input_delay $IN_DEL -clock $CLK_PORT $ALL_IN_BUT_CLK


set_operating_conditions tt1p05v25c

# Describe which paths are false paths

# Read the parasitic files (after PnR, ignore this section for now)
#remove_annotated_parasitics -all
#read_parasitics -triplet_type max alu.spef

# Report the timing information 
report_timing -transition_time -slack_greater_than 0.00

report_timing -transition_time -delay_type min

# Extract a .lib file for your macro
extract_model -library_cell -format lib -output $DESIGN_NAME


################################################################################
# PRIMEPOWER: Data-Dependent, Cycle-Accurate Power Analysis                    #
################################################################################

# UNCOMMENT FOR PART 2
#set power_enable_analysis true

################################################################################
# Of course, ptpx not only gives you accurate static-timing analysis, but also #
# gives you an easy way to model your power. The power estimate can be done in #
# two ways, either you want a averaged power or a data-dependent, cycle-       #
# accurate power analysis based on a particular testvectors. For average       #
# power, you only need to do this:                                             #
#                                                                              #
#    set power_analysis_mode averaged                                          #
#                                                                              #
# For cycle-accurate power (instantaneous peak power for each clock cycle),    #
# you need to do:                                                              #
#                                                                              #
#    set power_analysis_mode time_based                                        #
#    set_power_analysis_options -cycle_accurate_clock clk_p_i                  #
#                                                                              #
################################################################################

# ADD CODE HERE FOR PART 2


################################################################################
# Read the .vcd files. This is a file containing toggling activities of a      #
# particular testvectors (i.e. you send a bunch of test data into your design, #
# and record the switching activities of each of the internal nodes). To get   #
# this file, you need to have (1)Gate-level netlist, including design.vg and   #
# testbench.v; (2)SDF files. To annotate SDF information and also dump the     #
#.vcd file, you just need to create a new initial block in testbench.v and     #
# write this:                                                                  #
#                                                                              #
# initial begin                                                                #
#   $sdf_annotate("Design.sdf", InstanceNameOfYourTestedModule);               #
#   $dumpfile("CTRL_1V.vcd") ;                                                 #
#   $dumpvars ;                                                                #
# end                                                                          #
#                                                                              #
# If everything runs correctly, then your gate-level simulation should have    #
# technology-dependent delay behaviors. After the simulation, you can also get #
# a .vcd file under the same folder you did your gate-level simulation.        #
################################################################################

# UNCOMMENT FOR PART 2 
#read_vcd alu.vcd -strip_path alu_tb/alu_0
#update_power
#report_power -verbose
