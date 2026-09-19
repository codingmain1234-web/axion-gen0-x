`default_nettype none

// AXION Gen0-X command-driven eight-lane vector and AI compute prototype.
module axion_gen0x (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire [7:0] data_in,
    input  wire [7:0] command,
    output reg  [7:0] data_out
);

    reg reset_active;
    always @(posedge clk)
        reset_active <= !rst_n;

    wire core_rst_n = !reset_active;

    localparam [7:0] CMD_LOAD_A0    = 8'h10;
    localparam [7:0] CMD_LOAD_A7    = 8'h17;
    localparam [7:0] CMD_LOAD_B0    = 8'h18;
    localparam [7:0] CMD_LOAD_B7    = 8'h1f;
    localparam [7:0] CMD_VEC_ADD    = 8'h20;
    localparam [7:0] CMD_VEC_MIN    = 8'h26;
    localparam [7:0] CMD_DOT8_MAC   = 8'h28;
    localparam [7:0] CMD_READ_VEC0  = 8'h30;
    localparam [7:0] CMD_READ_VEC7  = 8'h37;
    localparam [7:0] CMD_READ_ACC0  = 8'h38;
    localparam [7:0] CMD_READ_ACC4  = 8'h3c;
    localparam [7:0] CMD_READ_RELU  = 8'h3d;
    localparam [7:0] CMD_READ_BIST  = 8'h3e;
    localparam [7:0] CMD_READ_VER   = 8'h3f;
    localparam [7:0] CMD_CLEAR_ACC  = 8'h40;
    localparam [7:0] CMD_SELF_TEST  = 8'h50;

    localparam [2:0] READ_VECTOR = 3'd0;
    localparam [2:0] READ_ACC    = 3'd1;
    localparam [2:0] READ_RELU   = 3'd2;
    localparam [2:0] READ_BIST   = 3'd3;
    localparam [2:0] READ_VER    = 3'd4;

    reg [63:0] a_vec;
    reg [63:0] b_vec;
    reg [63:0] vector_result;
    reg [2:0]  read_mode;
    reg [2:0]  read_index;
    reg [2:0]  bist_state;
    reg [7:0]  bist_status;

    wire vector_execute = (command >= CMD_VEC_ADD) &&
                          (command <= CMD_VEC_MIN) &&
                          (bist_state == 3'd0);
    wire [2:0] alu_op = (bist_state == 3'd1) ? 3'd0 : command[2:0];
    wire [63:0] vector_y;
    wire [63:0] mul_low_vec;
    wire signed [15:0] product0;
    wire signed [15:0] product1;
    wire signed [15:0] product2;
    wire signed [15:0] product3;
    wire signed [15:0] product4;
    wire signed [15:0] product5;
    wire signed [15:0] product6;
    wire signed [15:0] product7;

    axion_x_mul8_shared u_mul8 (
        .a_vec       (a_vec),
        .b_vec       (b_vec),
        .p0          (product0),
        .p1          (product1),
        .p2          (product2),
        .p3          (product3),
        .p4          (product4),
        .p5          (product5),
        .p6          (product6),
        .p7          (product7),
        .mul_low_vec (mul_low_vec)
    );

    axion_x_vcore_simd8 u_vcore (
        .a_vec       (a_vec),
        .b_vec       (b_vec),
        .mul_low_vec (mul_low_vec),
        .op          (alu_op),
        .y_vec       (vector_y)
    );

    wire clear_acc = (command == CMD_CLEAR_ACC) ||
                     ((command == CMD_SELF_TEST) && (bist_state == 3'd0));
    wire mac_en = ((command == CMD_DOT8_MAC) && (bist_state == 3'd0)) ||
                  (bist_state == 3'd1);
    wire signed [39:0] sa_acc;
    wire [7:0] sa_relu_sat;

    axion_x_sa_core_dot8 u_sa_core (
        .clk       (clk),
        .rst_n     (core_rst_n),
        .ena       (ena),
        .clear_acc (clear_acc),
        .mac_en    (mac_en),
        .p0        (product0),
        .p1        (product1),
        .p2        (product2),
        .p3        (product3),
        .p4        (product4),
        .p5        (product5),
        .p6        (product6),
        .p7        (product7),
        .acc       (sa_acc),
        .relu_sat  (sa_relu_sat)
    );

    always @(posedge clk) begin
        if (!core_rst_n) begin
            a_vec         <= 64'h0000000000000000;
            b_vec         <= 64'h0000000000000000;
            vector_result <= 64'h0000000000000000;
            read_mode     <= READ_VECTOR;
            read_index    <= 3'd0;
            bist_state    <= 3'd0;
            bist_status   <= 8'h00;
        end else if (ena) begin
            if (bist_state == 3'd1) begin
                vector_result <= vector_y;
                bist_state    <= 3'd2;
            end else if (bist_state == 3'd2) begin
                bist_state <= 3'd3;
            end else if (bist_state == 3'd3) begin
                bist_state <= 3'd4;
            end else if (bist_state == 3'd4) begin
                bist_state <= 3'd5;
            end else if (bist_state == 3'd5) begin
                bist_state <= 3'd6;
            end else if (bist_state == 3'd6) begin
                if ((sa_acc == 40'sd120) &&
                    (vector_result == 64'h0909090909090909))
                    bist_status <= 8'ha5;
                else
                    bist_status <= 8'h5a;
                bist_state <= 3'd0;
                read_mode  <= READ_BIST;
            end else begin
                if ((command >= CMD_LOAD_A0) && (command <= CMD_LOAD_A7)) begin
                    case (command[2:0])
                        3'd0: a_vec[7:0]   <= data_in;
                        3'd1: a_vec[15:8]  <= data_in;
                        3'd2: a_vec[23:16] <= data_in;
                        3'd3: a_vec[31:24] <= data_in;
                        3'd4: a_vec[39:32] <= data_in;
                        3'd5: a_vec[47:40] <= data_in;
                        3'd6: a_vec[55:48] <= data_in;
                        default: a_vec[63:56] <= data_in;
                    endcase
                end else if ((command >= CMD_LOAD_B0) && (command <= CMD_LOAD_B7)) begin
                    case (command[2:0])
                        3'd0: b_vec[7:0]   <= data_in;
                        3'd1: b_vec[15:8]  <= data_in;
                        3'd2: b_vec[23:16] <= data_in;
                        3'd3: b_vec[31:24] <= data_in;
                        3'd4: b_vec[39:32] <= data_in;
                        3'd5: b_vec[47:40] <= data_in;
                        3'd6: b_vec[55:48] <= data_in;
                        default: b_vec[63:56] <= data_in;
                    endcase
                end else if (vector_execute) begin
                    vector_result <= vector_y;
                    read_mode     <= READ_VECTOR;
                    read_index    <= 3'd0;
                end else if (command == CMD_DOT8_MAC) begin
                    read_mode <= READ_RELU;
                end else if ((command >= CMD_READ_VEC0) && (command <= CMD_READ_VEC7)) begin
                    read_mode  <= READ_VECTOR;
                    read_index <= command[2:0];
                end else if ((command >= CMD_READ_ACC0) && (command <= CMD_READ_ACC4)) begin
                    read_mode  <= READ_ACC;
                    read_index <= command[2:0];
                end else if (command == CMD_READ_RELU) begin
                    read_mode <= READ_RELU;
                end else if (command == CMD_READ_BIST) begin
                    read_mode <= READ_BIST;
                end else if (command == CMD_READ_VER) begin
                    read_mode <= READ_VER;
                end else if (command == CMD_CLEAR_ACC) begin
                    read_mode <= READ_RELU;
                end else if (command == CMD_SELF_TEST) begin
                    a_vec       <= 64'h0807060504030201;
                    b_vec       <= 64'h0102030405060708;
                    bist_status <= 8'h01;
                    bist_state  <= 3'd1;
                    read_mode   <= READ_BIST;
                end
            end
        end
    end

    always @* begin
        case (read_mode)
            READ_VECTOR: begin
                case (read_index)
                    3'd0: data_out = vector_result[7:0];
                    3'd1: data_out = vector_result[15:8];
                    3'd2: data_out = vector_result[23:16];
                    3'd3: data_out = vector_result[31:24];
                    3'd4: data_out = vector_result[39:32];
                    3'd5: data_out = vector_result[47:40];
                    3'd6: data_out = vector_result[55:48];
                    default: data_out = vector_result[63:56];
                endcase
            end
            READ_ACC: begin
                case (read_index)
                    3'd0: data_out = sa_acc[7:0];
                    3'd1: data_out = sa_acc[15:8];
                    3'd2: data_out = sa_acc[23:16];
                    3'd3: data_out = sa_acc[31:24];
                    default: data_out = sa_acc[39:32];
                endcase
            end
            READ_RELU: data_out = sa_relu_sat;
            READ_BIST: data_out = bist_status;
            READ_VER:  data_out = 8'ha8;
            default:   data_out = 8'h00;
        endcase
    end

endmodule

`default_nettype wire
