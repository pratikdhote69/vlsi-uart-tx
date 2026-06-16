# Functional Coverage Plan: UART Transmitter

## 1. Functional Coverage Points

| Coverage Point Name | Description | Target Bins / Range | Goal (%) |
| :--- | :--- | :--- | :--- |
| `cp_data_in` | Verifies that all classes of data bytes are transmitted. | `all_zeros` (0x00), `all_ones` (0xFF), `alternating_55` (0x55), `alternating_AA` (0xAA), and 4 auto-bins for other values. | 100% |
| `cp_prescale` | Verifies that different ranges of baud rates are tested. | `min_prescale` (2), `small` (3-20), `medium` (21-100), `large` (101-65535). | 100% |
| `cp_tx_start` | Verifies the stimulus density of the start trigger. | `idle` (0), `active` (1). | 100% |
| `cross_data_prescale` | Cross coverage between data patterns and prescaler values. | Cross of `cp_data_in` and `cp_prescale`. | 90% |

## 2. SystemVerilog Covergroup Definition

```systemverilog
covergroup uart_tx_cg @(posedge clk);
    option.per_instance = 1;
    option.name = "uart_tx_functional_coverage";

    // Coverpoint for Data Input
    cp_data_in: coverpoint data_in {
        bins all_zeros       = {8'h00};
        bins all_ones        = {8'hFF};
        bins alternating_55  = {8'h55};
        bins alternating_AA  = {8'hAA};
        bins general_payload[4] = {[8'h01:8'hFE]} with (!(item in {8'h55, 8'hAA}));
    }

    // Coverpoint for Prescaler Divisor
    cp_prescale: coverpoint prescale {
        bins min_prescale    = {16'd2};
        bins small_prescale  = {[16'd3:16'd20]};
        bins medium_prescale = {[16'd21:16'd100]};
        bins large_prescale  = {[16'd101:16'hFFFF]};
    }

    // Coverpoint for Start Trigger
    cp_tx_start: coverpoint tx_start {
        bins idle   = {1'b0};
        bins active = {1'b1};
    }

    // Cross Coverage
    cross_data_prescale: cross cp_data_in, cp_prescale;
endgroup
```

## 3. Corner Cases to Cover
1.  **Minimum Prescaler (`prescale = 2`)**: Verifies that the FSM can operate at maximum speed without state-skipping or timing violations.
2.  **Back-to-Back Transmission**: Verifies that `tx_start` can be asserted in the exact cycle `tx_busy` drops, ensuring zero-bubble throughput.
3.  **Start During Busy**: Verifies that asserting `tx_start` while the transmitter is active does not corrupt the current frame or trigger a premature restart.
4.  **All Zeros (0x00) and All Ones (0xFF)**: Verifies correct framing when the data payload matches the start bit (0) or stop/idle bit (1).