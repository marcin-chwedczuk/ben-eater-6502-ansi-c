
# Set cc65 compiler paths
CC65_HOME = "/Users/mc/devel/retro/ben-eater-6502/cc65"
export CC65_INC = "${CC65_HOME}/include"
export LD65_LIB = "${CC65_HOME}/lib"
export LD65_CFG = "${CC65_HOME}/cfg"

SRC_DIR=src
BUILD_DIR=build

CFLAGS=-O -t c64

.PHONY: all
all: app

$(BUILD_DIR)/%.s: %.cc
	cc65 $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.s $(BUILD_DIR)/%.s
	ca65 -t c64 $< -o $@

app: main.o text.o

.PHONY: clean
clean:
        rm -f build/*