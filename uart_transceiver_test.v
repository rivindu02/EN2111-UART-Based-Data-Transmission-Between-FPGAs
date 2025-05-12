`timescale 1ns / 1ps

module uart_transceiver_test #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire        clk,
    input  wire        rst,         // Active high (KEY0)
    input  wire        key1,        // New input: KEY1 for manual trigger
    output wire        txd,
    output wire        tx_busy,
    input  wire        rxd,
    output wire [7:0]  rx_data,
    output wire        rx_valid,
    output wire [7:0]  leds         // Output received data on LEDs
);

    wire baud_tick;
    reg [15:0] baud_cnt = 0;
    reg tx_start;
    reg [7:0] tx_data = 8'hA5;  // Arbitrary data to send (you can change this)

    // Debounce KEY1 (optional but recommended)
    reg [2:0] key1_sync;
    wire key1_pressed;

    always @(posedge clk) begin
        key1_sync <= {key1_sync[1:0], key1};
    end
    assign key1_pressed = (key1_sync[2:1] == 2'b10);  // Rising edge detection

    // Baud rate generator
    always @(posedge clk or posedge rst) begin
        if (rst)
            baud_cnt <= 0;
        else if (baud_cnt == (CLK_FREQ / BAUD_RATE - 1))
            baud_cnt <= 0;
        else
            baud_cnt <= baud_cnt + 1;
    end

    assign baud_tick = (baud_cnt == 0);

    // Trigger TX on KEY1 press
    always @(posedge clk or posedge rst) begin
        if (rst)
            tx_start <= 0;
        else
            tx_start <= key1_pressed;  // Trigger only once on key press
    end

    // Transmitter instance
    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .start(tx_start),
        .data(tx_data),
        .baud_tick(baud_tick),
        .tx(txd),
        .busy(tx_busy)
    );

    // Receiver instance
    uart_rx receiver (
        .clk(clk),
        .rst(rst),
        .rx(rxd),
        .baud_tick(baud_tick),
        .data(rx_data),
        .valid(rx_valid)
    );

    // Output received data to LEDs
    assign leds = rx_data;

endmodule
