
REPO_DIR = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# Set cc65 compiler paths
CC65_HOME = $(REPO_DIR)/cc65
BIN_DIR = $(CC65_HOME)/bin
export CC65_INC = $(CC65_HOME)/include
export LD65_LIB = $(CC65_HOME)/lib
export LD65_CFG = $(CC65_HOME)/cfg

# Project structure
SRC_DIR=src
BUILD_DIR=build
HW_DIR=hardware
ROM_IMAGE=rom.image

# Grab only filenames _without_ directory prefix
C_FILES=$(notdir $(wildcard $(SRC_DIR)/*.cc))
ASM_FILES=$(notdir $(wildcard $(SRC_DIR)/*.s))
# Order is important, we may use functions from assembly in C but not in the other direction
OBJ_FILES=$(patsubst %.s,%.o,$(ASM_FILES)) $(patsubst %.cc,%.o,$(C_FILES)) 

# Compiler settings
CPU=65c02
CFLAGS=-t none -O --cpu $(CPU)
ASMFLAGS=-t none --cpu $(CPU)
LDFLAGS=-C $(HW_DIR)/be6502.cfg

.PHONY: all
all: app

$(BUILD_DIR)/%.s: $(SRC_DIR)/%.cc
	$(BIN_DIR)/cc65 $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o: $(BUILD_DIR)/%.s $(SRC_DIR)/%.cc
	$(BIN_DIR)/ca65 $(ASMFLAGS) $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	$(BIN_DIR)/ca65 $(ASMFLAGS) $< -o $@

app: $(addprefix $(BUILD_DIR)/,$(OBJ_FILES))
	$(BIN_DIR)/ld65 -o $(BUILD_DIR)/$(ROM_IMAGE) $(LDFLAGS)  --obj-path $(HW_DIR) \
		$(HW_DIR)/interrupt.o $(HW_DIR)/vectors.o $(HW_DIR)/wait.o \
		$^ $(HW_DIR)/be6502.lib

# Oneoff action to create C runtime for Ben Eater 6502 computer
.PHONY: mkruntime
mkruntime: $(HW_DIR)/crt0.s $(HW_DIR)/be6502.cfg
	rm -f $(HW_DIR)/be6502.lib
	cp $(CC65_HOME)/lib/supervision.lib $(HW_DIR)/be6502.lib
	$(BIN_DIR)/ca65 $(HW_DIR)/crt0.s -o $(HW_DIR)/crt0.o 
	$(BIN_DIR)/ca65 $(HW_DIR)/interrupt.s -o $(HW_DIR)/interrupt.o
	$(BIN_DIR)/ca65 $(HW_DIR)/vectors.s -o $(HW_DIR)/vectors.o 
	$(BIN_DIR)/ca65 $(HW_DIR)/wait.s -o $(HW_DIR)/wait.o 
	$(BIN_DIR)/ar65 a $(HW_DIR)/be6502.lib $(HW_DIR)/crt0.o

.PHONY: clean
clean:
	rm -f build/*
