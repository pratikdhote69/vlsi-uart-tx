# Design Specification: High-Performance UART Transmitter (uart_tx)

## 1. Module Name and Description
*   **Module Name**: `uart_tx`
*   **Description**: A production-grade, highly configurable Universal Asynchronous Receiver-Transmitter (UART) Transmitter. It serializes an 8-bit parallel data input into a standard UART frame format (1 start bit, 8 data bits, 1 stop bit) with a configurable baud rate generator controlled by an external prescaler.

## 2. Port List
| Port Name | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | 1 | System clock input (typically 50MHz - 100MHz) |
| `rst_n` | Input | 1 | Active-low asynchronous reset |
| `tx_start` | Input | 1 | Trigger signal to start transmission (sampled on `clk` edge) |
| `data_in` | Input | 8 | 8-bit parallel data byte to be transmitted |
| `prescale` | Input | 16 | Baud rate divisor value: $Prescale = \frac{F_{clk}}{BaudRate}$ |
| `tx_out` | Output | 1 | Serial UART output line (idle high) |
| `tx_busy` | Output | 1 | Status flag indicating transmission is in progress |

## 3. Functional Description
The `uart_tx` module accepts an 8-bit data byte and serializes it onto the `tx_out` line. 
*   **Baud Rate Generation**: The transmission speed is controlled by the `prescale` input. An internal counter (`baud_cnt`) counts from `0` to `prescale - 1` for each transmitted bit.
*   **Frame Format**: 
    *   **Idle**: `tx_out` remains high (`1'b1`).
    *   **Start Bit**: `tx_out` goes low (`1'b0`) for one bit period.
    *   **Data Bits**: 8 data bits are transmitted LSB first.
    *   **Stop Bit**: `tx_out` goes high (`1'b1`) for one bit period.
*   **Input Protection**: The `data_in` and `prescale` inputs are latched into internal registers (`data_reg` and `prescale_reg`) at the moment `tx_start` is asserted. Any changes to these inputs during transmission are safely ignored.
*   **Busy Lockout**: If `tx_start` is asserted while `tx_busy` is high, the request is ignored to prevent frame corruption.

## 4. Timing Diagram (ASCII)
```
            __                                                                     ___
clk      __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|   |__
               _________________
tx_start _____|                 |_________________________________________________________
                        ________
data_in  XXXXXXXXXXXXXX|  0x55  |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
         __________________________________________________________________________
tx_busy  ________________|                                                         |______
         _______________________                                 _________________________
tx_out                          |_______X_______X_______X_______|
         (Idle: High)           | Start | D0(1) | D1(0) | ...   | Stop  | (Idle: High)
                                <---- Prescale Cycles Per Bit ---->
```

## 5. State Machine Description
The module utilizes a highly robust, glitch-free 4-state Mealy/Moore hybrid Finite State Machine (FSM):
*   **`ST_IDLE` (2'b00)**: The transmitter is idle. `tx_out` is held high, and `tx_busy` is low. When `tx_start` is asserted, the module latches the input data and prescale values, transitions to `ST_START`, and asserts `tx_busy` and pulls `tx_out` low.
*   **`ST_START` (2'b01)**: The transmitter transmits the start bit (low). It remains in this state for `prescale` clock cycles. Upon completion, it transitions to `ST_DATA`.
*   **`ST_DATA` (2'b10)**: The transmitter serializes the 8-bit data register, LSB first. It remains in this state for $8 \times prescale$ clock cycles. An internal bit index counter (`bit_idx`) tracks the current bit. Upon transmitting the 8th bit, it transitions to `ST_STOP`.
*   **`ST_STOP` (2'b11)**: The transmitter transmits the stop bit (high). It remains in this state for `prescale` clock cycles. Upon completion, it transitions back to `ST_IDLE` and de-asserts `tx_busy`.

## 6. Key Design Decisions
1.  **Fully Synchronous Design**: All state transitions and output updates are synchronized to the rising edge of `clk` to prevent glitches.
2.  **Input Latching**: Latching `data_in` and `prescale` at the start of transmission prevents mid-flight protocol corruption if the upstream logic changes inputs prematurely.
3.  **Prescale Guarding**: The internal prescale register is guarded against values less than 2 to prevent zero-division or zero-cycle lockups in the baud counter.
4.  **Registered Outputs**: Both `tx_out` and `tx_busy` are directly driven by registers to eliminate combinational path delays and hazard glitches on the physical chip pins.