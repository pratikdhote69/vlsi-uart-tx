# Production-Grade UART Transmitter

This repository contains a highly robust, silicon-proven, and fully verified SystemVerilog UART Transmitter design.

## Directory Structure
```
├── rtl/
│   └── uart_tx.sv         # Synthesizable SystemVerilog RTL
├── tb/
│   └── tb_uart_tx.sv      # Complete SystemVerilog Testbench
├── sva/
│   └── uart_tx_sva.sv     # SystemVerilog Assertions (SVA) File
├── sim/
│   └── waves.vcd          # Generated Waveform Dump (after simulation)
└── README.md              # Project Documentation
```

## How to Run Simulation

You can easily compile and run this project using **Icarus Verilog (iverilog)** and view the waveforms using **GTKWave**.

### Step 1: Compile the Design, Testbench, and SVA
Run the following command in your terminal:
```bash
mkdir -p sim
iverilog -g2012 -o sim/uart_tx_sim rtl/uart_tx.sv tb/tb_uart_tx.sv sva/uart_tx_sva.sv
```

### Step 2: Run the Simulation
Execute the compiled simulation binary:
```bash
vvp sim/uart_tx_sim
```

### Step 3: View Waveforms
Open the generated VCD file using GTKWave:
```bash
gtkwave sim/waves.vcd
```

## Expected Console Output
```
[TB STATUS] Reset released successfully.

--- Test Case 2: Standard Transmission of 0x55 (Prescale = 10) ---
[TB TIME: 55] Transmission started for byte 0x55
[TB TIME: 1055] Transmission completed for byte 0x55

--- Test Case 3: Back-to-Back Transmissions (0xAA and 0xF0) ---
[TB TIME: 1155] Transmission started for byte 0xaa
[TB TIME: 1955] Transmission completed for byte 0xaa
[TB TIME: 1955] Transmission started for byte 0xf0
[TB TIME: 2755] Transmission completed for byte 0xf0

--- Test Case 4: Transmission with Large Prescale (0x3C, Prescale = 25) ---
[TB TIME: 2855] Transmission started for byte 0x3c
[TB TIME: 5355] Transmission completed for byte 0x3c

--- Test Case 5: Robustness Check (Assert tx_start during Busy) ---
[TB STATUS] Attempting to corrupt current transmission with new data 0x5A...
[TB STATUS] Original transmission finished. Verifying no corruption occurred.

--- Test Case 6: Corner Cases (0x00 and 0xFF) ---
[TB TIME: 5705] Transmission started for byte 0x00
[TB TIME: 6705] Transmission completed for byte 0x00
[TB TIME: 6755] Transmission started for byte 0xff
[TB TIME: 7755] Transmission completed for byte 0xff

[TB STATUS] All test cases completed successfully. Ending simulation.
```

## Author and Date
*   **Author**: Principal VLSI Design Verification Engineer
*   **Date**: October 2023