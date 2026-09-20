# AXION Gen0-X Hardware Test

## Basic bring-up

1. Supply the Tiny Tapeout board normally and select the Gen0-X project.
2. Start at a low clock such as 100 kHz and assert reset for at least two
   rising edges.
3. Release reset, set `ena=1`, send command `3F`, and confirm output `A8`.
4. Send command `50`, wait at least nine clocks, send `3E`, and confirm `A5`.

## SIMD8 test

Load A lanes using commands `10`–`17` and B lanes with `18`–`1F`. Send `20`
for ADD, then read commands `30`–`37`. For A=`[1..8]` and B=`[8..1]`, every
result lane must be `09`.

## DOT8 test

1. Send `40` to clear the accumulator.
2. Load A=`[1,2,3,4,5,6,7,8]` and B=`[8,7,6,5,4,3,2,1]`.
3. Send `28`, wait five more rising edges, then send `3D`. Output must be 120.
4. Read commands `38`–`3C`; the five little-endian bytes must encode 120.
5. Repeat `28`; the full accumulator must become 240 while ReLU output is 127.

For a signed test, clear and load A lane 0=`FC` (-4), B lane 0=`02`, and all
other lanes zero. DOT8 must produce accumulator bytes
`F8 FF FF FF FF`, while ReLU returns zero.

## Characterization

Repeat BIST and DOT8 loops at increasing clock rates: 0.1, 1, 5, 10 and
15.5 MHz. Only after 15.5 MHz is stable across expected voltage and temperature
should 16 MHz or higher be tried. Those higher clocks are experiments, not the
signoff guarantee.
