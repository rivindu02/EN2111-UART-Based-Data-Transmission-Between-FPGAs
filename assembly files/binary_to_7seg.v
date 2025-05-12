module binary_to_7seg (
    input [3:0] data_in,
    output [6:0] data_out
);

    reg [6:0] lut_7seg [0:15];
    reg [6:0] seg_val;

    // Assign the output as the inverted LUT value
    assign data_out = seg_val;

    always @(*) begin
        // LUT initialization (hardcoded for synthesis tools)
        lut_7seg[0]  = 7'b0111111;
        lut_7seg[1]  = 7'b0000110;
        lut_7seg[2]  = 7'b1011011;
        lut_7seg[3]  = 7'b1001111;
        lut_7seg[4]  = 7'b1100110;
        lut_7seg[5]  = 7'b1101101;
        lut_7seg[6]  = 7'b1111101;
        lut_7seg[7]  = 7'b0000111;
        lut_7seg[8]  = 7'b1111111;
        lut_7seg[9]  = 7'b1101111;
        lut_7seg[10] = 7'b0000000;
        lut_7seg[11] = 7'b0000000;
        lut_7seg[12] = 7'b0000000;
        lut_7seg[13] = 7'b0000000;
        lut_7seg[14] = 7'b0000000;
        lut_7seg[15] = 7'b0000000;

        seg_val = lut_7seg[data_in];
    end

endmodule
