# AI VLSI Factory — Generation Report

**Module:** `uart_tx`  
**Request:** Create a UART Transmitter  
**Generated:** 2026-06-16 10:28:32  

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

--- TEST CASE 1: Reset Sequence ---
PASS: Reset state verified successfully.

--- TEST CASE 2: Transmitting 8'h55 (Alternating Bits) ---
[TB TIME: 85000] Initiated TX of 8'h55 with prescale 8

--- TEST CASE 3: Transmitting 8'hAA (Alternating Bits) ---
[TB TIME: 1005000] Initiated TX of 8'haa with prescale 8

--- TEST CASE 4: Transmitting 8'hF0 with Prescale = 12 ---
[TB TIME: 1925000] Initiated TX of 8'hf0 with prescale 12

--- TEST CASE 5: Back-to-Back Transmission (0x3C then 0xC3) ---
[TB TIME: 3245000] Initiated TX of 8'h3c with prescale 8
[TB TIME: 4075000] Initiated TX of 8'hc3 with prescale 8

--- TEST CASE 6: Robustness Check (Ignore tx_start during active transmission) ---
[TB TIME: 5095000] Initiated TX of 8'hff with prescale 16
[TB TIME: 5145000] Attempted rogue tx_start during active transmission.

All test cases completed successfully.
C:\Users\prati\Desktop\AI_VLSI_FA
```

### Errors
```
COMPILE ERRORS:
C:\Users\prati\Desktop\AI_VLSI_FACTORY\output\uart_tx\rtl\uart_tx.sv:50: sorry: constant selects in always_* processes are not currently supported (all bits will be included).
C:\Users\prati\Desktop\AI_VLSI_FACTORY\output\uart_tx\rtl\uart_tx.sv:50: sorry: constant selects in always_* processes are not currently supported (all bits will be included).

