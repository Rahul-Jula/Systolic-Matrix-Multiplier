`timescale 1ns/1ps
`default_nettype none
// APB control/status for the unchanged Part III core. Inspired by the supplied
// baseline/apb_slave.v; the zero-wait slave completes on ACCESS, never SETUP.
module apb_matmul_control (
    input wire PCLK, PRESETn,
    input wire [9:0] PADDR,
    input wire PWRITE, PSEL, PENABLE,
    input wire [15:0] PWDATA,
    output logic [15:0] PRDATA,
    output wire PREADY,
    input wire core_done,
    input wire [4:0] core_flags,
    output logic [9:0] base_a, base_b, base_c,
    output logic [7:0] stride_a, stride_b, stride_c,
    output wire engine_busy, core_run, core_reset,
    output logic start_pulse, done_reg,
    output logic [4:0] flags_reg
);
    typedef enum logic [1:0] {IDLE, PREPARE, RUN} state_t;
    state_t state;
    wire write_access = PSEL && PENABLE && PREADY && PWRITE;
    assign PREADY = 1'b1;
    assign engine_busy = state != IDLE;
    assign core_run = state == RUN;
    assign core_reset = !PRESETn || state == PREPARE;

    // Full byte-address decode. Read data is valid before the completing edge.
    always_comb begin
        PRDATA = 16'b0;
        case (PADDR)
            10'h000: PRDATA = {15'b0,start_pulse};
            10'h002: PRDATA = {6'b0,base_a};
            10'h004: PRDATA = {6'b0,base_b};
            10'h006: PRDATA = {6'b0,base_c};
            10'h008: PRDATA = {8'b0,stride_a};
            10'h00a: PRDATA = {8'b0,stride_b};
            10'h00c: PRDATA = {8'b0,stride_c};
            10'h00e: PRDATA = {done_reg,engine_busy,14'b0};
            10'h010: PRDATA = {11'b0,flags_reg};
            default: PRDATA = 16'b0;
        endcase
    end
    // CSRs are frozen while busy, so they also serve as stable active config.
    // PREPARE clears accumulators/flags every job without erasing matrix RAM.
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state <= IDLE;
            base_a <= 0; base_b <= 0; base_c <= 0;
            stride_a <= 1; stride_b <= 1; stride_c <= 1;
            start_pulse <= 0; done_reg <= 0; flags_reg <= 0;
        end else begin
            start_pulse <= 0;
            case (state)
                IDLE: if (write_access) begin
                    case (PADDR)
                        10'h000: if (PWDATA[0]) begin
                            start_pulse <= 1; done_reg <= 0; flags_reg <= 0;
                            state <= PREPARE;
                        end
                        10'h002: base_a <= PWDATA[9:0];
                        10'h004: base_b <= PWDATA[9:0];
                        10'h006: base_c <= PWDATA[9:0];
                        10'h008: stride_a <= PWDATA[7:0];
                        10'h00a: stride_b <= PWDATA[7:0];
                        10'h00c: stride_c <= PWDATA[7:0];
                        default: begin end // RO, odd, and unmapped writes ignored.
                    endcase
                end
                PREPARE: state <= RUN;
                RUN: if (core_done) begin
                    // New core done follows the eighth committed C write.
                    flags_reg <= core_flags; done_reg <= 1; state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
`default_nettype wire
