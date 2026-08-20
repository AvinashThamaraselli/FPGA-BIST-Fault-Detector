
---

## 🎯 Key Technical Features

* 🚀 **Autonomous BIST Pipeline:** Hardware-level LFSR vector stimulus and MISR spatial compaction to detect functional degradation and stuck faults.
* 🎛️ **Live Hardware Fault Injection:** Dedicated switches to inject single-bit transient and permanent faults into the ALU datapath in real time.
* 📟 **Custom LCD Engine:** Integrated 50 MHz timing divider generating 1 $\mu\text{s}$ state ticks for power-up sequencing, instruction clearing, and 50 ms continuous line refreshing.
* 🔄 **Synchronized User Controls:** Glitch-filtered multi-stage edge synchronizer on `BTN0` prevents bounce conditions across operational states.
* 📊 **Deterministic In-Situ Comparator:** Compares real-time faulty response vectors against the reference model without degrading critical path timing.

---

## 🕹️ Hardware Switch & Button Mapping

### 1. Arithmetic & Logic Operations (`SW13`, `SW12`, `SW11`)
| SW13 (`T7`) | SW12 (`R8`) | SW11 (`T8`) | Selected ALU Operation | LCD Line 1 Display |
| :---: | :---: | :---: | :---: | :---: |
| `0` | `0` | `0` | **AND** ($A \ \& \ B$) | `R=XX AND` |
| `0` | `0` | `1` | **OR** ($A \ \vert \ B$) | `R=XX OR ` |
| `0` | `1` | `0` | **XOR** ($A \ \oplus \ B$) | `R=XX XOR` |
| `0` | `1` | `1` | **ADD** ($A + B$) | `R=XX ADD` |
| `1` | `0` | `0` | **SUB** ($A - B$) | `R=XX SUB` |
| `1` | `0` | `1` | **Left Shift** ($A \ll 1$) | `R=XX LSH` |
| `1` | `1` | `0` | **Right Shift** ($A \gg 1$) | `R=XX RSH` |
| `1` | `1` | `1` | **NAND** ($\sim(A \ \& \ B)$) | `R=XX NAND` |

### 2. Fault Injection Settings (`SW3`, `SW4`)
| SW3 (`M4`) - SA0 | SW4 (`M2`) - SA1 | Injected Fault Mode (Bit 0) | LCD Line 2 Verdict |
| :---: | :---: | :---: | :---: |
| `0` | `0` | **No Fault** (Golden reference path) | `PASS` |
| `1` | `0` | **Stuck-At-0** (Bit 0 forced to logic `0`) | `PASS` / `ERROR` |
| `0` | `1` | **Stuck-At-1** (Bit 0 forced to logic `1`) | `PASS` / `ERROR` |
| `1` | `1` | **Bit Flip** (Bit 0 dynamically inverted) | Always `ERROR` |

### 3. State & Mode Transitions (`BTN0`)
* **Mode 0 (Default):** LCD Line 2 shows `PRESS BTN0`. Set data switches **SW1–SW8** (`sw[7:0]`) to configure Operand $A$. Press **`BTN0` (`K13`)** to capture.
* **Mode 1:** LCD Line 2 shows `B=XX`. Set data switches **SW1–SW8** (`sw[7:0]`) to configure Operand $B$. Press **`BTN0` (`K13`)** to capture.
* **Mode 2 (Result & Telemetry):** Line 1 displays `R=XX <OP>` and Line 2 displays the live BIST comparison verdict (`PASS` or `ERROR`). Toggle **SW11–SW13** to switch operations or **SW3–SW4** to inject faults on the fly.
* **Reset Cycle:** Press **`BTN0`** once more to return to Mode 0 for the next test sequence.

---

## 📁 Repository Directory Structure

```text
├── rtl/
│   ├── top_bist.v              # Top-level integration (ALU, Faults, LCD FSM, Sync)
│   ├── lfsr_16bit.v            # 16-bit Linear Feedback Shift Register
│   ├── fault_injector.v        # Dynamic multi-type fault injection core
│   ├── misr_16bit.v            # 16-bit Multiple-Input Signature Register
│   └── signature_comparator.v  # Hardware BIST signature verification logic
├── constraints/
│   └── top_bist.xdc            # Pinout & timing constraints for Edge Artix-7
├── sim/
│   ├── tb_lfsr_16bit.v         # LFSR pattern generation testbench
│   ├── tb_fault_injector.v     # Fault injection verification testbench
│   ├── tb_misr_16bit.v         # MISR signature compaction testbench
│   └── tb_signature_comparator.v# Signature comparator verification testbench
└── README.md