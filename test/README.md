# AXION Gen0-X RTL tests

The cocotb suite verifies reset and version behavior, every SIMD8 operation,
signed DOT8 accumulation, 40-bit readback, ReLU/saturation, `ena` state freeze,
random vectors, one-DOT8-per-cycle pipeline throughput and built-in self-test.

Run `make` from this directory in the Tiny Tapeout development container.
