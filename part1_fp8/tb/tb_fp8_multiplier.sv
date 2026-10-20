`timescale 1ns/1ps
`default_nettype none
// Directed, self-checking waveform test. Expected values are constants.
// First five cases cover positive, negative, zero, overflow, and invalid.
module tb_fp8_multiplier;
    logic [7:0] a, b;
    wire [7:0] result;
    wire [4:0] flags;
    logic [7:0] expected_result;
    logic [4:0] expected_flags;
    integer case_id;
    integer checked;
    fp8_multiplier dut(.a(a), .b(b), .result(result), .flags(flags));

    task automatic check_case(input integer id, input logic [7:0] av, bv,
                              input logic [7:0] expected,
                              input logic [4:0] expected_exc,
                              input string description);
        case_id = id; a = av; b = bv;
        expected_result = expected; expected_flags = expected_exc;
        #1;
        if ((result !== expected) || (flags !== expected_exc))
            $fatal(1, "Case %0d FAIL: %s a=%h b=%h got=%h/%b expected=%h/%b",
                   id, description, a, b, result, flags, expected, expected_exc);
        $display("PASS case %0d: %s | a=%h b=%h result=%h flags=%b",
                 id, description, a, b, result, flags);
        checked = checked + 1;
        #9;
    endtask

    initial begin
`ifdef FSDB
        $fsdbDumpfile("build/fp8_multiplier.fsdb");
        $fsdbDumpvars(0, tb_fp8_multiplier);
`else
        $dumpfile("build/fp8_multiplier.vcd");
        $dumpvars(0, tb_fp8_multiplier);
`endif
        checked = 0; case_id = 0; a = 0; b = 0;
        expected_result = 0; expected_flags = 0;
        #10;
        check_case(1, 8'h38, 8'h40, 8'h48, 5'b00000, "positive normals: 1.5 * 2 = 3");
        check_case(2, 8'hb8, 8'h40, 8'hc8, 5'b00000, "negative times positive: -1.5 * 2 = -3");
        check_case(3, 8'h00, 8'h40, 8'h00, 5'b00000, "multiply by zero: +0 * 2 = +0");
        check_case(4, 8'h6f, 8'h40, 8'h70, 5'b10001, "overflow: 15.5 * 2 -> +infinity");
        check_case(5, 8'h00, 8'h70, 8'h78, 5'b00010, "invalid: zero * infinity -> quiet NaN");
        check_case(6, 8'h31, 8'h31, 8'h32, 5'b00001, "inexact normal: 1.0625 squared -> 1.125");
        check_case(7, 8'h10, 8'h10, 8'h00, 5'b01001, "underflow: 0.25 squared -> +0");
        check_case(8, 8'h10, 8'h30, 8'h10, 5'b00000, "minimum normal preserved: 0.25 * 1");
        check_case(9, 8'h80, 8'h40, 8'h80, 5'b00000, "signed zero: -0 * 2 = -0");
        check_case(10, 8'hf0, 8'hb0, 8'h70, 5'b00000, "infinity sign: -infinity * -1 = +infinity");
        check_case(11, 8'h78, 8'h30, 8'h78, 5'b00000, "quiet NaN propagation");
        check_case(12, 8'h71, 8'h30, 8'h78, 5'b00010, "signaling NaN: invalid");
        check_case(13, 8'h01, 8'h40, 8'h00, 5'b00000, "unsupported denormal input treated as zero");
        check_case(14, 8'h3f, 8'h31, 8'h40, 5'b00001, "normalization carry: 1.9375 * 1.0625 -> 2");
        check_case(15, 8'h6f, 8'h31, 8'h70, 5'b10001, "overflow after multiplication");
        check_case(16, 8'h90, 8'h10, 8'h80, 5'b01001, "negative underflow -> -0");
        check_case(17, 8'h70, 8'h00, 8'h78, 5'b00010, "invalid operation in reversed operand order");
        check_case(18, 8'hb8, 8'hc0, 8'h48, 5'b00000, "two negative normals: -1.5 * -2 = 3");
        $display("PASS: %0d directed multiplier cases", checked);
        $finish;
    end
endmodule
`default_nettype wire
