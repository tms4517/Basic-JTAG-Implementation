TOP_MODULE=jtag
RTL_PATH=../rtl
PACKAGE=jtag_pa

.PHONY: all clean verilate build sim waves

all: clean verilate build sim waves

verilate: .stamp.verilate

build: obj_dir/Vjtag

sim: waveform.vcd

waves: waveform.vcd
	@echo
	@echo "### WAVES ###"
	gtkwave waveform.vcd

waveform.vcd: ./obj_dir/V$(TOP_MODULE)
	@echo
	@echo "### SIMULATING ###"
	@./obj_dir/V$(TOP_MODULE) +verilator+rand+reset+2

./obj_dir/V$(TOP_MODULE): .stamp.verilate
	@echo
	@echo "### BUILDING SIM ###"
	make -C obj_dir -f V$(TOP_MODULE).mk V$(TOP_MODULE)

.stamp.verilate: $(RTL_PATH)/$(TOP_MODULE).sv tb_$(TOP_MODULE).cpp
	@echo
	@echo "### VERILATING ###"
ifdef test
	verilator -CFLAGS -D$(test) -Wall --trace --x-assign unique --x-initial unique -cc -I../rtl/ $(PACKAGE).sv $(RTL_PATH)/$(TOP_MODULE).sv --top-module jtag --exe tb_$(TOP_MODULE).cpp
endif
ifndef test
	@echo "Error: No test specified"
endif
	@touch .stamp.verilate

lint: $(RTL_PATH)/$(TOP_MODULE).sv
	verilator --lint-only -I../rtl/ $(PACKAGE).sv $(RTL_PATH)/$(TOP_MODULE).sv

clean:
	rm -rf .stamp.*;
	rm -rf ./obj_dir
	rm -rf waveform.vcd
