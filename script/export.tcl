source ./script/varSetup.tcl

file mkdir ${SYNTH_DIR}/${DESIGN_NAME}
write -hierarchy -format verilog -output ${SYNTH_DIR}/${DESIGN_NAME}.vg
write_sdf -version 1.0 -context verilog ${SYNTH_DIR}/${DESIGN_NAME}.sdf
set_propagated_clock [all_clocks]
write_sdc ${SYNTH_DIR}/${DESIGN_NAME}.sdc
