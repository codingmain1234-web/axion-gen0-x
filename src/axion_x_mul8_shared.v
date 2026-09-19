`default_nettype none

// Eight signed INT8 multipliers shared by SIMD MUL-low and SA-Core DOT8.
// The low eight product bits are identical for signed and unsigned multiply.
module axion_x_mul8_shared (
    input  wire [63:0]       a_vec,
    input  wire [63:0]       b_vec,
    output wire signed [15:0] p0,
    output wire signed [15:0] p1,
    output wire signed [15:0] p2,
    output wire signed [15:0] p3,
    output wire signed [15:0] p4,
    output wire signed [15:0] p5,
    output wire signed [15:0] p6,
    output wire signed [15:0] p7,
    output wire [63:0]       mul_low_vec
);

    assign p0 = $signed(a_vec[7:0])   * $signed(b_vec[7:0]);
    assign p1 = $signed(a_vec[15:8])  * $signed(b_vec[15:8]);
    assign p2 = $signed(a_vec[23:16]) * $signed(b_vec[23:16]);
    assign p3 = $signed(a_vec[31:24]) * $signed(b_vec[31:24]);
    assign p4 = $signed(a_vec[39:32]) * $signed(b_vec[39:32]);
    assign p5 = $signed(a_vec[47:40]) * $signed(b_vec[47:40]);
    assign p6 = $signed(a_vec[55:48]) * $signed(b_vec[55:48]);
    assign p7 = $signed(a_vec[63:56]) * $signed(b_vec[63:56]);

    assign mul_low_vec = {
        p7[7:0], p6[7:0], p5[7:0], p4[7:0],
        p3[7:0], p2[7:0], p1[7:0], p0[7:0]
    };

endmodule

`default_nettype wire
