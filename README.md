# TINY-TPU

### Overview

**Tiny TPU** is a small-scale, FPGA-based implementation of Google's *Tensor Processing Unit*. The goal of this project was to learn about the end-to-end technicalities of accelerator design from hardware to software, while deciphering the lower level intricacies of Google's proprietary technology. In doing so, we explored the possibility of a small scale, low power TPU.

A more detailed report is located in `/docs/report/report.pdf`.

### Current Status

The TPU currently doesn't have all of the hardware validated, but is close to having a complete instruction decoder for an instruction set, as well as functional accumulator tables for large matrix multiplication. Right now it can only do up to 16x16 matrix multiplication.

### Synthesizing and Programming onto an FPGA

The stable version is the latest commit on the `synthesis` branch, as `master` is left open to continue progress on the project. This project was synthesized on Quartus 15.0 and programmed onto an Altera DE1-SoC FPGA. No other setup is guaranteed to work. Synthesis requires the necessary Cyclone V libraries to use the IP blocks instantiated in the Verilog.

The Verilog files for synthesis are located in `/hardware/synthesis` and the Verilog files are located in `/hardware/hdl`.
