MODULE = mac
RTL_DIR = rtl
SIM_DIR = sim

SV_SRCS = $(wildcard $(RTL_DIR)/*.sv)
CPP_SRCS = $(wildcard $(SIM_DIR)/*.cpp)

WAVE_FILE = wave.fst

VFLAGS = -Wall -Wno-fatal --trace-fst --top-module $(MODULE) --cc $(SV_SRCS) --exe $(CPP_SRCS) \
         -I$(RTL_DIR) -I../common --build -j 0 -o sim_$(MODULE)

.PHONY: sim wave clean

sim:
	verilator $(VFLAGS)
	./obj_dir/sim_$(MODULE)

wave: sim
	@if pgrep -x "surfer" > /dev/null; then \
		echo "Surfer already running"; \
	else \
		surfer $(WAVE_FILE) & \
	fi

clean:
	rm -rf obj_dir $(WAVE_FILE)
