## AXION Gen0-X

AXION Gen0-X combines an eight-lane byte-wide vector ALU with an eight-lane
signed INT8 dot-product engine. It targets a GF180 `2x2` Tiny Tapeout tile at
16 MHz. The theoretical peak is 128 MMAC/s after the DOT8 pipeline fills.

Data is loaded one byte at a time on `ui_in`; `uio_in` carries the command.
The output byte appears on `uo_out`. Commands `10`–`17` load A, `18`–`1F`
load B, `20`–`26` execute vector operations, and `28` starts DOT8 MAC.
Commands `30`–`37` read vector lanes and `38`–`3C` read the signed 40-bit
accumulator in little-endian byte order.

For a quick check, issue command `50`, wait at least nine clocks, then issue
`3E`. Output `A5` indicates that the real SIMD ADD and DOT8 datapaths passed
their built-in test. The version command `3F` returns `A8`.

This page describes an RTL candidate. Final tile fit, timing and fabrication
readiness depend on successful GDS, precheck and gate-level workflows.
