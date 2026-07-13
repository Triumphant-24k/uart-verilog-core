# UART Verilog Core

A modular UART transmitter and receiver implemented in Verilog HDL and verified using QuestaSim.

This repository contains a UART TX core, UART RX core, and a loopback top module for end-to-end verification.

---

## Features

- UART transmitter
- UART receiver
- Configurable `CLKS_PER_BIT`
- 8-bit data frame
- 1 start bit
- 1 stop bit
- No parity
- TX/RX loopback verification
- QuestaSim testbenches

---

## UART Frame Format

```text
Idle  Start   Data Bits LSB First              Stop   Idle
  1      0     D0 D1 D2 D3 D4 D5 D6 D7           1      1
```

Example byte:

```text
8'hA5 = 1010_0101
```

UART transmits the least significant bit first:

```text
1, 0, 1, 0, 0, 1, 0, 1
```

---

## Project Structure

```text
uart-verilog-core/

src/
    uart_tx.v
    uart_rx.v
    baud_tick_gen.v
    uart_loopback_top.v

tb/
    uart_tx_tb.v
    uart_rx_tb.v
    uart_loopback_tb.v

sim/
    run_questa.do

README.md
.gitignore
```

---

## Module Overview

| Module | Description |
|--------|-------------|
| `uart_tx.v` | UART transmitter. Converts 8-bit parallel data into serial UART format. |
| `uart_rx.v` | UART receiver. Converts serial UART input into 8-bit parallel data. |
| `baud_tick_gen.v` | Basic baud tick generator module. Included for reuse and future expansion. |
| `uart_loopback_top.v` | Connects TX serial output directly to RX serial input for loopback testing. |

---

## UART Transmitter

### Inputs

| Signal | Width | Description |
|--------|-------|-------------|
| `clk` | 1 | System clock |
| `rst` | 1 | Active-high reset |
| `tx_start` | 1 | Starts transmission |
| `tx_data` | 8 | Byte to transmit |

### Outputs

| Signal | Width | Description |
|--------|-------|-------------|
| `tx_serial` | 1 | UART serial output |
| `tx_busy` | 1 | High while transmission is active |
| `tx_done` | 1 | Pulses high after transmission completes |

### TX State Flow

```text
IDLE -> START -> DATA -> STOP -> DONE -> IDLE
```

---

## UART Receiver

### Inputs

| Signal | Width | Description |
|--------|-------|-------------|
| `clk` | 1 | System clock |
| `rst` | 1 | Active-high reset |
| `rx_serial` | 1 | UART serial input |

### Outputs

| Signal | Width | Description |
|--------|-------|-------------|
| `rx_data` | 8 | Received byte |
| `rx_done` | 1 | Pulses high when byte is received |
| `rx_busy` | 1 | High while reception is active |

### RX State Flow

```text
IDLE -> START -> DATA -> STOP -> DONE -> IDLE
```

The receiver samples the start bit near the middle of the bit period, then samples each data bit once per bit period.

---

## CLKS_PER_BIT

`CLKS_PER_BIT` defines how many system clock cycles make one UART bit period.

```text
CLKS_PER_BIT = Clock Frequency / Baud Rate
```

Example:

```text
Clock Frequency = 10 MHz
Baud Rate       = 115200
CLKS_PER_BIT    = 10,000,000 / 115200 ≈ 87
```

For faster simulation, the testbenches use:

```verilog
localparam CLKS_PER_BIT = 8;
```

---

## Testbenches

| Testbench | Purpose |
|----------|---------|
| `uart_tx_tb.v` | Verifies UART TX serial frame generation. |
| `uart_rx_tb.v` | Verifies UART RX byte reconstruction from serial input. |
| `uart_loopback_tb.v` | Connects TX to RX and verifies end-to-end data transfer. |

The loopback test sends:

| Test Byte | Expected RX Data |
|----------|------------------|
| `8'hA5` | `8'hA5` |
| `8'h3C` | `8'h3C` |
| `8'h55` | `8'h55` |

Expected transcript output:

```text
PASS: Sent a5, Received a5
PASS: Sent 3c, Received 3c
PASS: Sent 55, Received 55
```

---

## Running Simulation in QuestaSim

From the repository root, run:

```tcl
cd path/to/uart-verilog-core
do sim/run_questa.do
```

Manual command sequence:

```tcl
vlib work
vlog src/uart_tx.v
vlog src/uart_rx.v
vlog src/uart_loopback_top.v
vlog tb/uart_loopback_tb.v
vsim -voptargs=+acc work.uart_loopback_tb
add wave -r sim:/uart_loopback_tb/*
run -all
```

---

## Verification Status

| Module | Status |
|--------|--------|
| UART TX | Verified |
| UART RX | Verified |
| UART Loopback | Verified |

---

## Notes

This implementation uses a simple UART format: 8 data bits, no parity, and 1 stop bit. It is suitable for RTL learning, simulation, and as a base for FPGA integration.
