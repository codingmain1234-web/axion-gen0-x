import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


CMD_LOAD_A0 = 0x10
CMD_LOAD_B0 = 0x18
CMD_VEC_ADD = 0x20
CMD_DOT8_MAC = 0x28
CMD_READ_VEC0 = 0x30
CMD_READ_ACC0 = 0x38
CMD_READ_RELU = 0x3D
CMD_READ_BIST = 0x3E
CMD_READ_VER = 0x3F
CMD_CLEAR_ACC = 0x40
CMD_SELF_TEST = 0x50


def s8(value):
    value &= 0xFF
    return value - 256 if value & 0x80 else value


def lane_op(op, a, b):
    if op == 0:
        return (a + b) & 0xFF
    if op == 1:
        return (a - b) & 0xFF
    if op == 2:
        return (a * b) & 0xFF
    if op == 3:
        return a & b
    if op == 4:
        return a ^ b
    if op == 5:
        return max(a, b)
    if op == 6:
        return min(a, b)
    raise ValueError(op)


async def start_and_reset(dut):
    # Icarus uses 1 ps precision, so use the nearest exactly representable
    # period to the 64.516129 ns (15.5 MHz) physical-design constraint.
    cocotb.start_soon(Clock(dut.clk, 64.516, unit="ns").start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")


async def pulse_command(dut, command, data=0):
    dut.ui_in.value = data & 0xFF
    dut.uio_in.value = command
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    dut.uio_in.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # The registered command predecode adds one cycle before the four-stage
    # DOT8 data pipeline; wait through the accumulator commit edge.
    if command == CMD_DOT8_MAC:
        for _ in range(4):
            await RisingEdge(dut.clk)
            await Timer(1, unit="ns")


async def load_vectors(dut, a_values, b_values):
    assert len(a_values) == len(b_values) == 8
    for lane, value in enumerate(a_values):
        await pulse_command(dut, CMD_LOAD_A0 + lane, value)
    for lane, value in enumerate(b_values):
        await pulse_command(dut, CMD_LOAD_B0 + lane, value)


async def read_vector(dut):
    values = []
    for lane in range(8):
        await pulse_command(dut, CMD_READ_VEC0 + lane)
        values.append(int(dut.uo_out.value))
    return values


async def read_acc_u40(dut):
    value = 0
    for byte in range(5):
        await pulse_command(dut, CMD_READ_ACC0 + byte)
        value |= int(dut.uo_out.value) << (8 * byte)
    return value


@cocotb.test()
async def test_reset_version_and_fixed_outputs(dut):
    await start_and_reset(dut)
    assert int(dut.uo_out.value) == 0
    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0
    await pulse_command(dut, CMD_READ_VER)
    assert int(dut.uo_out.value) == 0xA8


@cocotb.test()
async def test_all_simd8_operations(dut):
    await start_and_reset(dut)
    a_values = [250, 3, 20, 0xAC, 0, 255, 64, 17]
    b_values = [10, 5, 13, 0x3C, 255, 1, 4, 99]
    await load_vectors(dut, a_values, b_values)
    for op in range(7):
        await pulse_command(dut, CMD_VEC_ADD + op)
        expected = [lane_op(op, a, b) for a, b in zip(a_values, b_values)]
        assert await read_vector(dut) == expected


@cocotb.test()
async def test_dot8_accumulator_relu_and_full_readback(dut):
    await start_and_reset(dut)
    await pulse_command(dut, CMD_CLEAR_ACC)
    a_values = list(range(1, 9))
    b_values = list(range(8, 0, -1))
    await load_vectors(dut, a_values, b_values)
    await pulse_command(dut, CMD_DOT8_MAC)
    assert int(dut.uo_out.value) == 120
    assert await read_acc_u40(dut) == 120

    await pulse_command(dut, CMD_DOT8_MAC)
    assert int(dut.uo_out.value) == 127
    assert await read_acc_u40(dut) == 240

    await pulse_command(dut, CMD_CLEAR_ACC)
    await load_vectors(dut, [0xFC] + [0] * 7, [2] + [0] * 7)
    await pulse_command(dut, CMD_DOT8_MAC)
    assert int(dut.uo_out.value) == 0
    assert await read_acc_u40(dut) == 0xFFFFFFFFF8


@cocotb.test()
async def test_enable_freezes_state(dut):
    await start_and_reset(dut)
    await load_vectors(dut, list(range(1, 9)), list(range(8, 0, -1)))
    await pulse_command(dut, CMD_VEC_ADD)
    assert await read_vector(dut) == [9] * 8
    dut.ena.value = 0
    await pulse_command(dut, CMD_LOAD_A0, 100)
    await pulse_command(dut, CMD_CLEAR_ACC)
    dut.ena.value = 1
    await pulse_command(dut, CMD_VEC_ADD)
    assert await read_vector(dut) == [9] * 8


@cocotb.test()
async def test_random_vectors_and_dot8(dut):
    await start_and_reset(dut)
    rng = random.Random(0xA710)
    for _ in range(48):
        a_values = [rng.randrange(256) for _ in range(8)]
        b_values = [rng.randrange(256) for _ in range(8)]
        await load_vectors(dut, a_values, b_values)
        op = rng.randrange(7)
        await pulse_command(dut, CMD_VEC_ADD + op)
        assert await read_vector(dut) == [
            lane_op(op, a, b) for a, b in zip(a_values, b_values)
        ]
        await pulse_command(dut, CMD_CLEAR_ACC)
        await pulse_command(dut, CMD_DOT8_MAC)
        expected_dot = sum(s8(a) * s8(b) for a, b in zip(a_values, b_values))
        assert await read_acc_u40(dut) == (expected_dot & 0xFFFFFFFFFF)


@cocotb.test()
async def test_pipeline_accepts_one_dot8_each_clock(dut):
    await start_and_reset(dut)
    await pulse_command(dut, CMD_CLEAR_ACC)
    await load_vectors(dut, [1] * 8, [1] * 8)
    dut.uio_in.value = CMD_DOT8_MAC
    for _ in range(4):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
    dut.uio_in.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
    assert await read_acc_u40(dut) == 32


@cocotb.test()
async def test_builtin_self_test(dut):
    await start_and_reset(dut)
    await pulse_command(dut, CMD_SELF_TEST)
    for _ in range(5):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
    await pulse_command(dut, CMD_READ_BIST)
    assert int(dut.uo_out.value) == 0xA5
