# AXION Gen0-X Architecture

## Datapath

```text
A register: 8 x 8-bit ─┬─> SIMD8 V-Core ─> 8 x 8-bit result
B register: 8 x 8-bit ─┘
                        └─> 8 signed INT8 multipliers
                              └─> four 17-bit pair sums
                                   └─> two 18-bit half sums
                                        └─> one 19-bit DOT8 sum
                                             └─> signed 40-bit accumulator
                                                  └─> ReLU / INT8 saturation
```

The external command and its data are first captured by a registered
predecode stage. The multiplier bank is shared by vector MUL-low and the
SA-Core. Vector operations are combinational and captured in a 64-bit result
register. The SA-Core has five logical stages: product capture, pair
reduction, half reduction, DOT8 capture and accumulation.

After filling the pipeline, it accepts one DOT8 every clock. At 15.5 MHz this
is eight MACs per clock or a theoretical 124 MMAC/s. A single external command
becomes visible in the accumulator after six rising clock edges including its
command-capture edge.

## Numeric behavior

- SIMD ADD, SUB and MUL-low wrap to eight bits per lane.
- MAX and MIN compare unsigned lane values.
- DOT8 interprets A and B lanes as signed two's-complement INT8.
- The accumulator wraps as a signed 40-bit value.
- ReLU returns zero for negative values, the accumulator value for 0–127 and
  127 for larger positive values.
- Clearing the accumulator also invalidates all pending pipeline entries.

## Clock and reset

The signoff target is 15.5 MHz (`64.516129 ns`). State-holding blocks use the
dedicated asynchronous reset pins of their standard cells. The testbench holds
`rst_n` low for at least two rising edges and only releases it while the clock
is running. A 16 MHz clock remains a post-signoff hardware experiment.

## Built-in self-test

Command `50` loads A=`[1,2,3,4,5,6,7,8]` and
B=`[8,7,6,5,4,3,2,1]`, clears the accumulator, executes SIMD ADD and DOT8,
then checks for eight lanes of `09` and an accumulator value of 120. Status
`A5` means pass, `5A` means fail and `01` means running.
