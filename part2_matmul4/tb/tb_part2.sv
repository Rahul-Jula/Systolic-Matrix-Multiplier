`timescale 1ns/1ps
module tb_part2;
    logic clk = 0;
    always #10 clk = ~clk;
    logic resetn = 0, pe_resetn = 0, start = 0;
    wire done;
    logic [9:0] load_addr = 0;
    logic [31:0] load_a = 0, load_b = 0;
    logic [3:0] load_we = 0;
    wire [31:0] read_a, read_b, read_c;
    logic [31:0] a_words[0:3], b_words[0:3], expected_words[0:3];
    logic [4:0] expected_flags;
    integer testcase_id = 0;
    integer checked_entries = 0;
    integer c_write_count = 0;
    integer selected_case = 0;
    logic [31:0] final_c0, final_c1, final_c2, final_c3;

    matrix_multiplication dut (
        .clk(clk), .resetn(resetn), .pe_resetn(pe_resetn),
        .address_mat_a(10'd0), .address_mat_b(10'd0), .address_mat_c(10'd0),
        .address_stride_a(8'd1), .address_stride_b(8'd1), .address_stride_c(8'd1),
        .bram_addr_a_ext(load_addr), .bram_rdata_a_ext(read_a),
        .bram_wdata_a_ext(load_a), .bram_we_a_ext(load_we),
        .bram_addr_b_ext(load_addr), .bram_rdata_b_ext(read_b),
        .bram_wdata_b_ext(load_b), .bram_we_b_ext(load_we),
        .bram_addr_c_ext(10'd0), .bram_rdata_c_ext(read_c),
        .bram_wdata_c_ext(32'd0), .bram_we_c_ext(4'd0),
        .start(start), .done(done)
    );
`ifdef BASELINE
    wire [4:0] exception_flags = 0;
`else
    wire [4:0] exception_flags = dut.u_matmul_4x4.exception_flags;
    wire [4:0] pe33_flags = dut.u_matmul_4x4.u_systolic_pe_matrix.pe33.exception_flags;
    wire [4:0] pe33_product_flags = dut.u_matmul_4x4.u_systolic_pe_matrix.pe33.u_mac.product_flags;
    wire [4:0] pe33_add_flags = dut.u_matmul_4x4.u_systolic_pe_matrix.pe33.u_mac.add_flags;
`endif
    // Convenient waveform aliases, directly driven by actual DUT signals.
    wire [9:0] c_write_addr = dut.bram_addr_c;
    wire [31:0] c_write_data = dut.bram_wdata_c;
    wire [3:0] c_write_enable = dut.bram_we_c;
    wire core_start = dut.start_mat_mul;
    wire [7:0] core_cycle = dut.u_matmul_4x4.clk_cnt;
    wire [31:0] a_stream = dut.bram_rdata_a;
    wire [31:0] b_stream = dut.bram_rdata_b;

    `include "cases.svh"

    always @(posedge clk) begin
        if (resetn && (|c_write_enable)) begin
            if ($isunknown({c_write_addr,c_write_data}))
                $fatal(1, "Unknown C write at %0t", $time);
            c_write_count = c_write_count + 1;
            $display("EVENT case=%0d C_WRITE t=%0t addr=%0d data=%08h", testcase_id,$time,c_write_addr,c_write_data);
        end
    end

    task automatic run_case(input integer which);
        integer k, row;
        begin
            @(negedge clk);
            testcase_id = which;
            resetn = 0; pe_resetn = 0; start = 0; load_we = 0;
            c_write_count = 0;
            checked_entries = 0;
            final_c0 = 0; final_c1 = 0; final_c2 = 0; final_c3 = 0;
`ifdef BASELINE
            // Instructor sample: A columns and B rows, low byte first.
            a_words[0]=32'h09050308; a_words[1]=32'h01020304;
            a_words[2]=32'h00010306; a_words[3]=32'h05060708;
            b_words[0]=32'h00030101; b_words[1]=32'h03040100;
            b_words[2]=32'h01030503; b_words[3]=32'h02030609;
            expected_words[0]=32'h363e4b62; expected_words[1]=32'h28303f5a;
            expected_words[2]=32'h2e2c3352; expected_words[3]=32'h0d131a22;
            expected_flags=0;