```

## Generated Files

- `.git\config` (351 bytes)
- `.git\description` (73 bytes)
- `.git\HEAD` (23 bytes)
- `.git\hooks\applypatch-msg.sample` (478 bytes)
- `.git\hooks\commit-msg.sample` (896 bytes)
- `.git\hooks\fsmonitor-watchman.sample` (4726 bytes)
- `.git\hooks\post-update.sample` (189 bytes)
- `.git\hooks\pre-applypatch.sample` (424 bytes)
- `.git\hooks\pre-commit.sample` (1649 bytes)
- `.git\hooks\pre-merge-commit.sample` (416 bytes)
- `.git\hooks\pre-push.sample` (1374 bytes)
- `.git\hooks\pre-rebase.sample` (4898 bytes)
- `.git\hooks\pre-receive.sample` (544 bytes)
- `.git\hooks\prepare-commit-msg.sample` (1492 bytes)
- `.git\hooks\push-to-checkout.sample` (2783 bytes)
- `.git\hooks\sendemail-validate.sample` (2308 bytes)
- `.git\hooks\update.sample` (3650 bytes)
- `.git\index` (864 bytes)
- `.git\info\exclude` (240 bytes)
- `.git\logs\HEAD` (527 bytes)
- `.git\logs\refs\heads\master` (561 bytes)
- `.git\logs\refs\remotes\origin\main` (152 bytes)
- `.git\objects\09\4b2b622fdc8949e5333c225ee75cdc98c3c27d` (139 bytes)
- `.git\objects\0d\51d4ebdde5b6902560dcd5a635be978cf1b11b` (139 bytes)
- `.git\objects\15\92e237a936312b23ba8eafa9c9e58e31a12afb` (780 bytes)
- `.git\objects\1a\08626a5c01e951e34584e4e8b923dc95a9cb4c` (359 bytes)
- `.git\objects\1d\b7a6ca2c2a3d112bd615b0ad742fad1e56330f` (57 bytes)
- `.git\objects\1e\156dbf74f4ba5878b10dd6ea52026dfaa34bdd` (140 bytes)
- `.git\objects\1f\152668bd328ad51106513a62f591393fdfb86d` (1443 bytes)
- `.git\objects\29\e0020da35699302162250a8a489a316c1b3e43` (1123 bytes)
- `.git\objects\2b\21a85ee8326fb1d16a8ea1fc8784820ae94f40` (1104 bytes)
- `.git\objects\31\7203a4cfd01e65f1f9c94b649bd13d95e71e0f` (515 bytes)
- `.git\objects\35\c2fc57c656e0fd58d9445fa657e238f2efba79` (1025 bytes)
- `.git\objects\3e\1750dac64e92991013b19f1518b0d9097ae5ee` (2002 bytes)
- `.git\objects\41\070b9c5732b10c07fd2139a7bfcc23bdc562c9` (54 bytes)
- `.git\objects\4a\b3af66aa4a183857185bc3a1862eeb9d845e39` (1661 bytes)
- `.git\objects\50\ce9de2fc209302c879ac2db01f7f0be18688dc` (51 bytes)
- `.git\objects\5c\a64afd13fa6c462901503302d7dedc65564bbc` (54 bytes)
- `.git\objects\60\c988cf9e84bb4e62a98012b5cfc54a780a6fdb` (254 bytes)
- `.git\objects\79\18d4685eac1f6454fe7b078927314f491300d5` (787 bytes)
- `.git\objects\7b\becda5c5d776b1aa2b67a3383a9cc10974a340` (59 bytes)
- `.git\objects\7c\dd2d474aee59e7363a161710b00e551e74be2f` (254 bytes)
- `.git\objects\7d\44a6423a7aa899e2501f8c0e39be03692f02d0` (51 bytes)
- `.git\objects\83\283e84c5553063d9e0ae5c19be0bdd9d39f8d7` (522 bytes)
- `.git\objects\88\548adbd0ece7ebae07e892ead476843a425821` (1127 bytes)
- `.git\objects\8b\6057ce984b33087ca4f0e1f28c2f738a67ee7d` (58 bytes)
- `.git\objects\94\48a2573ccbfbb502b2e21cbe9c5cfe9a5c3fee` (55 bytes)
- `.git\objects\95\fc2cda0ed94e82423aed4af1e8da8290e2a54a` (59 bytes)
- `.git\objects\96\5e2bc775a34da1beef9d83e807d6033ce18abe` (456 bytes)
- `.git\objects\9d\a65222b34d373cb348a82329bdd97fefcf69be` (252 bytes)
- `.git\objects\9f\c2e191c0db3aae4774adca86a01c346b2854df` (1922 bytes)
- `.git\objects\a6\b61d5fa03d08e1d8952fcbbb4bb21aee2d75a4` (262 bytes)
- `.git\objects\ac\3a5ed8d0fe591748bcce9410cd70d78099c422` (490 bytes)
- `.git\objects\b6\158b15ae492b49b61efc5555eec7897d19ef13` (299 bytes)
- `.git\objects\d4\67a0983a0a7a6d6eb49182f90c0deb14f01380` (296 bytes)
- `.git\objects\ee\5f9f4dec3d5da2e9da13e04f9a00740612da8f` (1769 bytes)
- `.git\objects\f0\8d4d5585cf16f43f3f872fe04e0e50c5cdbbe7` (119 bytes)
- `.git\objects\f6\45a2233c5768368e64b0ac61f12541f35e8159` (268 bytes)
- `.git\refs\heads\master` (41 bytes)
- `.git\refs\remotes\origin\main` (41 bytes)
- `.gitignore` (134 bytes)
- `docs\coverage_plan.md` (2372 bytes)
- `docs\design_spec.md` (5228 bytes)
- `docs\generation_report.md` (4902 bytes)
- `README.md` (2400 bytes)
- `rtl\uart_tx.sv` (4336 bytes)
- `sim\sim.vvp` (15627 bytes)
- `sim\waves.gtkw` (470 bytes)
- `sim\waves.vcd` (32242 bytes)
- `sva\uart_tx_sva.sv` (3254 bytes)
- `tb\uart_tx_tb.sv` (4083 bytes)

## How to Run

```bash
# Compile
iverilog -g2012 -o sim/sim.vvp rtl/uart_tx.sv tb/uart_tx_tb.sv

# Simulate
vvp sim/sim.vvp
```
