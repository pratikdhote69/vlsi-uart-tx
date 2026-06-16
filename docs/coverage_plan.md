# Functional Coverage Plan: UART Transmitter

## 1. Functional Coverage Points

| Coverage Item ID | Description | Bin Definitions / Corner Cases | Target % |
| :--- | :--- | :--- | :--- |
| **CP_DATA_IN** | Coverage of the parallel input data byte | - `all_zeros` (8'h00)<br>- `all_ones` (8'hFF)<br>- `alternating_0` (8'h55)<br>- `alternating_1` (8'hAA)<br>- `walking_ones` (one-hot patterns)<br>- `others` (standard distribution) | 100% |
| **CP_PRESCALE** | Coverage of the baud rate divisor values | - `min_scale` (2 to 8)<br>- `mid_scale` (9 to 100)<br>- `max_scale` (> 100) | 100% |
| **CP_TX_START** | Coverage of start trigger conditions | - `start_while_idle` (valid start)<br>- `start_while_busy` (ignored start) | 100% |
| **CR_DATA_X_PRESCALE** | Cross coverage of data patterns and prescale values | Cross of `CP_DATA_IN` and `CP_PRESCALE` | 90% |

## 2. SystemVerilog Covergroup Definition

```systemverilog
covergroup cg_uart_tx @(posedge clk);
    option.per_instance = 1;
    option.goal = 100;

    // Coverpoint for input data patterns
    cp_data: coverpoint data_in {
        bins all_zeros     = {8'h00};
        bins all_ones      = {8'hFF};
        bins alternating_a = {8'h55};
        bins alternating_b = {8'hAA};
        bins walking_ones[] = {8'h01, 8'h02, 8'h04, 8'h08, 8'h10, 8'h20, 8'h40, 8'h80};
        bins others        = default;
    }

    // Coverpoint for prescale configurations
    cp_prescale: coverpoint prescale {
        bins min_scale = {[2:8]};
        bins mid_scale = {[9:100]};
        bins max_scale = {[101:65535]};
    }

    // Coverpoint for start signal behavior
    cp_start: coverpoint tx_start {
        bins asserted = {1'b1};
        bins deasserted = {1'b0};
    }

    // Cross coverage to ensure different data patterns are tested across different baud rates
    cross_data_prescale: cross cp_data, cp_prescale;
endgroup
```

## 3. Corner Cases to Cover
1.  **Minimum Prescale Value**: Running with `prescale = 2` (highest speed, shortest bit period).
2.  **Maximum Prescale Value**: Running with `prescale = 65535` (slowest speed, longest bit period).
3.  **Rogue Start Strobe**: Asserting `tx_start` exactly one clock cycle before the current transmission finishes to verify that the FSM transitions correctly without dropping or corrupting the next frame.