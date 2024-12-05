set BUILD_DIR "./build"
set HDL_DIR "./hdl"
set SYNTH_DIR "${BUILD_DIR}/synth"
set REPORT_DIR "${BUILD_DIR}/report"

lappend search_path $HDL_DIR $SYNTH_DIR

# Clock period (ns)
set TCLK 0.615
# 5% of TCLK
set TCU  [expr 0.05*${TCLK}]
# 10% of TCLK
set IN_DEL [expr 0.1*${TCLK}]
# 0% of TCLK
set IN_DEL_MIN [expr 0*${TCLK}]
# 10% of TCLK
set OUT_DEL [expr 0.1*${TCLK}]
# 0% of TCLK
set OUT_DEL_MIN [expr 0*${TCLK}]

set SIG_FIGS 5