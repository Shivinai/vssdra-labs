import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge


@cocotb.test()
async def test_backpressure(dut):
    cocotb.start_soon(Clock(dut.CLK, 10, "ns").start())

    dut.M_AXIS_TREADY.value = 0
    dut.RESET.value = 1

    for _ in range(4):
        await FallingEdge(dut.CLK)

    dut.RESET.value = 0

    for _ in range(1000):
        await FallingEdge(dut.CLK)

        if int(dut.M_AXIS_TVALID.value):
            break
    else:
        raise AssertionError("TVALID is not set")

    held_data = int(dut.M_AXIS_TDATA.value)
    held_last = int(dut.M_AXIS_TLAST.value)

    for cycle in range(10):
        await FallingEdge(dut.CLK)

        assert int(dut.M_AXIS_TVALID.value) == 1, (
            f"TVALID reset during backpressure, cycle: {cycle}"
        )

        assert int(dut.M_AXIS_TDATA.value) == held_data, (
            f"TDATA got data during backpressure, cycle: {cycle}"
        )

        assert int(dut.M_AXIS_TLAST.value) == held_last, (
            f"TLAST changed during backpressure, cycle: {cycle}"
        )

    dut.M_AXIS_TREADY.value = 1
    await RisingEdge(dut.CLK)

    accepted = 1

    for _ in range(2000):
        await FallingEdge(dut.CLK)

        if int(dut.M_AXIS_TVALID.value):
            await RisingEdge(dut.CLK)
            accepted += 1

            if accepted >= 3:
                break
    else:
        raise AssertionError(
            f"Transfer did not resume: accepted {accepted} words"
        )

    dut._log.info(
        "Backpressure test passed"
    )