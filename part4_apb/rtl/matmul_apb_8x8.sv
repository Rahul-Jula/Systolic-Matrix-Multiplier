`timescale 1ns/1ps
`default_nettype none
// Part III RAM datapath retained; its host FSM is replaced by APB ownership.
module matmul_apb_8x8 (
    input wire PCLK, PRESETn,
    input wire [9:0] PADDR,
    input wire PWRITE, PSEL, PENABLE,
    input wire [15:0] PWDATA,
    output wire [15:0] PRDATA,
    output wire PREADY,
    input wire [9:0] load_addr_a, load_addr_b, read_addr_c,
    input wire [63:0] load_a, load_b,
    input wire load_we,
    output wire [63:0] read_a, read_b, read_c
);
    wire [9:0] base_a, base_b, base_c;
    wire [7:0] stride_a, stride_b, stride_c;
    wire engine_busy, core_run, core_reset, core_done, start_pulse, done_reg;
    wire [4:0] core_flags, flags_reg;
    apb_matmul_control ctrl (.*);
    wire [9:0] a_top_addr, a_bottom_addr, b_left_addr, b_right_addr, c_write_addr;
    wire [31:0] a_top_data, a_bottom_data, b_left_data, b_right_data;
    wire [31:0] c_top_data, c_bottom_data;
    wire c_write_valid;
    // Full-word writes retain the provided RAM semantics. Host loading is
    // allowed while idle (also during global reset), never while computing.
    wire host_write = load_we && !engine_busy;
    part3_ram matrix_A_top (.clk(PCLK), .addr0(a_top_addr), .d0(32'd0), .we0(1'b0), .q0(a_top_data),
        .addr1(load_addr_a), .d1(load_a[31:0]), .we1(host_write), .q1(read_a[31:0]));
    part3_ram matrix_A_bottom (.clk(PCLK), .addr0(a_bottom_addr), .d0(32'd0), .we0(1'b0), .q0(a_bottom_data),
        .addr1(load_addr_a), .d1(load_a[63:32]), .we1(host_write), .q1(read_a[63:32]));
    part3_ram matrix_B_left (.clk(PCLK), .addr0(b_left_addr), .d0(32'd0), .we0(1'b0), .q0(b_left_data),
        .addr1(load_addr_b), .d1(load_b[31:0]), .we1(host_write), .q1(read_b[31:0]));
    part3_ram matrix_B_right (.clk(PCLK), .addr0(b_right_addr), .d0(32'd0), .we0(1'b0), .q0(b_right_data),
        .addr1(load_addr_b), .d1(load_b[63:32]), .we1(host_write), .q1(read_b[63:32]));
    part3_ram matrix_C_top (.clk(PCLK), .addr0(c_write_addr), .d0(c_top_data), .we0(c_write_valid), .q0(),
        .addr1(read_addr_c), .d1(32'd0), .we1(1'b0), .q1(read_c[31:0]));
    part3_ram matrix_C_bottom (.clk(PCLK), .addr0(c_write_addr), .d0(c_bottom_data), .we0(c_write_valid), .q0(),
        .addr1(read_addr_c), .d1(32'd0), .we1(1'b0), .q1(read_c[63:32]));

    matmul_8x8 u_matmul_8x8 (
        .clk(PCLK), .reset(core_reset), .pe_reset(core_reset), .start_mat_mul(core_run),
        .address_mat_a(base_a), .address_mat_b(base_b), .address_mat_c(base_c),
        .address_stride_a(stride_a), .address_stride_b(stride_b), .address_stride_c(stride_c),
        .a_top_data(a_top_data), .a_bottom_data(a_bottom_data), .b_left_data(b_left_data), .b_right_data(b_right_data),
        .a_top_addr(a_top_addr), .a_bottom_addr(a_bottom_addr), .b_left_addr(b_left_addr), .b_right_addr(b_right_addr),
        .c_addr(c_write_addr), .c_top_data(c_top_data), .c_bottom_data(c_bottom_data),
        .c_write_valid(c_write_valid), .done_mat_mul(core_done), .exception_flags(core_flags)
    );
endmodule

`default_nettype wire
