module uart_loopback_test (
    input  wire        clk,
    input  wire        rst,
    output wire [7:0]  leds,
	 output wire        txd,
	 input wire         rxd
);

//    wire        txd;
    wire        tx_busy;
    wire        rx_valid;
    wire [7:0]  rx_data;

    // Generate tx_start only once after reset
    reg tx_trigger = 0;
    reg [3:0] start_cnt = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start_cnt <= 0;
            tx_trigger <= 0;
        end else if (start_cnt < 10) begin
            start_cnt <= start_cnt + 1;
        end else if (!tx_trigger) begin
            tx_trigger <= 1;  // start signal active once
        end else begin
            tx_trigger <= 0;  // deactivate start after one pulse
        end
    end

    uart_transceiver uart (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_trigger),
        .tx_data(8'hA5),      // << Transmit this hardcoded value
        .txd(txd),
        .tx_busy(tx_busy),
        .rxd(txd),            // << Loopback connection
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    // Output received data to LEDs only when valid
    reg [7:0] led_reg = 0;
    always @(posedge clk or posedge rst) begin
        if (rst)
            led_reg <= 8'b0;
        else if (rx_valid)
            led_reg <= rx_data;
    end

    assign leds = led_reg;

endmodule
