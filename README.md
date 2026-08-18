# 8-Bit SPI Master Controller (Verilog)

A lightweight, fully synthesizable 8-bit SPI (Serial Peripheral Interface) Master Controller written in Verilog HDL and verified using AMD Xilinx Vivado.

## Features
* **Protocol Mode:** SPI Mode 0 (CPOL = 0, CPHA = 0)
* **Data Transfer:** Full-duplex, MSB-first serial transmission
* **Efficiency:** Single 8-bit shift register reused for simultaneous MOSI drive and MISO sampling
* **Handshaking:** Dedicated `busy` and `done` status flags for system controller integration

## Finite State Machine (FSM)
The controller operates using a 4-state Finite State Machine:
1. **`IDLE` (2'b00):** Waits for `start == 1`. Loads `tx_data` into internal shift register.
2. **`INIT` (2'b01):** Asserts Chip Select (`cs = 0`) to enforce slave setup time before clocking.
3. **`TRANSFER` (2'b10):** Toggles `sclk`, drives `mosi` with MSB, and samples `miso` into LSB over 8 cycles.
4. **`DONE` (2'b11):** Deasserts `cs = 1`, updates `rx_data`, and pulses `done = 1`.

## Simulation & Waveform Verification

The design was verified using a behavioral testbench in Vivado simulating an SPI Slave responding with alternating bits (`0xAA`).

### Waveform Highlights:
* **TX Transmission:** `tx_data = 0xA5` (`10100101`) successfully serialized over `mosi`.
* **RX Reception:** Captured `miso` toggles into `rx_data = 0xAA` (`10101010`).
* **Handshaking:** `busy` remains high throughout transaction; `done` pulses high exactly upon completion.
