# UART Transmitter (uart_tx) Project

This repository contains a production-ready, highly configurable SystemVerilog UART Transmitter design with a comprehensive verification suite, including SystemVerilog Assertions (SVA) and a functional coverage plan.

## Directory Structure
```
├── rtl/
│   └── uart_tx.sv         # Synthesizable SystemVerilog RTL
├── tb/
│   └── tb_uart_tx.sv      # SystemVerilog Testbench
├── sva/
│   └── uart_tx_sva.sv     # SystemVerilog Assertions (SVA) file
├── sim/
│   └── waves.vcd          # Generated simulation waveform file (after run)
└── README.md              # Project documentation
```

## How to Run Simulation

You can easily compile and run the simulation using **Icarus Verilog (iverilog)** and view the waveforms using **GTKWave**.

### Step 1: Compile the Design, SVA, and Testbench
Run the following command in your terminal:
```bash
mkdir -p sim
iverilog -g2012 -o sim/uart_tx_tb.vvp rtl/uart_tx.sv sva/uart_tx_sva.sv tb/tb_uart_tx.sv
```

### Step 2: Run the Simulation
Execute the compiled simulation file:
```bash
vvp sim/uart_tx_tb.vvp
```

### Step 3: View Waveforms
Open the generated VCD file using GTKWave:
```bash
gtkwave sim/waves.vcd
```

## Expected Output
When running the simulation, you should see the following console output:
```text
--- TEST CASE 1: Reset Sequence ---
PASS: Reset state verified successfully.

--- TEST CASE 2: Transmitting 8'h55 (Alternating Bits) ---
[TB TIME: 70000] Initiated TX of 8'h55 with prescale 8

--- TEST CASE 3: Transmitting 8'hAA (Alternating Bits) ---
[TB TIME: 970000] Initiated TX of 8'haa with prescale 8

--- TEST CASE 4: Transmitting 8'hF0 with Prescale = 12 ---
[TB TIME: 1870000] Initiated TX of 8'hf0 with prescale 12

--- TEST CASE 5: Back-to-Back Transmission (0x3C then 0xC3) ---
[TB TIME: 3170000] Initiated TX of 8'h3c with prescale 8
[TB TIME: 4070000] Initiated TX of 8'hc3 with prescale 8

--- TEST CASE 6: Robustness Check (Ignore tx_start during active transmission) ---
[TB TIME: 5170000] Initiated TX of 8'hff with prescale 16
[TB TIME: 5210000] Attempted rogue tx_start during active transmission.

All test cases completed successfully.
```

## Author and Date
*   **Author**: Principal VLSI Design Verification Engineer
*   **Date**: October 2023