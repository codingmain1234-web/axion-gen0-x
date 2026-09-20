# AXION Gen0-X

AXION Gen0-X is an eight-lane compute prototype for the Tiny Tapeout TTGF26c
shuttle. It doubles the lane count and theoretical INT8 MAC throughput of
Gen0-P while keeping a small command-driven interface suitable for first
silicon experiments.

## Target specification

- GF180MCU (`gf180mcuD`) process through Tiny Tapeout TTGF26c
- `2x2` tile allocation, approximately 0.22 mm² before final GDS measurement
- 16 MHz implementation target; 20 MHz is a post-signoff experiment only
- Eight SIMD8 V-Core lanes
- Eight shared signed INT8 multipliers
- Pipelined signed DOT8 MAC with a 40-bit accumulator
- Registered command predecode; external commands execute one cycle later
- One DOT8 accepted per cycle after pipeline fill
- 128 MMAC/s theoretical peak at 16 MHz
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

The GitHub workflows run RTL simulation, GDS generation, precheck and
gate-level simulation. Physical fit, timing and signoff are intentionally not
claimed until those workflows produce a successful Gen0-X build.

See `ARCHITECTURE.md`, `HARDWARE_TEST.md` and `SUBMISSION_CHECKLIST.md` for
implementation and tapeout details.
