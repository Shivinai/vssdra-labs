import os
import random

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge
from sine_model import model

WIDTH = int(os.environ["WIDTH"])
FRAC = int(os.environ.get("FRAC", "13"))
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
    received = []
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

            assert data == expected[index], (
                f"sample {index}: got {data}, "
                f"expected {expected[index]}"
            )

            expected_last = int(
                PACKET_LEN > 0
                and (index + 1) % PACKET_LEN == 0
            )

            assert last == expected_last, (
                f"sample {index}: TLAST={last}, "
                f"expected {expected_last}"
            )

            received.append(data)
            index += 1

            if index == N:
                break

    assert index == N, (
        f"timeout: received {index} of {N} samples"
    )

    scale = 2 ** FRAC

    expected_plot = [value / scale for value in expected]
    received_plot = [value / scale for value in received]

    samples = range(N)

    fig, ax = plt.subplots(figsize=(12, 5))

    ax.plot(
        samples,
        expected_plot,
        linestyle="--",
        linewidth=2,
        label="Python model"
    )

    ax.plot(
        samples,
        received_plot,
        marker=".",
        markersize=4,
        linewidth=1,
        label="SV model"
    )

    ax.set_xlabel("n")
    ax.set_ylabel("A")
    ax.legend()

    fig.savefig("wave/proof.png", dpi=150, bbox_inches="tight")
    plt.close(fig)