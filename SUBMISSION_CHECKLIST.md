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
- [ ] Cocotb RTL simulation passes in the official Tiny Tapeout container

## Physical implementation

- [ ] Official TTGF26c GDS workflow passes
- [ ] Design fits the requested GF180 `2x2` tile
- [ ] Worst-corner setup timing passes at 16 MHz
- [ ] Hold timing passes
- [ ] DRC passes
- [ ] LVS passes
- [ ] Antenna checks pass
- [ ] Gate-level simulation passes
- [ ] GDS viewer inspected manually

## Submission

- [ ] GitHub repository and project metadata reviewed
- [ ] Final source archive created
- [ ] Final GDS artifact archived
- [ ] Tiny Tapeout submission form completed
- [ ] Order placed only after every required check above passes
