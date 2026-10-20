`timescale 1ns/1ps
`default_nettype none
// Directed, self-checking waveform test. Expected values are constants.
// First five cases cover positive, negative, zero, overflow, and invalid.
module tb_fp8_adder;
    logic [7:0] a, b;
    wire [7:0] result;
    wire [4:0] flags;
    logic [7:0] expected_result;
    logic [4:0] expected_flags;
    integer case_id;
    integer checked;
    fp8_adder dut(.a(a), .b(b), .result(result), .flags(flags));

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
        $fsdbDumpfile("build/fp8_adder.fsdb");
        $fsdbDumpvars(0, tb_fp8_adder);
`else
        $dumpfile("build/fp8_adder.vcd");
        $dumpvars(0, tb_fp8_adder);
`endif
        checked = 0; case_id = 0; a = 0; b = 0;
        expected_result = 0; expected_flags = 0;
        #10;
        check_case(1, 8'h30, 8'h38, 8'h44, 5'b00000, "positive normals: 1 + 1.5 = 2.5");
        check_case(2, 8'hb8, 8'hb0, 8'hc4, 5'b00000, "negative normals: -1.5 + -1 = -2.5");
        check_case(3, 8'h00, 8'h38, 8'h38, 5'b00000, "zero identity: +0 + 1.5 = 1.5");
        check_case(4, 8'h6f, 8'h6f, 8'h70, 5'b10001, "overflow: 15.5 + 15.5 -> +infinity");
        check_case(5, 8'h70, 8'hf0, 8'h78, 5'b00010, "invalid: +infinity + -infinity -> quiet NaN");
        check_case(6, 8'h38, 8'hb0, 8'h20, 5'b00000, "opposite signs: 1.5 - 1 = 0.5");
        check_case(7, 8'h30, 8'hb0, 8'h00, 5'b00000, "exact cancellation: 1 - 1 = +0");
        check_case(8, 8'h80, 8'h80, 8'h80, 5'b00000, "signed zeros: -0 + -0 = -0");
        check_case(9, 8'h00, 8'h80, 8'h00, 5'b00000, "signed zeros: +0 + -0 = +0");
        check_case(10, 8'h70, 8'h30, 8'h70, 5'b00000, "infinity propagation: +infinity + 1");
        check_case(11, 8'hf0, 8'h30, 8'hf0, 5'b00000, "infinity propagation: -infinity + 1");
        check_case(12, 8'h78, 8'h30, 8'h78, 5'b00000, "quiet NaN propagates without invalid");
        check_case(13, 8'h71, 8'h30, 8'h78, 5'b00010, "signaling NaN is quieted; invalid");
        check_case(14, 8'h30, 8'h10, 8'h34, 5'b00000, "different exponents: 1 + 0.25 = 1.25");
        check_case(15, 8'h30, 8'h01, 8'h30, 5'b00000, "unsupported denormal input treated as zero");
        check_case(16, 8'h11, 8'h90, 8'h00, 5'b01001, "underflow: 0.265625 - 0.25 -> +0");
        check_case(17, 8'h30, 8'h12, 8'h34, 5'b00001, "round-to-even tie down: 1 + 0.28125 -> 1.25");
        check_case(18, 8'h31, 8'h12, 8'h36, 5'b00001, "round-to-even tie up: 1.0625 + 0.28125 -> 1.375");
        check_case(19, 8'h4f, 8'h10, 8'h50, 5'b00001, "post-normalization tie: 3.875 + 0.25 -> 4");
        check_case(20, 8'h6f, 8'h18, 8'h70, 5'b10001, "rounding overflow: 15.5 + 0.375 -> +infinity");
        check_case(21, 8'h10, 8'h10, 8'h20, 5'b00000, "smallest normals: 0.25 + 0.25 = 0.5");
        check_case(22, 8'ha0, 8'h10, 8'h90, 5'b00000, "negative result: -0.5 + 0.25 = -0.25");
        $display("PASS: %0d directed adder cases", checked);
        $finish;
    end
endmodule
`default_nettype wire