`else
            load_case(which == 3 ? 1 : which);
`endif
            repeat (3) @(negedge clk);
            if (exception_flags !== 5'b0) $fatal(1,"Reset did not clear flags");
            // Keep core reset during loading; exercise actual external RAM ports.
            for (k=0; k<4; k=k+1) begin
                load_addr=k; load_a=a_words[k]; load_b=b_words[k]; load_we=4'hf;
                $display("EVENT case=%0d LOAD t=%0t addr=%0d A=%08h B=%08h",which,$time,k,load_a,load_b);
                @(negedge clk);
            end
            load_we=0;
            for (k=0;k<4;k=k+1) begin
                if (dut.matrix_A.ram[k] !== a_words[k] || dut.matrix_B.ram[k] !== b_words[k])
                    $fatal(1,"RAM load mismatch word %0d",k);
            end
            resetn=1; pe_resetn=1;
            repeat (2) @(negedge clk);
            start=1;
            $display("EVENT case=%0d START t=%0t",which,$time);
            @(negedge clk); start=0;
            wait(done === 1'b1);
            $display("EVENT case=%0d DONE t=%0t flags=%05b",which,$time,exception_flags);
            // Final output write occurs on the next rising edge after done.
            repeat(3) @(negedge clk);
            if (c_write_count != 4) $fatal(1,"Expected 4 C writes, got %0d",c_write_count);
            if (exception_flags !== expected_flags)
                $fatal(1,"Flags got=%05b expected=%05b",exception_flags,expected_flags);
            for(k=0;k<4;k=k+1)
                for(row=0;row<4;row=row+1) begin
                    $display("CHECK case=%0d C[%0d][%0d] actual=%02h expected=%02h",which,row,k,dut.matrix_C.ram[k][8*row +: 8],expected_words[k][8*row +: 8]);
                    if(dut.matrix_C.ram[k][8*row +: 8] !== expected_words[k][8*row +: 8])
                        $fatal(1,"Matrix mismatch at [%0d][%0d]",row,k);
                    checked_entries=checked_entries+1;
                end
            final_c0=dut.matrix_C.ram[0]; final_c1=dut.matrix_C.ram[1];
            final_c2=dut.matrix_C.ram[2]; final_c3=dut.matrix_C.ram[3];
            $display("PASS case=%0d all %0d entries flags=%05b t=%0t",which,checked_entries,exception_flags,$time);
            repeat(4) @(negedge clk);
        end
    endtask

    initial begin
        $timeformat(-9, 0, " ns", 12);
`ifdef BASELINE
        $dumpfile("build/baseline.vcd");
        $dumpvars(0,tb_part2);
        run_case(0);
`else
        if (!$value$plusargs("CASE=%d", selected_case)) selected_case=0;
`ifdef FSDB
        if(selected_case==1) $fsdbDumpfile("build/clean.fsdb");
        else if(selected_case==2) $fsdbDumpfile("build/exception.fsdb");
        else $fsdbDumpfile("build/sequence.fsdb");
        $fsdbDumpvars(0,tb_part2);
        $fsdbDumpMDA();
`endif
        if(selected_case==1) $dumpfile("build/clean.vcd");
        else if(selected_case==2) $dumpfile("build/exception.vcd");
        else $dumpfile("build/sequence.vcd");
        $dumpvars(0,tb_part2);
        if(selected_case!=0) run_case(selected_case);
        else begin run_case(1); run_case(2); run_case(3); end
`endif
        $display("PART2 SIMULATION PASS");
        $finish;
    end
    initial begin #10000; $fatal(1,"Timeout waiting for completion"); end
endmodule
