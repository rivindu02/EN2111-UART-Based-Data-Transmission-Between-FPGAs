`timescale 1ns / 1ps

module invert_uart_transceiver_test #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire        clk,
    input  wire        rst_n,       // Active LOW KEY0
    input  wire        key1_n,      // Active LOW KEY1 (transmit trigger)
    output wire        txd,
    input  wire        rxd,
    output wire [7:0]  rx_data,
    output wire [7:0]  leds,	 // Output received data on LEDs
	 output wire [6:0]  seg
);

    wire rst = ~rst_n;              // Invert active-low reset
    wire key1 = ~key1_n;            // Invert active-low key1

    wire baud_tick;
    reg [15:0] baud_cnt = 0;
    reg tx_start;
    reg [7:0] tx_data = 8'h05;      // Data to send

    // Debounce and edge detect key1
    reg [2:0] key1_sync;
    wire key1_pressed;

    always @(posedge clk) begin
        key1_sync <= {key1_sync[1:0], key1};
    end
    assign key1_pressed = (key1_sync[2:1] == 2'b10);  // Falling edge (button press)

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

    // Trigger TX on falling edge of KEY1
    always @(posedge clk or posedge rst) begin
        if (rst)
            tx_start <= 0;
        else
            tx_start <= key1_pressed;
    end

    // Transmitter instance (NO 'busy' output)
    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .start(tx_start),
        .data(tx_data),
        .baud_tick(baud_tick),
        .tx(txd)
    );
	
	 
    // Receiver instance (NO 'valid' output)
    uart_rx receiver (
        .clk(clk),
        .rst(rst),
        .rx(rxd),
        .baud_tick(baud_tick),
        .data(rx_data)
    );

    // Output received data to LEDs
    assign leds = rx_data;
    
	 // 7-Segment Decoder (Only show last 4 bits)
    binary_to_7seg seg_decoder (
        .data_in(rx_data[3:0]),
        .data_out(seg)
    );
endmodule
