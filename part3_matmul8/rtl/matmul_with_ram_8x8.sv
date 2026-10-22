`timescale 1ns/1ps
`default_nettype none
// Six 32-bit synchronous dual-port RAMs, derived from the supplied wrapper.
// External port addresses are independent per matrix; data packs two banks.
// [31:0] = top A / left B / top C, [63:32] = bottom A / right B / bottom C.
module matmul_with_ram_8x8 (
    input wire clk, resetn, pe_resetn, start,
    input wire [9:0] address_mat_a, address_mat_b, address_mat_c,
    input wire [7:0] address_stride_a, address_stride_b, address_stride_c,
    input wire [9:0] load_addr_a, load_addr_b, read_addr_c,
    input wire [63:0] load_a, load_b,
    input wire load_we,
    output wire [63:0] read_a, read_b, read_c,
    output wire busy,
    output logic done,
    output wire [4:0] exception_flags
);
    typedef enum logic [1:0] {IDLE, PREPARE, RUN} state_t;
    state_t state;
    logic previous_start;
    logic [9:0] base_a, base_b, base_c;
    logic [7:0] stride_a, stride_b, stride_c;
    wire core_run = state == RUN;
    wire core_reset = !resetn || state == PREPARE;
    wire core_pe_reset = !pe_resetn || state == PREPARE;
    wire core_done;
    assign busy = state != IDLE;
    // Configuration is sampled on an idle rising start. A single preparation
    // clock clears every PE/flag and initializes addresses for each new job.
    // No external reset is needed between independent matrix operations.
    always_ff @(posedge clk) begin
        if (!resetn) begin
            state <= IDLE;
            previous_start <= 0;
            done <= 0;
            base_a <= 0; base_b <= 0; base_c <= 0;
            stride_a <= 1; stride_b <= 1; stride_c <= 1;
        end else begin
            previous_start <= start;
            case (state)
                IDLE: if (start && !previous_start) begin
                    base_a <= address_mat_a; base_b <= address_mat_b; base_c <= address_mat_c;
                    stride_a <= address_stride_a; stride_b <= address_stride_b; stride_c <= address_stride_c;
                    done <= 0;
                    state <= PREPARE;
                end
                PREPARE: state <= RUN;
                RUN: if (core_done) begin state <= IDLE; done <= 1; end
                default: state <= IDLE;
            endcase
        end
    end

    wire [9:0] a_top_addr, a_bottom_addr, b_left_addr, b_right_addr, c_write_addr;
    wire [31:0] a_top_data, a_bottom_data, b_left_data, b_right_data;
    wire [31:0] c_top_data, c_bottom_data;
    wire c_write_valid;
    // Full-word writes retain the provided RAM semantics. Host loading is
    // allowed while idle (also during global reset), never while computing.
    wire host_write = load_we && !busy;
    part3_ram matrix_A_top (.clk(clk), .addr0(a_top_addr), .d0(32'd0), .we0(1'b0), .q0(a_top_data),
        .addr1(load_addr_a), .d1(load_a[31:0]), .we1(host_write), .q1(read_a[31:0]));
    part3_ram matrix_A_bottom (.clk(clk), .addr0(a_bottom_addr), .d0(32'd0), .we0(1'b0), .q0(a_bottom_data),
        .addr1(load_addr_a), .d1(load_a[63:32]), .we1(host_write), .q1(read_a[63:32]));
    part3_ram matrix_B_left (.clk(clk), .addr0(b_left_addr), .d0(32'd0), .we0(1'b0), .q0(b_left_data),
        .addr1(load_addr_b), .d1(load_b[31:0]), .we1(host_write), .q1(read_b[31:0]));
    part3_ram matrix_B_right (.clk(clk), .addr0(b_right_addr), .d0(32'd0), .we0(1'b0), .q0(b_right_data),
        .addr1(load_addr_b), .d1(load_b[63:32]), .we1(host_write), .q1(read_b[63:32]));
    part3_ram matrix_C_top (.clk(clk), .addr0(c_write_addr), .d0(c_top_data), .we0(c_write_valid), .q0(),
        .addr1(read_addr_c), .d1(32'd0), .we1(1'b0), .q1(read_c[31:0]));
    part3_ram matrix_C_bottom (.clk(clk), .addr0(c_write_addr), .d0(c_bottom_data), .we0(c_write_valid), .q0(),
        .addr1(read_addr_c), .d1(32'd0), .we1(1'b0), .q1(read_c[63:32]));

    matmul_8x8 u_matmul_8x8 (
        .clk(clk), .reset(core_reset), .pe_reset(core_pe_reset), .start_mat_mul(core_run),
        .address_mat_a(base_a), .address_mat_b(base_b), .address_mat_c(base_c),
        .address_stride_a(stride_a), .address_stride_b(stride_b), .address_stride_c(stride_c),
        .a_top_data(a_top_data), .a_bottom_data(a_bottom_data), .b_left_data(b_left_data), .b_right_data(b_right_data),
        .a_top_addr(a_top_addr), .a_bottom_addr(a_bottom_addr), .b_left_addr(b_left_addr), .b_right_addr(b_right_addr),
        .c_addr(c_write_addr), .c_top_data(c_top_data), .c_bottom_data(c_bottom_data),
        .c_write_valid(c_write_valid), .done_mat_mul(core_done), .exception_flags(exception_flags)
    );
endmodule

// Same read-first, one-clock response as the instructor RAM; use whole words.
// Reset does not erase RAM. The two write ports must not target the same word.
module part3_ram (
    input wire clk,
    input wire [9:0] addr0, addr1,
    input wire [31:0] d0, d1,
    input wire we0, we1,
    output logic [31:0] q0, q1
);
    logic [31:0] ram [0:1023];
    always @(posedge clk) begin
        if (we0) ram[addr0] <= d0;
        q0 <= ram[addr0];
    end
    always @(posedge clk) begin
        if (we1) ram[addr1] <= d1;
        q1 <= ram[addr1];
    end
endmodule
`default_nettype wire
