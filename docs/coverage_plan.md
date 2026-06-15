## Functional Coverage Points
| Coverage Point | Description | Type |
| --- | --- | --- |
| tx_data | Transmitted data | coverpoint |
| tx_valid | Data valid signal | coverpoint |
| tx_ready | Transmitter ready signal | coverpoint |
| tx_out | Transmitted serial data | coverpoint |
| reset | Reset signal | coverpoint |

## Covergroup Definitions
```systemverilog
covergroup cg;
    coverpoint tx_data;
    coverpoint tx_valid;
    coverpoint tx_ready;
    coverpoint tx_out;
    coverpoint reset;
endgroup
```

## Coverage Goals
- Achieve 100% coverage for `tx_data` and `tx_valid` coverpoints
- Achieve 90% coverage for `tx_ready` and `tx_out` coverpoints
- Achieve 80% coverage for `reset` coverpoint

## Corner Cases to Cover
- Sending a byte with invalid data
- Sending a byte after reset
- Sending multiple bytes
- Resetting the transmitter during transmission