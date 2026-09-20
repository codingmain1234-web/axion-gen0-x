## AXION Gen0-X

AXION Gen0-X combines an eight-lane byte-wide vector ALU with an eight-lane
signed INT8 dot-product engine. It targets a GF180 `2x2` Tiny Tapeout tile at
15.5 MHz. The theoretical peak is 124 MMAC/s after the DOT8 pipeline fills.

Data is loaded one byte at a time on `ui_in`; `uio_in` carries the command.
The output byte appears on `uo_out`. Commands `10`–`17` load A, `18`–`1F`
load B, `20`–`26` execute vector operations, and `28` starts DOT8 MAC.
Commands `30`–`37` read vector lanes and `38`–`3C` read the signed 40-bit
accumulator in little-endian byte order.

For a quick check, issue command `50`, wait at least nine clocks, then issue
`3E`. Output `A5` indicates that the real SIMD ADD and DOT8 datapaths passed
their built-in test. The version command `3F` returns `A8`.

The official RTL, GDS, precheck and gate-level workflows pass. The final die
area is 0.231396 mm². At 15.5 MHz, worst setup slack is +1.075 ns and worst
hold slack is +0.470 ns, with zero timing, final DRC, LVS and antenna
violations. This is a physically verified tapeout candidate; no fabrication
order has yet been placed.
