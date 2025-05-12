`timescale 1ns / 1ps

module uart_rx (
    input  wire clk,
    input  wire rst,
    input  wire rx,
    input  wire baud_tick,
    output reg [7:0] data
);

    reg [3:0] bit_index = 0;
    reg [7:0] shift_reg = 0;
    reg [1:0] state = 0;
    reg rx_sync = 1;

    localparam IDLE  = 0,
               START = 1,
               DATA  = 2,
               STOP  = 3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            bit_index <= 0;
            shift_reg <= 0;
            data <= 0;
            rx_sync <= 1;
        end else begin
            rx_sync <= rx;

            case (state)
                IDLE: begin
                    if (!rx_sync)  // start bit detected
                        state <= START;
                end

                START: begin
                    if (baud_tick) begin
                        if (!rx_sync) begin
                            state <= DATA;
                            bit_index <= 0;
                        end else begin
                            state <= IDLE; // false start
                        end
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        shift_reg[bit_index] <= rx_sync;
                        if (bit_index == 7)
                            state <= STOP;
                        bit_index <= bit_index + 1;
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        if (rx_sync) begin
                            data <= shift_reg;  // accept byte
                        end
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
