SRC_DIRS := ./hdl
BUILD_DIR := ./build
SIM_DIR := $(BUILD_DIR)/sim
SRC_FILES := $(shell find $(SRC_DIRS) -name '*.sv' -or -name '*.v')

all: rect_fill_sim

# Icarus

rect_fill_sim: $(SIM_DIR)/rect_fill_dump.vcd

$(SIM_DIR)/rect_fill_dump.vcd: $(BUILD_DIR)/m216a_tb.vvp
	vvp $^
	mkdir -p $(dir $@)
	mv dump.vcd $@

$(BUILD_DIR)/m216a_tb.vvp: $(SRC_FILES) ./test/M216A_TB.v
	mkdir -p $(dir $@)
	iverilog -o $@ -s M216A_TB $^

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
