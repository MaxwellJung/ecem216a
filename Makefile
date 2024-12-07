SRC_DIRS := ./hdl
SRC_FILES := $(shell find $(SRC_DIRS) -name '*.sv' -or -name '*.v')
BUILD_DIR := ./build
SIM_DIR := $(BUILD_DIR)/sim
WORK_DIR := ./WORK

all: synth

synth: FORCE
	dc_shell -f script/synthesis.tcl

# Icarus
rect_fill_sim: FORCE
	mkdir -p $(dir $(BUILD_DIR)/m216a_tb.vvp)
	iverilog -o $(BUILD_DIR)/m216a_tb.vvp -s M216A_TB $(SRC_FILES) ./test/M216A_TB.v
	vvp $(BUILD_DIR)/m216a_tb.vvp
	mkdir -p $(dir $(SIM_DIR)/rect_fill_dump.vcd)
	mv dump.vcd $(SIM_DIR)/rect_fill_dump.vcd

.PHONY: clean
clean:
	rm -r $(BUILD_DIR) $(WORK_DIR)

FORCE: ;
