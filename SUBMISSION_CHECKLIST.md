# AXION Gen0-X submission checklist

## RTL and functional verification

- [x] Eight-lane SIMD RTL implemented
- [x] Eight signed INT8 multipliers and DOT8 pipeline implemented
- [x] Signed 40-bit accumulator, ReLU and saturation implemented
- [x] Built-in self-test implemented
- [x] Executable Python reference model created
- [x] Cocotb tests cover all vector operations, random DOT8, pipeline
  throughput, reset, enable and BIST
- [x] Yosys sequential SAT smoke checks pass for version, SIMD ADD,
  pipelined DOT8 throughput and BIST
- [x] Local Yosys hierarchy, latch, structural and full synthesis checks pass
- [x] Cocotb RTL simulation passes in the official Tiny Tapeout container

## Physical implementation

- [x] Official TTGF26c GDS workflow passes
- [x] Design fits the requested GF180 `2x2` tile
- [x] Worst-corner setup timing passes at 15.5 MHz
- [x] Hold timing passes
- [x] DRC passes
- [x] LVS passes
- [x] Antenna checks pass
- [x] Gate-level simulation passes
- [x] GDS viewer inspected manually

## Submission

- [x] GitHub repository and project metadata reviewed
- [x] Final source archive created for the v0.1 release
- [x] Final GDS artifact archived from Actions run `35499734929`
- [ ] Tiny Tapeout submission form completed
- [ ] Order placed only after every required check above passes
