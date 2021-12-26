CPU=cpu.v
DECODER=riscv_decode.v
TESTBENCH=testbench.v
TESTBENCH_DEC=tb_miriscv_decode_obf.v
LSU=miriscv_lsu.v
DEFINES=miriscv_defines.v

GENERAL=ALU.v instruction_memory.v register_file.v data_memory.v

SOURCES=$(CPU) $(DECODER) $(LSU) $(TESBENCH) $(GENERAL) $(DEFINES)
BIN=miet_riscv.vvp

FLAGS=-Wall

all: execute

execute: compile
	vvp $(BIN) $(BIN_OPTIONS)
compile:
	iverilog $(FLAGS) -o $(BIN) $(SOURCES)

compile_tb_mriscv_dec:
	iverilog $(FLAGS) -o tb_mriscv_decoder.vvp $(DECODER) $(DEFINES) $(TESTBENCH_DEC)

.PHONY: execute compile compile_tb_miriscv_dec
