`timescale 1ns/1ps
module tb_part4;
    logic PCLK=0;
    always #10 PCLK=~PCLK;
    logic PRESETn=0, PSEL=0, PENABLE=0, PWRITE=0;
    logic [9:0] PADDR=0;
    logic [15:0] PWDATA=0;
    wire [15:0] PRDATA;
    wire PREADY;
    logic load_we=0;
    logic [9:0] load_addr_a=0, load_addr_b=0, read_addr_c=0;
    logic [63:0] load_a=0, load_b=0;
    wire [63:0] read_a, read_b, read_c;
    logic [63:0] a_words[0:7],b_words[0:7],expected_words[0:7];
    logic [63:0] loaded_a[0:7],loaded_b[0:7],final_c[0:7];
    logic [4:0] expected_flags;
    integer testcase_id=0,checked_entries=0,total_checked=0,c_write_count=0;
    integer selected_case=0,apb_write_count=0,apb_read_count=0,protocol_checks=0;
    integer accepted_jobs=0;
    logic [9:0] last_apb_read_addr=0;
    logic [15:0] last_apb_read_data=0;
    integer ba,bb,bc,sa,sb,sc;
    time final_write_time;
    bit monitor_job=0;
    matmul_apb_8x8 dut(.*);
    wire start_pulse=dut.start_pulse,engine_busy=dut.engine_busy,core_run=dut.core_run;
    wire [1:0] engine_state=dut.ctrl.state;
    wire [7:0] core_cycle=dut.u_matmul_8x8.run_cycle;
    wire [4:0] core_flags=dut.core_flags,flags_reg=dut.flags_reg;
    wire done_reg=dut.done_reg,c_write_valid=dut.c_write_valid;
    wire [9:0] c_write_addr=dut.c_write_addr;
    wire [63:0] c_write_data={dut.c_bottom_data,dut.c_top_data};
    wire [9:0] cfg_base_a=dut.base_a,cfg_base_b=dut.base_b,cfg_base_c=dut.base_c;
    wire [7:0] cfg_stride_a=dut.stride_a,cfg_stride_b=dut.stride_b,cfg_stride_c=dut.stride_c;
    `include "cases.svh"
    `include "apb_tasks.svh"

    always @(posedge PCLK) begin
        if(PRESETn && c_write_valid && monitor_job) begin
            if(c_write_count>=8) $fatal(1,"Extra C write");
            if(c_write_addr !== 10'(bc+c_write_count*sc)) $fatal(1,"C address");
            if(c_write_data !== expected_words[c_write_count]) $fatal(1,"C data column %0d",c_write_count);
            if(done_reg) $fatal(1,"Premature done");
            $display("EVENT C_WRITE t=%0t column=%0d addr=%0d data=%016h",$time,c_write_count,c_write_addr,c_write_data);
            c_write_count=c_write_count+1; final_write_time=$time;
        end
        #1;
        if(PRESETn && start_pulse) begin
            accepted_jobs=accepted_jobs+1;
            $display("EVENT START t=%0t",$time);
            if(done_reg || flags_reg!==0) $fatal(1,"New start did not clear status");
        end
        if(PRESETn && monitor_job && done_reg) begin
            if(c_write_count!=8 || $time<=final_write_time) $fatal(1,"Done before writes committed");
        end
    end

    task automatic reset_bus;
        begin
            @(negedge PCLK); PRESETn=0; PSEL=0; PENABLE=0; PWRITE=0;
            repeat(3) @(negedge PCLK);
            PRESETn=1;
            expect_read('h000,0); expect_read('h002,0); expect_read('h004,0); expect_read('h006,0);
            expect_read('h008,1); expect_read('h00a,1); expect_read('h00c,1);
            expect_read('h00e,0); expect_read('h010,0);
        end
    endtask

    task automatic bus_checks;
        logic [15:0] unused;
        begin
            // SETUP alone cannot mutate a CSR, and PENABLE without PSEL cannot.
            @(negedge PCLK); PSEL=1; PENABLE=0; PWRITE=1; PADDR=2; PWDATA=99;
            repeat(3) @(negedge PCLK);
            if(cfg_base_a!==0) $fatal(1,"SETUP wrote CSR");
            PSEL=0; PENABLE=1;
            repeat(2) @(negedge PCLK);
            if(cfg_base_a!==0) $fatal(1,"Unselected write");
            PENABLE=0; PWRITE=0; protocol_checks=protocol_checks+2;
            write(0,0); expect_read('he,0);
            write('he,'hffff); write('h10,'hffff);
            expect_read('he,0); expect_read('h10,0);
            write(3,'hffff); write('h202,'hffff);
            expect_read(3,0); expect_read('h202,0); expect_read(2,0);
            write(2,'hffff); expect_read(2,'h03ff);
            write(8,'hffff); expect_read(8,'h00ff);
            // Genuine back-to-back transfers: PSEL stays high, exactly one
            // SETUP cycle between completed ACCESS phases.
            @(negedge PCLK); PSEL=1; PENABLE=0; PWRITE=1; PADDR=2; PWDATA=17;
            @(negedge PCLK); PENABLE=1;
            @(posedge PCLK); if(!PREADY) $fatal(1,"Unexpected wait");
            @(negedge PCLK); PENABLE=0; PADDR=4; PWDATA=43;
            @(negedge PCLK); PENABLE=1;
            @(posedge PCLK); if(!PREADY) $fatal(1,"Unexpected wait");
            @(negedge PCLK); PENABLE=0; PWRITE=0; PADDR=2;
            @(negedge PCLK); PENABLE=1;
            @(posedge PCLK); if(PRDATA!==17) $fatal(1,"Back-to-back read A");
            @(negedge PCLK); PENABLE=0; PADDR=4;
            @(negedge PCLK); PENABLE=1;
            @(posedge PCLK); if(PRDATA!==43) $fatal(1,"Back-to-back read B");
            @(negedge PCLK); PSEL=0; PENABLE=0;
            protocol_checks=protocol_checks+2;
            $display("APB PROTOCOL CHECKS PASS checks=%0d",protocol_checks);
        end
    endtask

    task automatic run_case(input integer which,input bit strided);
        integer k,r,polls,jobs_before;
        logic [15:0] status,flags;
        begin
            @(negedge PCLK);
            testcase_id=which; checked_entries=0; c_write_count=0; monitor_job=0;
            load_case(which);
            ba=strided?17:0; bb=strided?43:0; bc=strided?101:0;
            sa=strided?3:1; sb=strided?2:1; sc=strided?5:1;
            for(k=0;k<8;k=k+1) begin
                load_addr_a=10'(ba+k*sa); load_addr_b=10'(bb+k*sb);
                load_a=a_words[k]; load_b=b_words[k]; load_we=1;
                @(negedge PCLK);
            end
            load_we=0;
            for(k=0;k<8;k=k+1) begin
                load_addr_a=10'(ba+k*sa); load_addr_b=10'(bb+k*sb);
                @(posedge PCLK); #1;
                loaded_a[k]=read_a; loaded_b[k]=read_b;
                if(read_a!==a_words[k] || read_b!==b_words[k]) $fatal(1,"RAM load %0d",k);
                @(negedge PCLK);
            end
            write(2,16'(ba)); write(4,16'(bb)); write(6,16'(bc));
            write(8,16'(sa)); write(10,16'(sb)); write(12,16'(sc));
            expect_read(2,16'(ba)); expect_read(4,16'(bb)); expect_read(6,16'(bc));
            expect_read(8,16'(sa)); expect_read(10,16'(sb)); expect_read(12,16'(sc));
            jobs_before=accepted_jobs;
            write(0,1); monitor_job=1;
            // Attempt to redirect, restart, and overwrite loaded RAM while busy.
            load_addr_a=10'(ba); load_addr_b=10'(bb); load_a='1; load_b='1; load_we=1;
            write(2,900); write(4,901); write(6,902);
            write(8,7); write(10,7); write(12,7); write(0,1); write(0,0);
            load_we=0;
            if(cfg_base_a!==10'(ba) || cfg_base_b!==10'(bb) || cfg_base_c!==10'(bc) ||
               cfg_stride_a!==8'(sa) || cfg_stride_b!==8'(sb) || cfg_stride_c!==8'(sc))
                $fatal(1,"Busy configuration changed");
            if(accepted_jobs!=jobs_before+1) $fatal(1,"Busy start was accepted");
            polls=0; status=0;
            while(!status[15] && polls<40) begin read('he,status); polls=polls+1; end
            if(status!==16'h8000) $fatal(1,"Done poll timeout/bad status");
            read('h10,flags);
            if(flags!=={11'b0,expected_flags}) $fatal(1,"Flags got=%04h expected=%02h",flags,expected_flags);
            $display("EVENT DONE_READ t=%0t flags=%04h",$time,flags);
            if(c_write_count!=8) $fatal(1,"Write count");
            expect_read('he,'h8000); expect_read('h10,{11'b0,expected_flags});
            for(k=0;k<8;k=k+1) begin
                read_addr_c=10'(bc+k*sc);
                @(posedge PCLK); #1; final_c[k]=read_c;
                for(r=0;r<8;r=r+1) begin
                    if(read_c[8*r+:8]!==expected_words[k][8*r+:8]) $fatal(1,"RAM C[%0d][%0d]",r,k);
                    checked_entries=checked_entries+1;
                end
                $display("CHECK case=%0d C_COLUMN[%0d]=%016h",which,k,read_c);
                @(negedge PCLK);
            end
            load_addr_a=10'(ba); load_addr_b=10'(bb);
            @(posedge PCLK); #1;
            if(read_a!==a_words[0] || read_b!==b_words[0]) $fatal(1,"Host write while busy");
            total_checked=total_checked+checked_entries; monitor_job=0;
            $display("PASS case=%0d checked=%0d flags=%05b",which,checked_entries,flags[4:0]);
        end
    endtask

    initial begin
        $timeformat(-9,0," ns",12);
        if(!$value$plusargs("CASE=%d",selected_case)) selected_case=0;
`ifdef FSDB
        if(selected_case==1) $fsdbDumpfile("build/ones.fsdb");
        else if(selected_case==2) $fsdbDumpfile("build/varied.fsdb");
        else if(selected_case==3) $fsdbDumpfile("build/exception.fsdb");
        else $fsdbDumpfile("build/sequence.fsdb");
        $fsdbDumpvars(0,tb_part4); $fsdbDumpMDA();
`else
        if(selected_case==1) $dumpfile("build/ones.vcd");
        else if(selected_case==2) $dumpfile("build/varied.vcd");
        else if(selected_case==3) $dumpfile("build/exception.vcd");
        else $dumpfile("build/sequence.vcd");
        $dumpvars(0,tb_part4);
`endif
        reset_bus();
        if(selected_case) run_case(selected_case,selected_case!=1);
        else begin
            bus_checks();
            run_case(1,0); run_case(2,1); run_case(3,1); run_case(1,1);
            // Abort an active operation, then verify reset defaults and a full
            // clean run. No direct force of internal state or done is used.
            write(0,1); repeat(5) @(negedge PCLK);
            if(!engine_busy) $fatal(1,"Reset test was not active");
            reset_bus(); repeat(40) @(negedge PCLK);
            if(c_write_valid || done_reg || engine_busy) $fatal(1,"Aborted job completed");
            run_case(1,0);
        end
        $display("PART4 SIMULATION PASS total_checked=%0d protocol_checks=%0d",total_checked,protocol_checks);
        $finish;
    end
    initial begin #100000; $fatal(1,"Global timeout"); end
endmodule
