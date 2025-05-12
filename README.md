# UART-Based Data Transmission Between FPGAs

## Project Overview
This project, developed as part of the **EN2111 Electronic Circuit Design** module, implements a UART (Universal Asynchronous Receiver-Transmitter) protocol for data transmission between two FPGA boards. The system enables reliable serial communication at a specified baud rate, with one FPGA transmitting data and the other receiving and displaying it on a 7-segment display. The design includes UART transmitter and receiver modules, baud rate generation, debouncing for user inputs, and a 7-segment decoder for visual output. The project also includes testbenches for simulation and verification. The target FPGA board is the **DE0-Nano**.

## Key Theories and Concepts

### 1. UART Protocol
The UART protocol is a serial communication standard for asynchronous data transfer between devices. Key features include:
- **Asynchronous Communication**: No shared clock signal is required; timing is managed using a predefined baud rate.
- **Frame Structure**: Each data frame consists of:
  - 1 start bit (logic low).
  - 8 data bits (configurable, typically 8 bits in this project).
  - 1 stop bit (logic high).
- **Baud Rate**: The rate at which bits are transmitted (e.g., 9600 or 115200 bps). Both transmitter and receiver must use the same baud rate for successful communication.
- **Implementation**: The UART transmitter (`uart_tx.v`) serializes data with start and stop bits, while the receiver (`uart_rx.v`) deserializes incoming data, detecting start/stop bits and reconstructing the data byte.

### 2. Baud Rate Generation
- **Theory**: The baud rate determines the timing of bit transmission. For a given clock frequency (e.g., 50 MHz), the baud rate is achieved by generating a "baud tick" signal at regular intervals.
- **Implementation**: A counter increments on each clock cycle until it reaches a value equal to `CLK_FREQ / BAUD_RATE`. When this occurs, a baud tick is generated, resetting the counter. For example:
  - For 50 MHz clock and 9600 baud: `50,000,000 / 9600 ≈ 5208` clock cycles per baud tick.
  - This is implemented in files like `uart_tb.v`, `uart_transceiver_test.v`, and `invert_uart_transceiver_test.v`.

### 3. Debouncing
- **Theory**: Mechanical push buttons (e.g., KEY1 for triggering transmission) produce noisy signals due to contact bounce. Debouncing ensures a clean, single-edge signal.
- **Implementation**: A shift register (`key1_sync`) captures the button state over multiple clock cycles. A falling or rising edge is detected only when the signal stabilizes (e.g., `key1_sync[2:1] == 2'b10` for falling edge). This is used in `uart_transceiver_test.v` and `invert_uart_transceiver_test.v`.

### 4. 7-Segment Display
- **Theory**: A 7-segment display shows hexadecimal digits by activating specific segments (a-g). A lookup table (LUT) maps 4-bit binary inputs to 7-bit segment patterns.
- **Implementation**: The `binary_to_7seg.v` module converts the lower 4 bits of received data into a 7-segment pattern, driving the display to show hexadecimal values (0-9). This is integrated in `invert_uart_transceiver_test.v`.

### 5. FPGA Clocking and Reset
- **Theory**: FPGAs operate synchronously with a system clock (50 MHz in this project). A reset signal initializes the system to a known state.
- **Implementation**: The clock is toggled every 10 ns (for 50 MHz) in testbenches (`uart_tb.v`, `uart_transceiver_test_tb.v`). Active-high or active-low resets are used, with inversion as needed (e.g., `rst = ~rst_n` in `invert_uart_transceiver_test.v`).

### 6. Loopback Testing
- **Theory**: Loopback connects the transmitter output (TX) to the receiver input (RX) to verify functionality without external connections.
- **Implementation**: In `uart_transceiver_test_tb.v` and `uart_loopback_test.v`, the TX signal is directly fed to RX (`rxd = txd`). The loopback test module (`uart_loopback_test.v`) transmits a hexadecimal number \( x \) (e.g., `8'hA5`) and receives a number that is twice the transmitted value (\( 2x \)), allowing verification of data manipulation and integrity.

