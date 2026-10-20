`timescale 1ns/1ps
`default_nettype none
// Generated oracle vectors are checked against the actual combinational RTL.
// Exhaustive: every 8-bit input encoding, including DAZ inputs and NaNs.
module tb_fp8_exhaustive;
    logic [7:0] a, b;
    wire [7:0] add_result, mul_result;
    wire [4:0] add_flags, mul_flags;
    logic [28:0] add_vectors [0:65535];
    logic [28:0] mul_vectors [0:65535];
    integer errors;

    fp8_adder add_dut(.a(a), .b(b), .result(add_result), .flags(add_flags));
    fp8_multiplier mul_dut(.a(a), .b(b), .result(mul_result), .flags(mul_flags));

    initial begin
        errors = 0;
        a = 0;
        b = 0;
        $readmemh("build/add_vectors.hex", add_vectors);
        $readmemh("build/mul_vectors.hex", mul_vectors);
        for (int i = 0; i < 65536; i = i + 1) begin
            {a, b} = add_vectors[i][28:13];
            #1;
            if ({add_result, add_flags} !== add_vectors[i][12:0]) begin
                if (errors < 10)
                    $display("ADD mismatch a=%h b=%h got=%h/%b expected=%h/%b",
                             a, b, add_result, add_flags,
                             add_vectors[i][12:5], add_vectors[i][4:0]);
                errors = errors + 1;
            end
            if ({mul_result, mul_flags} !== mul_vectors[i][12:0]) begin
                if (errors < 10)
                    $display("MUL mismatch a=%h b=%h got=%h/%b expected=%h/%b",
                             a, b, mul_result, mul_flags,
                             mul_vectors[i][12:5], mul_vectors[i][4:0]);
                errors = errors + 1;
            end
        end
        if (errors != 0) $fatal(1, "Exhaustive verification failed: %0d mismatches", errors);
        $display("PASS: 65,536 ADD and 65,536 MUL result+flag checks (131,072 total)");
        $finish;
    end
endmodule
`default_nettype wire
