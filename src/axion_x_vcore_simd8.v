`default_nettype none

// Eight 8-bit SIMD lanes executing one shared operation.
module axion_x_vcore_simd8 (
    input  wire [63:0] a_vec,
    input  wire [63:0] b_vec,
    input  wire [63:0] mul_low_vec,
    input  wire [2:0]  op,
    output wire [63:0] y_vec
);

    function [7:0] lane_alu;
        input [7:0] a;
        input [7:0] b;
        input [7:0] mul_low;
        input [2:0] lane_op;
        begin
            case (lane_op)
                3'd0: lane_alu = a + b;
                3'd1: lane_alu = a - b;
                3'd2: lane_alu = mul_low;
                3'd3: lane_alu = a & b;
                3'd4: lane_alu = a ^ b;
                3'd5: lane_alu = (a > b) ? a : b;
                3'd6: lane_alu = (a < b) ? a : b;
                default: lane_alu = 8'h00;
            endcase
        end
    endfunction

    assign y_vec[7:0]   = lane_alu(a_vec[7:0],   b_vec[7:0],   mul_low_vec[7:0],   op);
    assign y_vec[15:8]  = lane_alu(a_vec[15:8],  b_vec[15:8],  mul_low_vec[15:8],  op);
    assign y_vec[23:16] = lane_alu(a_vec[23:16], b_vec[23:16], mul_low_vec[23:16], op);
    assign y_vec[31:24] = lane_alu(a_vec[31:24], b_vec[31:24], mul_low_vec[31:24], op);
    assign y_vec[39:32] = lane_alu(a_vec[39:32], b_vec[39:32], mul_low_vec[39:32], op);
    assign y_vec[47:40] = lane_alu(a_vec[47:40], b_vec[47:40], mul_low_vec[47:40], op);
    assign y_vec[55:48] = lane_alu(a_vec[55:48], b_vec[55:48], mul_low_vec[55:48], op);
    assign y_vec[63:56] = lane_alu(a_vec[63:56], b_vec[63:56], mul_low_vec[63:56], op);

endmodule

`default_nettype wire
