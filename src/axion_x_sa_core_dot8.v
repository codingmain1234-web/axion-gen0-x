`default_nettype none

// Eight-lane signed INT8 DOT8 engine with a signed 40-bit accumulator.
module axion_x_sa_core_dot8 (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               ena,
    input  wire               clear_acc,
    input  wire               mac_en,
    input  wire signed [15:0] p0,
    input  wire signed [15:0] p1,
    input  wire signed [15:0] p2,
    input  wire signed [15:0] p3,
    input  wire signed [15:0] p4,
    input  wire signed [15:0] p5,
    input  wire signed [15:0] p6,
    input  wire signed [15:0] p7,
    output reg  signed [39:0] acc,
    output wire [7:0]         relu_sat
);

    // Five-stage multiply/reduce/accumulate pipeline. Pipeline data registers
    // do not need reset because their valid bits are cleared on reset/clear.
    reg signed [15:0] product0_pipe;
    reg signed [15:0] product1_pipe;
    reg signed [15:0] product2_pipe;
    reg signed [15:0] product3_pipe;
    reg signed [15:0] product4_pipe;
    reg signed [15:0] product5_pipe;
    reg signed [15:0] product6_pipe;
    reg signed [15:0] product7_pipe;

    wire signed [16:0] product0_ext = {product0_pipe[15], product0_pipe};
    wire signed [16:0] product1_ext = {product1_pipe[15], product1_pipe};
    wire signed [16:0] product2_ext = {product2_pipe[15], product2_pipe};
    wire signed [16:0] product3_ext = {product3_pipe[15], product3_pipe};
    wire signed [16:0] product4_ext = {product4_pipe[15], product4_pipe};
    wire signed [16:0] product5_ext = {product5_pipe[15], product5_pipe};
    wire signed [16:0] product6_ext = {product6_pipe[15], product6_pipe};
    wire signed [16:0] product7_ext = {product7_pipe[15], product7_pipe};

    reg signed [16:0] pair0_pipe;
    reg signed [16:0] pair1_pipe;
    reg signed [16:0] pair2_pipe;
    reg signed [16:0] pair3_pipe;

    wire signed [17:0] pair0_ext = {pair0_pipe[16], pair0_pipe};
    wire signed [17:0] pair1_ext = {pair1_pipe[16], pair1_pipe};
    wire signed [17:0] pair2_ext = {pair2_pipe[16], pair2_pipe};
    wire signed [17:0] pair3_ext = {pair3_pipe[16], pair3_pipe};

    reg signed [17:0] half0_pipe;
    reg signed [17:0] half1_pipe;

    wire signed [18:0] half0_ext = {half0_pipe[17], half0_pipe};
    wire signed [18:0] half1_ext = {half1_pipe[17], half1_pipe};

    reg signed [18:0] dot_pipe;
    reg [3:0]         valid_pipe;

    function [7:0] sat_relu8;
        input signed [39:0] value;
        begin
            if (value < 0)
                sat_relu8 = 8'd0;
            else if (value > 40'sd127)
                sat_relu8 = 8'd127;
            else
                sat_relu8 = value[7:0];
        end
    endfunction

    assign relu_sat = sat_relu8(acc);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc        <= 40'sd0;
            valid_pipe <= 4'b0000;
        end else if (ena) begin
            if (clear_acc) begin
                acc        <= 40'sd0;
                valid_pipe <= 4'b0000;
            end else begin
                if (valid_pipe[3])
                    acc <= acc + {{21{dot_pipe[18]}}, dot_pipe};

                valid_pipe <= {valid_pipe[2:0], mac_en};

                if (mac_en) begin
                    product0_pipe <= p0;
                    product1_pipe <= p1;
                    product2_pipe <= p2;
                    product3_pipe <= p3;
                    product4_pipe <= p4;
                    product5_pipe <= p5;
                    product6_pipe <= p6;
                    product7_pipe <= p7;
                end

                if (valid_pipe[0]) begin
                    pair0_pipe <= product0_ext + product1_ext;
                    pair1_pipe <= product2_ext + product3_ext;
                    pair2_pipe <= product4_ext + product5_ext;
                    pair3_pipe <= product6_ext + product7_ext;
                end

                if (valid_pipe[1]) begin
                    half0_pipe <= pair0_ext + pair1_ext;
                    half1_pipe <= pair2_ext + pair3_ext;
                end

                if (valid_pipe[2])
                    dot_pipe <= half0_ext + half1_ext;
            end
        end
    end

endmodule

`default_nettype wire