### 7. Simulation and Verification
- **Theory**: Testbenches simulate hardware behavior to verify functionality before deployment. They generate stimuli (e.g., clock, reset, button presses) and check outputs.
- **Implementation**: Testbenches like `uart_tb.v` and `uart_transceiver_test_tb.v` simulate UART communication, log results (e.g., `$display`), and generate waveform files (e.g., `uart_tb.vcd`) for debugging.

## File Descriptions
- **`uart_tx.v`**: UART transmitter module. Serializes 8-bit data with start and stop bits, triggered by a start signal.
- **`uart_rx.v`**: UART receiver module. Deserializes incoming serial data, outputting an 8-bit data byte.
- **`uart_tb.v`**: Testbench for standalone UART TX/RX testing. Simulates transmission of a byte (`8'hA5`) at 9600 baud and verifies reception.
- **`uart_transceiver_test.v`**: Top-level module for FPGA implementation. Integrates UART TX/RX, baud rate generator, and debouncing for KEY1 to trigger transmission. Outputs received data to LEDs.
- **`invert_uart_transceiver_test.v`**: Variant of the transceiver module with active-low inputs (rst_n, key1_n) and a 7-segment display output for the lower 4 bits of received data.
- **`uart_transceiver_test_tb.v`**: Testbench for `uart_transceiver_test.v`. Simulates key press and loopback communication at 9600 baud.
- **`binary_to_7seg.v`**: Converts 4-bit binary input to 7-segment display signals using a lookup table.
- **`uart_loopback_test.v`**: Simplified loopback test module. Automatically triggers transmission of a hexadecimal number \( x \) (e.g., `8'hA5`) after reset and receives \( 2x \), displaying the received data on LEDs.

## Project Features
- **Baud Rates**: Configurable (9600 or 115200 bps) via parameters.
- **User Interaction**: KEY1 triggers data transmission in `uart_transceiver_test.v` and `invert_uart_transceiver_test.v`.
- **Visual Output**: LEDs display received 8-bit data; 7-segment display shows the lower 4 bits in `invert_uart_transceiver_test.v`.
- **Modularity**: Reusable UART TX/RX modules and testbenches for simulation and hardware deployment.
- **Error Handling**: Debouncing ensures reliable button inputs; testbenches verify data integrity.

## Setup and Usage
1. **Tools**:
   - **Coding**: Use **Quartus Prime 24.1 Standard** for writing and synthesizing Verilog code.
   - **Simulation**: Use **Questa - Altera FPGA Starter Edition 2024.3** for running testbenches and analyzing waveforms.
2. **Synthesis**: Compile the Verilog files in Quartus Prime, targeting the **DE0-Nano** FPGA board.
3. **Pin Assignment**: Assign pins for `clk`, `rst`, `key1`, `txd`, `rxd`, `leds`, and `seg` based on the DE0-Nano's pinout (refer to the DE0-Nano user manual).
4. **Simulation**: Run testbenches (`uart_tb.v`, `uart_transceiver_test_tb.v`) in Questa to verify functionality and view waveforms.
5. **Hardware Testing**:
   - Connect two DE0-Nano boards: TX of one to RX of the other, and vice versa.
   - Press KEY1 to transmit data and observe received data on LEDs or 7-segment display.
6. **Loopback Testing**: For single-FPGA testing on a DE0-Nano, connect TX to RX and verify that transmitting \( x \) results in receiving \( 2x \).

## Future Improvements
- Add parity bit support for error detection.
- Implement a FIFO buffer for continuous data transmission.
- Support variable data lengths (e.g., 7-bit or 9-bit UART frames).
- Enhance the 7-segment display to show full 8-bit data using multiplexing.

## Acknowledgments
This project was developed as part of the EN2111 Electronic Circuit Design module. Special thanks to the instructors and peers for their guidance and support.
