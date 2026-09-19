"""Executable reference model for AXION Gen0-X."""

from __future__ import annotations

import random


ACC_BITS = 40
ACC_MASK = (1 << ACC_BITS) - 1


def u8(value: int) -> int:
    return value & 0xFF


def s8(value: int) -> int:
    value &= 0xFF
    return value - 256 if value & 0x80 else value


def s40(value: int) -> int:
    value &= ACC_MASK
    return value - (1 << ACC_BITS) if value & (1 << (ACC_BITS - 1)) else value


def lane_op(op: int, a: int, b: int) -> int:
    a, b = u8(a), u8(b)
    operations = {
        0: lambda: u8(a + b),
        1: lambda: u8(a - b),
        2: lambda: u8(a * b),
        3: lambda: a & b,
        4: lambda: a ^ b,
        5: lambda: max(a, b),
        6: lambda: min(a, b),
    }
    return operations[op]()


class Gen0XModel:
    def __init__(self) -> None:
        self.a = [0] * 8
        self.b = [0] * 8
        self.vector_result = [0] * 8
        self.acc = 0

    def vector(self, op: int) -> list[int]:
        self.vector_result = [lane_op(op, a, b) for a, b in zip(self.a, self.b)]
        return self.vector_result.copy()

    def clear_acc(self) -> None:
        self.acc = 0

    def dot8_mac(self) -> int:
        dot = sum(s8(a) * s8(b) for a, b in zip(self.a, self.b))
        self.acc = s40(self.acc + dot)
        return self.acc

    def relu_sat(self) -> int:
        return 0 if self.acc < 0 else min(self.acc, 127)

    def acc_bytes(self) -> list[int]:
        raw = self.acc & ACC_MASK
        return [(raw >> (8 * index)) & 0xFF for index in range(5)]


def run_checks() -> None:
    model = Gen0XModel()
    model.a = list(range(1, 9))
    model.b = list(range(8, 0, -1))
    assert model.dot8_mac() == 120
    assert model.relu_sat() == 120
    assert model.dot8_mac() == 240
    assert model.relu_sat() == 127

    rng = random.Random(0xA710)
    for _ in range(100_000):
        model.a = [rng.randrange(256) for _ in range(8)]
        model.b = [rng.randrange(256) for _ in range(8)]
        op = rng.randrange(7)
        assert model.vector(op) == [
            lane_op(op, a, b) for a, b in zip(model.a, model.b)
        ]
        model.clear_acc()
        expected = sum(s8(a) * s8(b) for a, b in zip(model.a, model.b))
        assert model.dot8_mac() == expected

    model.a = [0xFC] + [0] * 7
    model.b = [2] + [0] * 7
    model.clear_acc()
    assert model.dot8_mac() == -8
    assert model.relu_sat() == 0
    assert model.acc_bytes() == [0xF8, 0xFF, 0xFF, 0xFF, 0xFF]
    print("AXION Gen0-X reference checks passed (100,000 random cases)")


if __name__ == "__main__":
    run_checks()
