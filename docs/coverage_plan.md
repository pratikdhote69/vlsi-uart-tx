# Functional Coverage Plan: UART Transmitter

## 1. Functional Coverage Points
The verification strategy requires tracking both control and data paths to ensure high-quality verification closure.

| Coverage Point ID | Description | Target / Bin Definition | Goal (%) |
| :--- | :--- | :--- | :--- |
| `CP_TX_DATA` | Transmitted data byte values | Bins for `0x00`, `0xFF`, `0x55`, `0xAA`, and walking ones/zeros | 100% |
| `CP_BAUD_LIMIT` | Configured baud rate limits | Bins for fast (<=10), medium (11-50), and slow (>50) | 100% |
| `CP_STATE_TRANS` | FSM State Transitions | IDLE->START, START->DATA, DATA->STOP, STOP->IDLE | 100% |
| `CR_DATA_X_BAUD` | Cross of data values and baud rates | Cross of `CP_TX_DATA` and `CP_BAUD_LIMIT` | 90% |

## 2. SystemVerilog Covergroup Definition
The following covergroup is designed to be instantiated inside the testbench or verification environment to monitor coverage dynamically:

```systemverilog
covergroup uart_tx_cg @(posedge clk);
    option.per_instance = 1;
    option.goal = 100;

    // Coverpoint for Transmitted Data
    cp_tx_data: coverpoint tx_data {
        bins all_zeros       = {8'h00};
        bins all_ones        = {8'hFF};
        bins alternating_55  = {8'h55};
        bins alternating_AA  = {8'hAA};
        bins data_range_low  = {[8'h01 : 8'h7F]};
        bins data_range_high = {[8'h80 : 8'hFE]};
    }

    // Coverpoint for Baud Rate Divisor
    cp_baud_limit: coverpoint baud_limit {
        bins fast_baud   = {[16'd2  : 16'd10]};
        bins medium_baud = {[16'd11 : 16'd100]};
        bins slow_baud   = {[16'd101 : 16'd1000]};
    }

    // Coverpoint for FSM State Transitions
    cp_state_transitions: coverpoint state {
        bins idle_to_start = (2'b00 => 2'b01);
        bins start_to_data = (2'b01 => 2'b10);
        bins data_to_stop  = (2'b10 => 2'b11);
        bins stop_to_idle  = (2'b11 => 2'b00);
    }

    // Cross Coverage to ensure different data patterns are tested across different speeds
    cross_data_x_baud: cross cp_tx_data, cp_baud_limit;
endgroup
```

## 3. Corner Cases to Cover
1.  **Minimum Baud Limit**: Operating with `baud_limit = 1` or `2` (highest speed limits).
2.  **Back-to-Back Transmission**: Triggering `tx_start` on the exact clock cycle that `tx_busy` drops to 0.
3.  **Spurious Start**: Asserting `tx_start` during an active transmission to verify it is ignored and does not corrupt the current transfer.
4.  **Reset Recovery**: Asserting reset mid-transmission and verifying immediate recovery to the IDLE state.