# AXION Gen0-X

AXION Gen0-X is an eight-lane compute prototype for the Tiny Tapeout TTGF26c
shuttle. It doubles the lane count and theoretical INT8 MAC throughput of
Gen0-P while keeping a small command-driven interface suitable for first
silicon experiments.

## Signoff specification

- GF180MCU (`gf180mcuD`) process through Tiny Tapeout TTGF26c
- `2x2` tile allocation; final die area 0.231396 mm²
- 15.5 MHz signoff target; 16 MHz and above are post-signoff experiments
- Eight SIMD8 V-Core lanes
- Eight shared signed INT8 multipliers
- Pipelined signed DOT8 MAC with a 40-bit accumulator
- Registered command predecode; external commands execute one cycle later
- One DOT8 accepted per cycle after pipeline fill
- 124 MMAC/s theoretical peak at 15.5 MHz
- ReLU with signed INT8 saturation and an on-chip self-test

## Commands

| Command | Function |
|---|---|
| `10`–`17` | Load A lanes 0–7 |
| `18`–`1F` | Load B lanes 0–7 |
| `20` | SIMD ADD |
| `21` | SIMD SUB |
| `22` | SIMD MUL, low 8 bits |
| `23` | SIMD AND |
| `24` | SIMD XOR |
| `25` | SIMD unsigned MAX |
| `26` | SIMD unsigned MIN |
| `28` | Signed INT8 DOT8 MAC |
| `30`–`37` | Read vector lanes 0–7 |
| `38`–`3C` | Read accumulator bytes 0–4, little-endian |
| `3D` | Read ReLU/saturated output |
| `3E` | Read BIST status |
| `3F` | Read version (`A8`) |
| `40` | Clear accumulator and pending MACs |
| `50` | Start built-in self-test |

The eight-bit data bus is `ui_in`; commands are supplied on `uio_in`; results
are returned on `uo_out`. The bidirectional outputs are disabled.

## Verification

Run the executable mathematical model with:

```text
python REFERENCE_MODEL.py
```

Run RTL tests in the Tiny Tapeout development container with:

```text
cd test
make
```

The official GitHub workflows have passed RTL simulation, GDS generation,
Tiny Tapeout precheck and gate-level simulation. The final 15.5 MHz build has
1.075 ns worst setup slack, 0.470 ns worst hold slack, zero timing violations,
zero final routing/Magic DRC errors, zero LVS errors and zero antenna
violations. The layout contains 9,117 standard cells at 85.73% utilization.

These results make v0.1 a physically verified tapeout candidate. They do not
mean that a Tiny Tapeout submission or fabrication order has been placed.

See `ARCHITECTURE.md`, `HARDWARE_TEST.md` and `SUBMISSION_CHECKLIST.md` for
implementation and tapeout details.
