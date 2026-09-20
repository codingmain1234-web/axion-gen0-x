# AXION Gen0-X verification status

Final physical verification was completed on 2026-09-20. The recorded GitHub
Actions GDS run is `35499734929` for source commit `ba2a7ac`.

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
- Official Linux/Tiny Tapeout cocotb RTL workflow
- Official TTGF26c GDS build using `gf180mcuD`
- GF180 `2x2` tile fit: 0.231396 mm² die and 0.223686 mm² core
- 15.5 MHz multi-corner timing: +1.0747 ns worst setup slack and +0.4699 ns
  worst hold slack, with zero setup and hold violations
- 9,117 standard cells, 0.191768 mm² standard-cell area and 85.7308%
  utilization
- Final routing DRC: 0; Magic DRC: 0
- LVS errors, unmatched devices, nets and pins: 0
- Antenna violations: 0
- Tiny Tapeout precheck: all 12 reported checks passed
- Gate-level cocotb: all 7 test cases passed
- GDS render manually inspected
- Estimated total power: 24.4 mW under the build tool's activity/model
  assumptions; this is an estimate, not a measured silicon value

## Remaining external steps

- Submit the project through the applicable Tiny Tapeout shuttle process
- Place and pay for the fabrication order
- Test the packaged silicon when delivered

GEN0-X v0.1 is a physically verified tapeout candidate. Fabrication has not
yet been ordered.
