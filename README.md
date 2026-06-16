# Project: Configurable UART Transmitter (uart_tx)

This repository contains a production-ready, highly parameterizable, and fully verified Silicon-grade UART Transmitter IP designed in SystemVerilog.

## Directory Structure
```
uart_tx/
├── rtl/
│   └── uart_tx.sv         # Synthesizable SystemVerilog RTL
├── tb/
│   └── tb_uart_tx.sv      # Comprehensive Testbench
├── sva/
│   └── uart_tx_sva.sv     # SystemVerilog Assertions & Bind File
└── sim/
    └── waves.vcd          # Generated Waveform Dump (after simulation)
```

## How to Run Simulation
The design can be compiled and simulated using any standard IEEE SystemVerilog 2012 compliant simulator (e.g., ModelSim, VCS, Questa, or Icarus Verilog).

### Using Icarus Verilog (v11 or newer):
1. Create the simulation directory:
   ```bash
   mkdir -p sim
   ```
2. Compile the RTL, SVA, and Testbench files:
   ```bash
   iverilog -g2012 -o sim/uart_tx_sim rtl/uart_tx.sv sva/uart_tx_sva.sv tb/tb_uart_tx.sv
   ```
3. Run the simulation:
   ```bash
   vvp sim/uart_tx_sim
   ```
4. View Waveforms using GTKWave:
   ```bash
   gtkwave sim/waves.vcd
   ```

## Expected Simulation Output
Upon running the simulation, you should see the following console output confirming all test cases passed:

```
[TB_START] Starting UART Transmitter Verification...
[TC1] Verifying Reset and Idle State...
[SUCCESS] TC1 Passed.
[TC2] Transmitting Alternating Pattern 0x55 (01010101)...
[SUCCESS] TC2 Completed.
[TC3] Transmitting Alternating Pattern 0xAA (10101010)...
[SUCCESS] TC3 Completed.
[TC4] Verifying Back-to-Back Transmissions (0x3C then 0xC3)...
[SUCCESS] TC4 Completed.
[TC5] Transmitting 0xFF with slower Baud Rate (baud_limit = 20)...
[SUCCESS] TC5 Completed.
[TC6] Verifying tx_start is ignored during active transmission...
[TC6] Injecting spurious tx_start = 1 while busy...
[SUCCESS] TC6 Completed.
[TB_FINISHED] All test cases executed successfully.
```

## Author and Date
*   **Author**: Pratik dhote
*   **Date**: 15-6-2025
*   
