# AXION Gen0-X verification status

Local verification was performed on 2026-09-19.

## Passed

- Python reference model: 100,000 randomized SIMD8 and signed DOT8 cases
- Python syntax checks for the reference model and cocotb suite
- JSON and YAML project metadata parsing
- Verilog-2005 parsing of all five RTL source files
- Top-level hierarchy and unresolved-module check
- Latch check: no unintended latch inferred
- Structural check: zero Yosys problems and eight multiplier cells
- Full generic synthesis with `check -assert`
- Sequential SAT smoke proof for version response `A8`
- Sequential SAT smoke proof for SIMD lane ADD
- Sequential SAT smoke proof for four consecutive DOT8 commands; final
  accumulator result confirms one accepted command per cycle
- Sequential SAT smoke proof for the built-in self-test result `A5`

## Still required before fabrication

- Cocotb RTL test in the official Linux/Tiny Tapeout environment
- Official TTGF26c GDS build using `gf180mcuD`
- `2x2` area and routing-congestion result
- 16 MHz setup and hold signoff at all required corners
- DRC, LVS, antenna and Tiny Tapeout precheck
- Gate-level simulation and manual GDS viewer inspection

GEN0-X is therefore a locally synthesized RTL candidate, not yet a
fabrication-approved design.
