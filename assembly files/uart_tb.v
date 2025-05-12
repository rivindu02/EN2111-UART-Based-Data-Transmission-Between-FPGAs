`timescale 1ns / 1ps

module uart_tb;

    reg clk = 0;
    reg rst = 1;

    // Clock and Baud Parameters
    parameter CLK_FREQ = 50000000;      // 50 MHz
    parameter BAUD_RATE = 9600;
    parameter CLK_PERIOD = 20;          // 20 ns
    parameter BAUD_TICK_CYCLES = CLK_FREQ / BAUD_RATE; // = 5208

    // Baud tick generation
    reg baud_tick = 0;
    integer baud_counter = 0;

    // UART TX signals
    reg start = 0;
    reg [7:0] tx_data = 8'hA5;
    wire tx;
    wire tx_busy;

    // UART RX signals
    wire [7:0] rx_data;
    wire rx_valid;

    // Clock generation (50 MHz)
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Baud tick generation
    always @(posedge clk) begin
        if (baud_counter == BAUD_TICK_CYCLES - 1) begin
            baud_tick <= 1;
            baud_counter <= 0;
        end else begin
            baud_tick <= 0;
            baud_counter <= baud_counter + 1;
        end
    end

    // DUT instantiations
    uart_tx uut_tx (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data(tx_data),
        .baud_tick(baud_tick),
        .tx(tx),
        .busy(tx_busy)
    );

    uart_rx uut_rx (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .baud_tick(baud_tick),
        .data(rx_data),
        .valid(rx_valid)
    );

    // Simulation behavior
    initial begin
        $display("Starting UART TX/RX simulation at 50MHz / 9600 baud...");
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        // Reset
        #100;
        rst = 0;

        // Wait a few cycles and transmit data
        #100;
        start = 1;
        #CLK_PERIOD;
        start = 0;

        // Wait for valid output
        wait(rx_valid == 1);

        #20;
        if (rx_data == tx_data)
            $display("SUCCESS: Received data = 0x%0h", rx_data);
        else
            $display("FAILURE: Received data = 0x%0h (expected 0x%0h)", rx_data, tx_data);

        #100;
        $finish;
    end

endmodule
