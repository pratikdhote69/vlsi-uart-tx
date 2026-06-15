# UART Transmitter Project
## Project Description
This project implements a UART transmitter module that sends serial data to an external device.

## Directory Structure
- `rtl`: Contains the synthesizable SystemVerilog RTL code
- `tb`: Contains the testbench code
- `sva`: Contains the SystemVerilog Assertions code
- `coverage`: Contains the coverage plan and covergroup definitions

## How to Run Simulation
To run the simulation, use the following Icarus Verilog commands:
```bash
iverilog -o sim/uart_tx_tb.vvp uart_tx_tb.sv
vvp sim/uart_tx_tb.vvp
```
## Expected Output
The simulation will generate a VCD waveform dump file `sim/waves.vcd` that can be viewed using a waveform viewer such as GTKWave.

## Author and Date
This project was created by [Your Name] on [Today's Date].