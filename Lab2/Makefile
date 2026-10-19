SIM ?= verilator
WIDTH ?= 16
FRAC ?= 13
F0 ?= 1
FD ?= 16
AMP ?= 1.0
PACKET_LEN ?= 64

B1_COEF := $(shell python3 -c "import math; print(math.floor(2*math.cos(2*math.pi*$(F0)/$(FD))*2**$(FRAC)+0.5))")
Y1_INIT := $(shell python3 -c "import math; print(math.floor($(AMP)*math.sin(2*math.pi*$(F0)/$(FD))*2**$(FRAC)+0.5))")

export WIDTH FRAC PACKET_LEN B1_COEF Y1_INIT

MAC_FILES := control multiplier_control multiplier summator register mac
VERILOG_SOURCES := $(addprefix ../Lab1/rtl/,$(addsuffix .sv,$(MAC_FILES))) rtl/sine_generator_control.sv rtl/sine_generator.sv

BACKPRESSURE_TESTING_MODULE ?= backpressure_testing
TRACE_FILE ?= wave/wave.fst

ifeq ($(firstword $(subst ., ,$(shell cocotb-config --version))),1)
	TOPLEVEL := sine_generator
	MODULE := sine_generator
else
	COCOTB_TOPLEVEL := sine_generator
	COCOTB_TEST_MODULES := sine_generator
endif

export PYTHONPATH := sim:$(PYTHONPATH)
COMPILE_ARGS += -GWIDTH=$(WIDTH) -GFRAC=$(FRAC) -GB1_COEF=$(B1_COEF) -GY1_INIT=$(Y1_INIT) -GPACKET_LEN=$(PACKET_LEN) -Wno-fatal -Wno-TIMESCALEMOD --trace-fst --trace-structs
SIM_ARGS += --trace --trace-file $(TRACE_FILE)
include $(shell cocotb-config --makefiles)/Makefile.sim
.PHONY: backpressure view view-backpressure
backpressure:
	mkdir -p wave
	$(MAKE) TRACE_FILE=wave/backpressure.fst MODULE=$(BACKPRESSURE_TESTING_MODULE) COCOTB_TEST_MODULES=$(BACKPRESSURE_TESTING_MODULE) sim
view:
	surfer wave/wave.fst --state-file wave/wave.ron
view-backpressure:
	surfer wave/backpressure.fst --state-file wave/backpressure.ron
clean::
	$(RM) wave/wave.fst wave/backpressure.fst results.xml