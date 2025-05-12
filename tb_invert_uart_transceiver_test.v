`timescale 1ns / 1ps

module tb_invert_uart_transceiver_test();

    // Parameters
    parameter CLK_FREQ  = 50000000;
    parameter BAUD_RATE = 115200;
    parameter BAUD_TICK_PERIOD = 1_000_000_000 / BAUD_RATE; // In ns

    // Testbench signals
    reg clk = 0;
    reg rst_n = 0;
    reg key1_n = 1;
    wire txd;
    wire rxd;
    wire [7:0] rx_data;
    wire [7:0] leds;

    // Clock generation
    always #10 clk = ~clk; // 50 MHz clock

    // Instantiate DUT
    invert_uart_transceiver_test #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .key1_n(key1_n),
        .txd(txd),
        .rxd(rxd),        // Loopback
        .rx_data(rx_data),
        .leds(leds)
    );

    // Loopback connection
    assign rxd = txd;

    initial begin
        // Initialize
        rst_n = 0;
        key1_n = 1;
        #100;
        rst_n = 1;      // Deassert reset
        #1000;

        // Press KEY1 to start transmission
        key1_n = 0;     // Button press (active low)
        #40;
        key1_n = 1;     // Button release

        // Wait long enough for transmission and reception
        #(BAUD_TICK_PERIOD * 12 * 1000); // ~12 bit times (including start + stop)

        // Display received data
        $display("Received data: %h", rx_data);
        $display("LEDs: %b", leds);

        #100;
        $stop;
    end

endmodule
