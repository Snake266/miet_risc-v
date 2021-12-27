CPU=miriscv_core.v
DECODER=riscv_decode.v
LSU=miriscv_lsu.v

TOP=miriscv_top.sv
RAM=miriscv_ram.sv

DEFINES=miriscv_defines.v

TESTBENCH=testbench.v
TESTBENCH_DEC=tb_miriscv_decode_obf.v
TESTBENCH_TOP=tb_miriscv_top.v

GENERAL=ALU.v register_file.v

SOURCES=$(CPU) $(DECODER) $(LSU) $(TOP) $(RAM) $(GENERAL) $(DEFINES)
BIN=miet_riscv.vvp

FLAGS=-Wall -g2012

all:
	iverilog $(FLAGS) -o $(BIN) $(SOURCES) $(TESTBENCH)

compile_tb_mriscv_dec:
	iverilog $(FLAGS) -o tb_mriscv_decoder.vvp $(DECODER) $(DEFINES) $(TESTBENCH_DEC)

compile_tb_mriscv_top:
	iverilog $(FLAGS) -o tb_mriscv_top.vvp $(CPU) $(LSU) $(TOP) $(RAM) $(DECODER) $(DEFINES) $(TESTBENCH_TOP) $(GENERAL)

.PHONY: compile_tb_miriscv_dec compile_tb_mriscv_top
