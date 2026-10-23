// Adapted from baseline/example_tb.v: negedge SETUP/ACCESS drive retained;
// data widened to 16 bits, bounded PREADY wait, read sampled BEFORE teardown.
task automatic transfer(input bit wr, input logic [9:0] addr,
                        input logic [15:0] value, output logic [15:0] result,
                        input bit keep_selected);
    integer waits;
    begin
        @(negedge PCLK);
        PSEL=1; PENABLE=0; PWRITE=wr; PADDR=addr; PWDATA=value;
        @(negedge PCLK); PENABLE=1;
        waits=0;
        @(posedge PCLK);
        while (PREADY !== 1'b1 && waits<16) begin
            waits=waits+1; @(posedge PCLK);
        end
        if(PREADY !== 1'b1) $fatal(1,"APB timeout");
        result=PRDATA;
        if(wr) apb_write_count=apb_write_count+1;
        else begin
            apb_read_count=apb_read_count+1;
            last_apb_read_addr=addr; last_apb_read_data=result;
        end
        $display("APB %s t=%0t addr=%03h data=%04h",wr?"WRITE":"READ ",$time,addr,wr?value:result);
        @(negedge PCLK);
        PENABLE=0; PSEL=keep_selected; PWRITE=0; PADDR=0; PWDATA=0;
    end
endtask
task automatic write(input logic [9:0] addr, input logic [15:0] value);
    logic [15:0] unused;
    transfer(1,addr,value,unused,0);
endtask
task automatic read(input logic [9:0] addr, output logic [15:0] value);
    transfer(0,addr,0,value,0);
endtask
task automatic expect_read(input logic [9:0] addr, input logic [15:0] expected);
    logic [15:0] actual;
    begin
        read(addr,actual);
        if(actual !== expected) $fatal(1,"CSR %03h got=%04h expected=%04h",addr,actual,expected);
        protocol_checks=protocol_checks+1;
    end
endtask
