# Design Specification: Configurable UART Transmitter (uart_tx)

## 1. Module Name and Description
*   **Module Name**: `uart_tx`
*   **Description**: A highly robust, fully parameterizable, and synthesizable Universal Asynchronous Receiver-Transmitter (UART) Transmitter. It features a configurable baud rate generator, support for 8-bit data transmission, 1 start bit, and 1 stop bit. The design is optimized for high-frequency ASIC/FPGA synthesis and includes comprehensive SystemVerilog Assertions (SVA) for protocol compliance.

## 2. Port List
| Port Name | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | 1 | System clock input (e.g., 50MHz/100MHz) |
| `rst_n` | Input | 1 | Asynchronous active-low reset |
| `tx_start` | Input | 1 | Trigger signal to start transmission (ignored if busy) |
| `tx_data` | Input | 8 | 8-bit data payload to be transmitted |
| `baud_limit` | Input | 16 | Baud rate divisor limit: `baud_limit = (clk_freq / baud_rate) - 1` |
| `tx_out` | Output | 1 | Serial UART output line (defaults to high/idle) |
| `tx_busy` | Output | 1 | Status flag indicating transmission is in progress |

## 3. Functional Description
The `uart_tx` module converts an 8-bit parallel data byte into a serial stream conforming to the standard RS-232 UART protocol. 

### Key Features:
*   **Configurable Baud Rate**: The transmission speed is controlled dynamically via the `baud_limit` input port, allowing runtime configuration of standard baud rates (e.g., 9600, 115200, 921600) based on the system clock frequency.
*   **Glitch-Free Outputs**: All outputs (`tx_out`, `tx_busy`) are registered directly from flip-flops to prevent combinational glitches.
*   **Robust Handshaking**: The `tx_busy` signal is asserted immediately upon accepting a transmission request and remains high until the stop bit is fully transmitted. Any assertions of `tx_start` during this period are safely ignored.

## 4. Timing Diagram (ASCII)
Below is the timing diagram for transmitting the byte `8'h55` (binary `01010101`, LSB first: `1, 0, 1, 0, 1, 0, 1, 0`) with a `baud_limit` of N clock cycles.

```
            __   _______________________________________________________________
clk      __|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_
            ____
tx_start __|    |_______________________________________________________________
         _______ _______________________________________________________________
tx_data  _______X___________________________8'h55_______________________________
                 _______________________________________________________
tx_busy  _______|                                                       |_______
         _______                                 _______________________ _______
tx_out          |_______|_______|_______|_______|_______|_______|_______|
          IDLE   START   D0(1)   D1(0)   D2(1)   D3(0)   ...     STOP    IDLE
                 |<--N-->|
```

## 5. State Machine Description
The transmitter is governed by a 4-state Mealy/Moore hybrid Finite State Machine (FSM):

1.  **`IDLE` (2'b00)**:
    *   The transmitter is idle. `tx_out` is held high (logic 1). `tx_busy` is low.
    *   If `tx_start` is asserted, the input `tx_data` is latched into an internal shift register, `tx_busy` is asserted, and the FSM transitions to the `START` state.
2.  **`START` (2'b01)**:
    *   `tx_out` is driven low (logic 0) to signal the start bit.
    *   The baud counter counts up to `baud_limit`. Upon reaching the limit, the FSM transitions to the `DATA` state.
3.  **`DATA` (2'b10)**:
    *   `tx_out` is driven by the LSB of the shift register (`shift_reg[0]`).
    *   At each `baud_tick` (when the baud counter reaches `baud_limit`), the shift register shifts right by 1 bit, and the bit counter increments.
    *   Once all 8 bits (D0 to D7) are transmitted, the FSM transitions to the `STOP` state.
4.  **`STOP` (2'b11)**:
    *   `tx_out` is driven high (logic 1) to signal the stop bit.
    *   The baud counter counts up to `baud_limit`. Upon reaching the limit, `tx_busy` is deasserted, and the FSM transitions back to `IDLE`.

## 6. Key Design Decisions
*   **Single-Clock Synchronous Design**: All registers are updated on the rising edge of `clk` with an asynchronous active-low reset `rst_n` to match standard industry cell libraries.
*   **Dynamic Baud Rate**: Instead of hardcoding the baud rate using parameters, the `baud_limit` input allows the same IP block to be reused across different clock domains and baud rate requirements without recompilation.
*   **LSB-First Transmission**: Standard UART protocol dictates that the Least Significant Bit (LSB) is transmitted first. The internal shift register is designed to shift right, naturally presenting the LSB to the output pin.