import os
import random
 
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
from sine_model import model
 
WIDTH = int(os.environ["WIDTH"])
FRAC = int(os.environ["FRAC"])
B1_COEF = int(os.environ["B1_COEF"])
Y1_INIT = int(os.environ["Y1_INIT"])
PACKET_LEN = int(os.environ["PACKET_LEN"])

N = 256

@cocotb.test()
async def test_sine_generator(dut):
    random.seed(1)
    cocotb.start_soon(Clock(dut.CLK, 10, "ns").start())
    dut.M_AXIS_TREADY.value = 0
    dut.RESET.value = 1
    for _ in range(4):
        await FallingEdge(dut.CLK)
    dut.RESET.value = 0
 
    expected = model(N)
    index = 0
    for _ in range(N * 200):
        await FallingEdge(dut.CLK)
        ready = int(random.random() < 0.1)
        dut.M_AXIS_TREADY.value = ready
        if ready and int(dut.M_AXIS_TVALID.value):
            data = int(dut.M_AXIS_TDATA.value)
            if data >= 1 << (WIDTH - 1):
                data -= 1 << WIDTH
            last = int(dut.M_AXIS_TLAST.value)
            assert data == expected[index], f"sample {index}: got {data}, expected {expected[index]}"
            assert last == int(PACKET_LEN > 0 and (index + 1) % PACKET_LEN == 0), f"sample {index}: wrong TLAST"
            index += 1
            if index == N:
                break
    assert index == N, f"timeout: received {index} of {N} samples"
