`timescale 1ns/1ps
`default_nettype none
// Four unchanged Part II tiles; no memories or host controller in this top.
// start_mat_mul is a LEVEL held through all eight committed C transfers.
module matmul_8x8 (
    input wire clk, reset, pe_reset, start_mat_mul,
    input wire [9:0] address_mat_a, address_mat_b, address_mat_c,
    input wire [7:0] address_stride_a, address_stride_b, address_stride_c,
    input wire [31:0] a_top_data, a_bottom_data, b_left_data, b_right_data,
    output wire [9:0] a_top_addr, a_bottom_addr, b_left_addr, b_right_addr,
    output wire [9:0] c_addr,
    output wire [31:0] c_top_data, c_bottom_data,
    output wire c_write_valid,
    output logic done_mat_mul,
    output wire [4:0] exception_flags
);
    localparam logic [7:0] CAPTURE_CYCLE = 8'd26; // 3*N-1 + MAC latency
    logic [7:0] run_cycle;
    logic [3:0] written_columns;
    wire [31:0] a00_to_01, a10_to_11, b00_to_10, b01_to_11;
    wire [31:0] c01_to_00, c11_to_10;
    wire [3:0] legacy_done, tile_c_valid;
    wire [4:0] tile_flags [0:3];

    assign exception_flags = tile_flags[0] | tile_flags[1] |
                             tile_flags[2] | tile_flags[3];
    // The inherited done pulse (count 17) resets tile output addresses early.
    // Own the bank address here; never use that corrupted legacy C address.
    assign c_addr = address_mat_c + written_columns * address_stride_c;
    assign c_write_valid = start_mat_mul && !reset && !pe_reset &&
                           run_cycle > CAPTURE_CYCLE &&
                           written_columns < 8 && tile_c_valid[0] && tile_c_valid[2];
    always_ff @(posedge clk) begin
        if (reset || !start_mat_mul) begin
            run_cycle <= 0;
            written_columns <= 0;
            done_mat_mul <= 0;
        end else begin
            if (!done_mat_mul) run_cycle <= run_cycle + 1'b1;
            if (c_write_valid) begin
                written_columns <= written_columns + 1'b1;
                if (written_columns == 7) done_mat_mul <= 1;
            end
        end
    end

    // a_loc is TILE ROW, b_loc TILE COLUMN (0/1, not global PE 0/4).
    matmul_4x4_systolic tile00 (
        .clk(clk), .reset(reset), .pe_reset(pe_reset), .start_mat_mul(start_mat_mul),
        .done_mat_mul(legacy_done[0]), .exception_flags(tile_flags[0]),
        .address_mat_a(address_mat_a), .address_mat_b(address_mat_b), .address_mat_c(address_mat_c),
        .address_stride_a(address_stride_a), .address_stride_b(address_stride_b), .address_stride_c(address_stride_c),
        .a_data(a_top_data), .b_data(b_left_data), .a_data_in(32'd0), .b_data_in(32'd0),
        .a_data_out(a00_to_01), .b_data_out(b00_to_10),
        .c_data_in(c01_to_00), .c_data_out(c_top_data), .c_data_available(tile_c_valid[0]),
        .a_addr(a_top_addr), .b_addr(b_left_addr), .c_addr(),
        .validity_mask_a_rows(4'hf), .validity_mask_a_cols_b_rows(4'hf), .validity_mask_b_cols(4'hf),
        .final_mat_mul_size(8'd8), .a_loc(8'd0), .b_loc(8'd0)
    );
    matmul_4x4_systolic tile01 (
        .clk(clk), .reset(reset), .pe_reset(pe_reset), .start_mat_mul(start_mat_mul),
        .done_mat_mul(legacy_done[1]), .exception_flags(tile_flags[1]),
        .address_mat_a(address_mat_a), .address_mat_b(address_mat_b), .address_mat_c(address_mat_c),
        .address_stride_a(address_stride_a), .address_stride_b(address_stride_b), .address_stride_c(address_stride_c),
        .a_data(32'd0), .b_data(b_right_data), .a_data_in(a00_to_01), .b_data_in(32'd0),
        .a_data_out(), .b_data_out(b01_to_11),
        .c_data_in(32'd0), .c_data_out(c01_to_00), .c_data_available(tile_c_valid[1]),
        .a_addr(), .b_addr(b_right_addr), .c_addr(),
        .validity_mask_a_rows(4'hf), .validity_mask_a_cols_b_rows(4'hf), .validity_mask_b_cols(4'hf),
        .final_mat_mul_size(8'd8), .a_loc(8'd0), .b_loc(8'd1)
    );
    matmul_4x4_systolic tile10 (
        .clk(clk), .reset(reset), .pe_reset(pe_reset), .start_mat_mul(start_mat_mul),
        .done_mat_mul(legacy_done[2]), .exception_flags(tile_flags[2]),
        .address_mat_a(address_mat_a), .address_mat_b(address_mat_b), .address_mat_c(address_mat_c),
        .address_stride_a(address_stride_a), .address_stride_b(address_stride_b), .address_stride_c(address_stride_c),
        .a_data(a_bottom_data), .b_data(32'd0), .a_data_in(32'd0), .b_data_in(b00_to_10),
        .a_data_out(a10_to_11), .b_data_out(),
        .c_data_in(c11_to_10), .c_data_out(c_bottom_data), .c_data_available(tile_c_valid[2]),
        .a_addr(a_bottom_addr), .b_addr(), .c_addr(),
        .validity_mask_a_rows(4'hf), .validity_mask_a_cols_b_rows(4'hf), .validity_mask_b_cols(4'hf),
        .final_mat_mul_size(8'd8), .a_loc(8'd1), .b_loc(8'd0)
    );
    matmul_4x4_systolic tile11 (
        .clk(clk), .reset(reset), .pe_reset(pe_reset), .start_mat_mul(start_mat_mul),
        .done_mat_mul(legacy_done[3]), .exception_flags(tile_flags[3]),
        .address_mat_a(address_mat_a), .address_mat_b(address_mat_b), .address_mat_c(address_mat_c),
        .address_stride_a(address_stride_a), .address_stride_b(address_stride_b), .address_stride_c(address_stride_c),
        .a_data(32'd0), .b_data(32'd0), .a_data_in(a10_to_11), .b_data_in(b01_to_11),
        .a_data_out(), .b_data_out(),
        .c_data_in(32'd0), .c_data_out(c11_to_10), .c_data_available(tile_c_valid[3]),
        .a_addr(), .b_addr(), .c_addr(),
        .validity_mask_a_rows(4'hf), .validity_mask_a_cols_b_rows(4'hf), .validity_mask_b_cols(4'hf),
        .final_mat_mul_size(8'd8), .a_loc(8'd1), .b_loc(8'd1)
    );
endmodule
`default_nettype wire
