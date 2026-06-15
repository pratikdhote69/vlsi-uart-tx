# AI VLSI Factory — Generation Report

**Module:** `uart_tx`  
**Request:** Create a UART Transmitter  
**Generated:** 2026-06-15 10:46:49  

---

## File Validation

| File | Status | Detail |
|---|---|---|
| `README.md` | ✅ PASS | OK |
| `docs\coverage_plan.md` | ✅ PASS | OK |
| `docs\design_spec.md` | ✅ PASS | OK |
| `docs\generation_report.md` | ✅ PASS | OK |
| `rtl\uart_tx.sv` | ✅ PASS | OK |
| `sva\uart_tx_sva.sv` | ✅ PASS | OK |
| `tb\uart_tx_tb.sv` | ✅ PASS | OK |

## Simulation Results

**Status:** ✅ PASSED  
**Auto-fix attempts:** 0  

### Simulation Output
```
VCD info: dumpfile C:/Users/prati/Desktop/AI_VLSI_FACTORY/output/uart_tx/sim/waves.vcd opened for output.
Test case 1: Sent 0x05
Test case 2: Sent 0x0a
Test case 3: Sent 0xff
Test case 4: Sent 0x14 after reset
Test case 5: Sent multiple bytes
C:\Users\prati\Desktop\AI_VLSI_FACTORY\output\uart_tx\tb\uart_tx_tb.sv:62: $finish called at 410000 (1ps)

```

### Errors
```
COMPILE ERRORS:
C:\Users\prati\Desktop\AI_VLSI_FACTORY\output\uart_tx\rtl\uart_tx.sv:27: sorry: constant selects in always_* processes are not currently supported (all bits will be included).

```

## Generated Files

- `docs\coverage_plan.md` (896 bytes)
- `docs\design_spec.md` (1984 bytes)
- `docs\generation_report.md` (1204 bytes)
- `README.md` (804 bytes)
- `rtl\uart_tx.sv` (4332 bytes)
- `sim\sim.vvp` (8405 bytes)
- `sim\waves.gtkw` (470 bytes)
- `sim\waves.vcd` (2871 bytes)
- `sva\uart_tx_sva.sv` (1585 bytes)
- `tb\uart_tx_tb.sv` (1577 bytes)

## How to Run

```bash
# Compile
iverilog -g2012 -o sim/sim.vvp rtl/uart_tx.sv tb/uart_tx_tb.sv

# Simulate
vvp sim/sim.vvp
```
