# 10101 Overlapping Sequence Detector — Mealy FSM

## Overview
A 5-state Mealy FSM implemented in SystemVerilog to detect the overlapping bit sequence `10101`.

## Features
- Overlapping sequence detection
- Asynchronous active-high reset
- Self-checking testbench
- Verified using Icarus Verilog
- Waveform inspection using Surfer

## Expected Input
`1010101`

Detects `10101` twice, including the overlapping occurrence.

## Simulation
```bash
iverilog -g2012 -Wall -o mealy.vvp rtl.sv tb.sv
vvp mealy.vvp
```
## Output from Surfer(Windows)

![Waveform](wave.png)