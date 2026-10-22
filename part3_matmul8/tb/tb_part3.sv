`timescale 1ns/1ps
module tb_part3;
    logic clk = 0;
    always #10 clk = ~clk;
    logic resetn = 0, pe_resetn = 0, start = 0, load_we = 0;
    logic [9:0] address_mat_a = 0, address_mat_b = 0, address_mat_c = 0;
    logic [7:0] address_stride_a = 1, address_stride_b = 1, address_stride_c = 1;
    logic [9:0] load_addr_a = 0, load_addr_b = 0, read_addr_c = 0;
    logic [63:0] load_a = 0, load_b = 0;
    wire [63:0] read_a, read_b, read_c;
    wire busy, done;
    wire [4:0] exception_flags;
    logic [63:0] a_words [0:7], b_words [0:7], expected_words [0:7];
    // These waveform arrays snapshot ACTUAL RAM, never expected-value arrays.
    logic [63:0] loaded_a [0:7], loaded_b [0:7], final_c [0:7];
    logic [4:0] expected_flags;
    integer testcase_id = 0, checked_entries = 0, c_write_count = 0;
    integer cycle = 0, start_cycle = 0, first_run_cycle = 0, final_write_cycle = 0;
    integer total_checked = 0, selected_case = 0;
    integer edge_checks_a = 0, edge_checks_b = 0, neighbor_checks = 0;

    matmul_with_ram_8x8 dut (.*);
    `include "cases.svh"
    wire internal_run = dut.core_run;
    wire [7:0] core_cycle = dut.u_matmul_8x8.run_cycle;
    wire [3:0] tile_legacy_done = dut.u_matmul_8x8.legacy_done;
    wire [9:0] c_write_addr = dut.c_write_addr;
    wire c_write_valid = dut.c_write_valid;
    wire [63:0] c_write_data = {dut.c_bottom_data, dut.c_top_data};
    wire [31:0] a_top_read = dut.a_top_data, a_bottom_read = dut.a_bottom_data;
    wire [31:0] b_left_read = dut.b_left_data, b_right_read = dut.b_right_data;
    wire [31:0] a00_to_01 = dut.u_matmul_8x8.a00_to_01;
    wire [31:0] a10_to_11 = dut.u_matmul_8x8.a10_to_11;
    wire [31:0] b00_to_10 = dut.u_matmul_8x8.b00_to_10;
    wire [31:0] b01_to_11 = dut.u_matmul_8x8.b01_to_11;
    wire a_top_valid = dut.u_matmul_8x8.tile00.u_systolic_data_setup.a_data_valid;
    wire a_bottom_valid = dut.u_matmul_8x8.tile10.u_systolic_data_setup.a_data_valid;
    wire b_left_valid = dut.u_matmul_8x8.tile00.u_systolic_data_setup.b_data_valid;
    wire b_right_valid = dut.u_matmul_8x8.tile01.u_systolic_data_setup.b_data_valid;

    always @(posedge clk) begin
        cycle = cycle + 1;
        if (resetn && internal_run) begin
            if ($isunknown({core_cycle,c_write_valid,tile_legacy_done,exception_flags}))
                $fatal(1,"Unknown active control");
            if (core_cycle == 0) begin
                first_run_cycle = cycle;
                $display("EVENT case=%0d FIRST_RUN t=%0t cycle=%0d",testcase_id,$time,cycle);
            end
            if (|tile_legacy_done)
                $display("EVENT case=%0d LEGACY_DONE_IGNORED t=%0t cycle=%0d core=%0d",testcase_id,$time,cycle,core_cycle);
            if (core_cycle == 26)
                $display("EVENT case=%0d CAPTURE t=%0t cycle=%0d",testcase_id,$time,cycle);
            // Check every full-word input RAM response against the matrix
            // packing, at its true synchronous response/skew position.
            if (a_top_valid) begin
                if (a_top_read !== a_words[core_cycle-2][31:0]) $fatal(1,"A top stream");
                edge_checks_a = edge_checks_a + 1;
            end
            if (a_bottom_valid) begin
                if (a_bottom_read !== a_words[core_cycle-6][63:32]) $fatal(1,"A bottom stream");
                edge_checks_a = edge_checks_a + 1;
            end
            if (b_left_valid) begin
                if (b_left_read !== b_words[core_cycle-2][31:0]) $fatal(1,"B left stream");
                edge_checks_b = edge_checks_b + 1;
            end
            if (b_right_valid) begin
                if (b_right_read !== b_words[core_cycle-6][63:32]) $fatal(1,"B right stream");
                edge_checks_b = edge_checks_b + 1;
            end
            // Lane 0 crosses one 4-PE tile in 4 clocks. Check actual data
            // against independent input words, not merely equal tied wires.
            if (core_cycle >= 6 && core_cycle <= 13) begin
                if (a00_to_01[7:0] !== a_words[core_cycle-6][7:0] ||
                    b00_to_10[7:0] !== b_words[core_cycle-6][7:0]) $fatal(1,"Upper tile propagation");
                neighbor_checks = neighbor_checks + 2;
            end
            if (core_cycle >= 10 && core_cycle <= 17) begin
                if (a10_to_11[7:0] !== a_words[core_cycle-10][39:32] ||
                    b01_to_11[7:0] !== b_words[core_cycle-10][39:32]) $fatal(1,"Lower/right propagation");
                neighbor_checks = neighbor_checks + 2;
            end
            if (a_top_valid || a_bottom_valid || b_left_valid || b_right_valid)
                $display("EVENT case=%0d RAM_READ t=%0t core=%0d valid=%b%b%b%b A=%08h/%08h B=%08h/%08h",testcase_id,$time,core_cycle,a_top_valid,a_bottom_valid,b_left_valid,b_right_valid,a_top_read,a_bottom_read,b_left_read,b_right_read);
        end
        if (resetn && c_write_valid) begin
            if ($isunknown({c_write_addr,c_write_data})) $fatal(1,"Unknown write");
            if (c_write_count >= 8) $fatal(1,"Extra C write");
            if (c_write_addr !== 10'(address_mat_c+c_write_count*address_stride_c)) $fatal(1,"Bad C address");
            if (c_write_data !== expected_words[c_write_count])
                $fatal(1,"C write column=%0d got=%016h expected=%016h",c_write_count,c_write_data,expected_words[c_write_count]);
            if (done) $fatal(1,"Done before last committed write");
            $display("EVENT case=%0d C_WRITE t=%0t cycle=%0d core=%0d col=%0d addr=%0d data=%016h",testcase_id,$time,cycle,core_cycle,c_write_count,c_write_addr,c_write_data);
            c_write_count = c_write_count + 1;
            final_write_cycle = cycle;
        end
    end

    task automatic run_case(input integer which, input bit reset_first, input bit strided);
        integer k, row, timeout_count;
        logic [63:0] actual;
        begin
            @(negedge clk);
            testcase_id = which; checked_entries = 0; c_write_count = 0;
            edge_checks_a = 0; edge_checks_b = 0; neighbor_checks = 0;
            load_case(which);
            if (reset_first) begin
                resetn = 0; pe_resetn = 0;
                repeat(3) @(negedge clk);
                if (exception_flags !== 0) $fatal(1,"Reset flags");
            end
            address_mat_a = strided ? 10'd17 : 0;
            address_mat_b = strided ? 10'd43 : 0;
            address_mat_c = strided ? 10'd101 : 0;
            address_stride_a = strided ? 3 : 1;
            address_stride_b = strided ? 2 : 1;
            address_stride_c = strided ? 5 : 1;
            for(k=0;k<8;k=k+1) begin
                load_addr_a = 10'(address_mat_a + k*address_stride_a);
                load_addr_b = 10'(address_mat_b + k*address_stride_b);
                load_a = a_words[k]; load_b = b_words[k]; load_we = 1;
                @(negedge clk);
            end
            load_we = 0;
            for(k=0;k<8;k=k+1) begin
                loaded_a[k] = {dut.matrix_A_bottom.ram[address_mat_a+k*address_stride_a],dut.matrix_A_top.ram[address_mat_a+k*address_stride_a]};
                loaded_b[k] = {dut.matrix_B_right.ram[address_mat_b+k*address_stride_b],dut.matrix_B_left.ram[address_mat_b+k*address_stride_b]};
                if (loaded_a[k] !== a_words[k] || loaded_b[k] !== b_words[k]) $fatal(1,"RAM load word %0d",k);
            end
            resetn = 1; pe_resetn = 1;
            repeat(2) @(negedge clk);
            start = 1;
            @(posedge clk); #1; start_cycle = cycle;
            $display("EVENT case=%0d ACCEPTED_START t=%0t cycle=%0d",which,$time,start_cycle);
            @(negedge clk); start = 0;
            timeout_count = 0;
            while (done !== 1 && timeout_count < 80) begin
                @(negedge clk); timeout_count = timeout_count + 1;
            end
            if (!done) $fatal(1,"Operation timeout");
            if (c_write_count != 8) $fatal(1,"Expected eight writes per C bank");
            if (edge_checks_a != 16 || edge_checks_b != 16 || neighbor_checks != 32)
                $fatal(1,"Missing input/neighbor checks: A=%0d B=%0d neighbor=%0d",edge_checks_a,edge_checks_b,neighbor_checks);
            if (exception_flags !== expected_flags) $fatal(1,"Flags got=%05b expected=%05b",exception_flags,expected_flags);
            $display("EVENT case=%0d DONE t=%0t cycle=%0d start_to_final_write=%0d first_run_through_final_write=%0d",which,$time,cycle,final_write_cycle-start_cycle,final_write_cycle-first_run_cycle+1);
            // Read all actual C words back through the synchronous host port.
            for(k=0;k<8;k=k+1) begin
                read_addr_c = 10'(address_mat_c+k*address_stride_c);
                @(posedge clk); #1; actual = read_c;
                final_c[k] = actual;
                for(row=0;row<8;row=row+1) begin
                    if (actual[8*row +: 8] !== expected_words[k][8*row +: 8]) $fatal(1,"RAM C[%0d][%0d]",row,k);
                    checked_entries = checked_entries + 1;
                end
                $display("CHECK case=%0d C_COLUMN[%0d]=%016h",which,k,actual);
                @(negedge clk);
            end
            repeat(4) @(negedge clk);
            if (!done || busy || c_write_valid || c_write_count != 8 || exception_flags !== expected_flags)
                $fatal(1,"Completion/flags not stable");
            total_checked = total_checked + checked_entries;
            $display("PASS case=%0d checked=%0d flags=%05b",which,checked_entries,exception_flags);
        end
    endtask

    initial begin
        $timeformat(-9,0," ns",12);
        if (!$value$plusargs("CASE=%d",selected_case)) selected_case = 0;
`ifdef FSDB
        if(selected_case == 1) $fsdbDumpfile("build/ones.fsdb");
        else if(selected_case == 2) $fsdbDumpfile("build/varied.fsdb");
        else if(selected_case == 3) $fsdbDumpfile("build/exception.fsdb");
        else $fsdbDumpfile("build/sequence.fsdb");
        $fsdbDumpvars(0,tb_part3);
        $fsdbDumpMDA();
`endif
        if(selected_case == 1) $dumpfile("build/ones.vcd");
        else if(selected_case == 2) $dumpfile("build/varied.vcd");
        else if(selected_case == 3) $dumpfile("build/exception.vcd");
        else $dumpfile("build/sequence.vcd");
        $dumpvars(0,tb_part3);
        if (selected_case) run_case(selected_case,1,selected_case==2);
        else begin
            run_case(1,1,0);
            run_case(2,0,1);
            run_case(3,0,0);
            run_case(1,0,1); // Clean after exception, without external reset.
        end
        $display("PART3 SIMULATION PASS total_checked=%0d",total_checked);
        $finish;
    end
    initial begin #20000; $fatal(1,"Global timeout"); end
endmodule
