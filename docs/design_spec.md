# Design Specification: UART Transmitter (uart_tx)

## 1. Module Name and Description
*   **Module Name**: `uart_tx`
*   **Description**: A highly configurable, production-grade Universal Asynchronous Receiver-Transmitter (UART) Transmitter. It serializes an 8-bit parallel data input into a standard UART frame consisting of 1 Start Bit (low), 8 Data Bits (LSB first), and 1 Stop Bit (high). The baud rate is dynamically configurable via a 16-bit `prescale` input, which defines the number of clock cycles per serial bit.

## 2. Port List

| Port Name  | Direction | Width  | Description                                                                 |
| :--------- | :-------- | :----- | :-------------------------------------------------------------------------- |
| `clk`      | Input     | 1      | System clock. All operations are synchronous to the rising edge of `clk`.   |
| `rst_n`    | Input     | 1      | Active-low asynchronous reset.                                              |
| `tx_start` | Input     | 1      | Transmit start strobe. Initiates transmission when `tx_busy` is low.        |
| `data_in`  | Input     | 8      | 8-bit parallel data byte to be transmitted.                                 |
| `prescale` | Input     | 16     | Baud rate divisor (number of clock cycles per bit). Must be >= 2.           |
| `tx_out`   | Output    | 1      | Serial UART output line. Idle state is high (1).                            |
| `tx_busy`  | Output    | 1      | Status flag indicating transmission is in progress.                         |

## 3. Functional Description
The `uart_tx` module utilizes a finite state machine (FSM) to control the serialization process. 
*   **Baud Rate Generation**: An internal counter (`clk_cnt`) counts from `0` up to `prescale - 1` for each transmitted bit to establish the exact bit duration.
*   **Data Serialization**: When `tx_start` is asserted and the transmitter is idle (`tx_busy` is low), the input byte `data_in` is latched into an internal shift register.
*   **Frame Format**:
    *   **Start Bit**: The serial line `tx_out` is driven low for `prescale` clock cycles.
    *   **Data Bits**: The 8 bits of the latched data are shifted out LSB-first. Each bit is held for `prescale` clock cycles.
    *   **Stop Bit**: The serial line `tx_out` is driven high for `prescale` clock cycles.
*   **Flow Control**: The `tx_busy` signal is asserted immediately upon sampling `tx_start` and remains high until the stop bit transmission is fully complete.

## 4. Timing Diagram (ASCII)

```
           __                                                                               __
clk      _|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|
           ____
tx_start _|    |______________________________________________________________________________
          ======
data_in   = D0 ===============================================================================
                 _______________________________________________________________________
tx_busy  _______|                                                                       |_____
         ________                                                                _____________
tx_out           |_______|_______|_______|_______ ... ___|_______|_______|_______|
          IDLE   | START | D0    | D1    | D2    |    | D7    | STOP  | IDLE
                 |<--P-->|<--P-->|<--P-->|<--P-->|    |<--P-->|<--P-->|
                 P = prescale clock cycles
```

## 5. State Machine Description
The FSM consists of four states:
1.  **`ST_IDLE` (2'b00)**: The transmitter is idle. `tx_out` is held high, and `tx_busy` is low. If `tx_start` is asserted, the input data is latched, the clock counter is reset, and the FSM transitions to `ST_START`.
2.  **`ST_START` (2'b01)**: The transmitter drives `tx_out` low to signal the start bit. It remains in this state for `prescale` clock cycles. Once `clk_cnt` reaches `prescale - 1`, it resets the counter and transitions to `ST_DATA`.
3.  **`ST_DATA` (2'b10)**: The transmitter drives `tx_out` with the LSB of the shift register. It counts `prescale` clock cycles per bit. After each bit, the shift register shifts right, and `bit_cnt` increments. Once all 8 bits are transmitted (`bit_cnt == 7` and `clk_cnt == prescale - 1`), it transitions to `ST_STOP`.
4.  **`ST_STOP` (2'b11)**: The transmitter drives `tx_out` high to signal the stop bit. It remains in this state for `prescale` clock cycles. Once `clk_cnt` reaches `prescale - 1`, it transitions back to `ST_IDLE`, and `tx_busy` is deasserted.

## 6. Key Design Decisions
*   **Glitch-Free Outputs**: Both `tx_out` and `tx_busy` are fully registered outputs directly driven by flip-flops to prevent any combinational glitches on the physical serial line.
*   **Dynamic Prescaler**: Instead of hardcoding the baud rate, the `prescale` input allows the system to dynamically adjust the baud rate at runtime (e.g., switching between 9600, 115200, or custom high-speed rates).
*   **Robust Handshaking**: The module ignores `tx_start` requests while `tx_busy` is high, preventing mid-transmission corruption.