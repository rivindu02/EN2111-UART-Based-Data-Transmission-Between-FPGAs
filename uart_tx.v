`timescale 1ns / 1ps

module uart_tx (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [7:0] data,
    input  wire baud_tick,
    output reg  tx
);

    reg [3:0] bit_index = 0;
    reg [9:0] shift_reg = 10'b1111111111;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1;                       // Idle state of TX line is high
            bit_index <= 0;
            shift_reg <= 10'b1111111111;
        end else begin
            // Start a new transmission only if idle (bit_index == 0)
            if (start && bit_index == 0) begin
                shift_reg <= {1'b1, data, 1'b0}; // Stop bit, data, start bit
                bit_index <= 1;                  // Start counting from 1 (transmitting)
            end else if (baud_tick && bit_index != 0) begin
                tx <= shift_reg[0];                      // Send LSB
                shift_reg <= {1'b1, shift_reg[9:1]};     // Shift right
                if (bit_index == 10)                     // All 10 bits sent
                    bit_index <= 0;                      // Reset to idle
                else
                    bit_index <= bit_index + 1;
            end
        end
    end
endmodule

