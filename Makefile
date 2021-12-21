SOURCES=ALU.v instruction_memory.v register_file.v cpu.v testbench.v miriscv_defines.v riscv_decode.v data_memory.v
BIN=cpu.vvp

all: execute

execute: compile
	vvp $(BIN) $(BIN_OPTIONS)
compile:
	iverilog -Wall -o $(BIN) $(SOURCES)
