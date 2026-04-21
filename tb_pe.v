`timescale 1ns / 1ps
module tb_pe;

    parameter DW = 8;
    parameter AW = 32;

    reg            clk, rst;
    reg  [DW-1:0]  in_a, in_b;
    wire [DW-1:0]  out_a, out_b;
    wire [AW-1:0]  acc;
    wire           active;

    pe #(.DATA_WIDTH(DW), .ACC_WIDTH(AW)) dut (
        .clk(clk), .rst(rst),
        .in_a(in_a), .in_b(in_b),
        .out_a(out_a), .out_b(out_b),
        .acc(acc), .active(active)
    );

    initial clk = 0;
    always  #5 clk = ~clk;

    initial begin
        $dumpfile("tb_pe.vcd");
        $dumpvars(0, tb_pe);
    end

    integer fail = 0;

    task check;
        input [AW-1:0] got;
        input [AW-1:0] expected;
        input [63:0]   test_num;
        begin
            if (got !== expected) begin
                $display("FAIL test%0d: got=%0d expected=%0d", test_num, got, expected);
                fail = fail + 1;
            end else
                $display("PASS test%0d: acc=%0d", test_num, got);
        end
    endtask

    initial begin
     
        rst=1; in_a=0; in_b=0;
        @(posedge clk); #1;
        check(acc, 0, 1);   // acc must be 0 after reset

  
        rst=0; in_a=3; in_b=4;
        @(posedge clk); #1;
        check(acc, 12, 2);

        in_a=5; in_b=6;
        @(posedge clk); #1;
        check(acc, 42, 3);

        @(posedge clk); #1;
        if (out_a !== 5)
            $display("FAIL test4: out_a=%0d expected 5", out_a);
        else
            $display("PASS test4: out_a correctly passes in_a");

        in_a=7; in_b=0;
        #1;   // combinational, no clock needed
        if (active !== 0)
            $display("FAIL test5: active should be 0");
        else
            $display("PASS test5: active=0 when in_b=0");

        in_a=7; in_b=3;
        #1;
        if (active !== 1)
            $display("FAIL test6: active should be 1");
        else
            $display("PASS test6: active=1 when both nonzero");

        if (fail == 0)
            $display("\n>>> ALL PE TESTS PASSED <<<");
        else
            $display("\n>>> %0d TEST(S) FAILED <<<", fail);

        $finish;
    end

endmodule

