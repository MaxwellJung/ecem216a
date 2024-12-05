source ./script/varSetup.tcl

set SIG_FIGS 5

# Generate report files
file mkdir ${REPORT_DIR}/${DESIGN_NAME}
report_timing -path full -delay min -max_paths 10 -significant_digits ${SIG_FIGS} > ${REPORT_DIR}/${DESIGN_NAME}/design.holdtiming
report_timing -path full -delay max -max_paths 10 -significant_digits ${SIG_FIGS} > ${REPORT_DIR}/${DESIGN_NAME}/design.setuptiming
report_area -hierarchy > ${REPORT_DIR}/${DESIGN_NAME}/design.area
report_power -hier -hier_level 2 > ${REPORT_DIR}/${DESIGN_NAME}/design.power
report_resources > ${REPORT_DIR}/${DESIGN_NAME}/design.resources
report_constraint -verbose > ${REPORT_DIR}/${DESIGN_NAME}/design.constraint
check_design > ${REPORT_DIR}/${DESIGN_NAME}/design.check_design
check_timing > ${REPORT_DIR}/${DESIGN_NAME}/design.check_timing
