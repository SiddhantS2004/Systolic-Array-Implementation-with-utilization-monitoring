`timescale 1ns / 1ps
module tb_top;

    parameter N  = 4;
    parameter DW = 8;
    parameter AW = 32;

    reg                       clk, rst;
    reg  [N*DW-1:0]           a_flat, b_flat;
    wire [N*N*AW-1:0]         c_out;
    wire [7:0]                active_count, peak_utilization, utilization_percent;
    wire [31:0]               cumulative_active_cycles;

    top #(.N(N), .DATA_WIDTH(DW), .ACC_WIDTH(AW)) dut (
        .clk(clk), .rst(rst),
        .a_flat(a_flat), .b_flat(b_flat),
        .c_out(c_out),
        .active_count(active_count),
        .peak_utilization(peak_utilization),
        .cumulative_active_cycles(cumulative_active_cycles),
        .utilization_percent(utilization_percent)
    );

    initial clk = 0;
    always  #5 clk = ~clk;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

    function [AW-1:0] getC;
        input integer row, col;
        getC = c_out[((row*N+col)+1)*AW-1 -: AW];
    endfunction

    reg [AW-1:0] expected [0:N-1][0:N-1];
    integer i, j, errors;

    initial begin
        expected[0][0]=16; expected[0][1]=14; expected[0][2]=16; expected[0][3]=14;
        expected[1][0]=40; expected[1][1]=38; expected[1][2]=40; expected[1][3]=38;
        expected[2][0]=64; expected[2][1]=62; expected[2][2]=64; expected[2][3]=62;
        expected[3][0]=88; expected[3][1]=86; expected[3][2]=88; expected[3][3]=86;

        errors = 0;
        $display("==============================================");
        $display(" SYSTOLIC ARRAY - FULL SYSTEM TEST");
        $display(" Computing: A x B (dense matrix)");
        $display("==============================================");

        rst=1; a_flat=0; b_flat=0;
        repeat(3) @(posedge clk);
        #1; rst=0;

        $display("\nReal-time PE Utilization (cycle by cycle):");
        $display("Cycle | Active PEs | Utilization%%");
        $display("------|------------|-------------");

        #4;
        a_flat = {8'd13, 8'd9,  8'd5,  8'd1};
        b_flat = {8'd2,  8'd1,  8'd2,  8'd1};
        @(posedge clk);
        #1; $display("  %3d  |   %2d / 16  |    %3d%%", $time/10, active_count, (active_count*100)/16);

        a_flat = {8'd14, 8'd10, 8'd6,  8'd2};
        b_flat = {8'd1,  8'd2,  8'd1,  8'd2};
        @(posedge clk);
        #1; $display("  %3d  |   %2d / 16  |    %3d%%", $time/10, active_count, (active_count*100)/16);

        a_flat = {8'd15, 8'd11, 8'd7,  8'd3};
        b_flat = {8'd2,  8'd1,  8'd2,  8'd1};
        @(posedge clk);
        #1; $display("  %3d  |   %2d / 16  |    %3d%%", $time/10, active_count, (active_count*100)/16);

        a_flat = {8'd16, 8'd12, 8'd8,  8'd4};
        b_flat = {8'd1,  8'd2,  8'd1,  8'd2};
        @(posedge clk);
        #1; $display("  %3d  |   %2d / 16  |    %3d%%", $time/10, active_count, (active_count*100)/16);

        repeat(10) begin
            a_flat = 0;
            b_flat = 0;
            @(posedge clk);
            #1;
            $display("  %3d  |   %2d / 16  |    %3d%%",
                      $time/10, active_count, (active_count*100)/16);
        end

        repeat(5) @(posedge clk);

        $display("\nComputed C = A x B:");
        $display("     col0  col1  col2  col3");
        for (i=0; i<N; i=i+1) begin
            $write("row%0d: ", i);
            for (j=0; j<N; j=j+1)
                $write("%4d  ", getC(i,j));
            $write("\n");
        end

        $display("\nExpected C:");
        $display("     col0  col1  col2  col3");
        for (i=0; i<N; i=i+1) begin
            $write("row%0d: ", i);
            for (j=0; j<N; j=j+1)
                $write("%4d  ", expected[i][j]);
            $write("\n");
        end

        $display("\nVerification:");
        for (i=0; i<N; i=i+1) begin
            for (j=0; j<N; j=j+1) begin
                if (getC(i,j) !== expected[i][j]) begin
                    $display("  FAIL C[%0d][%0d]: got %0d expected %0d",
                              i, j, getC(i,j), expected[i][j]);
                    errors = errors + 1;
                end else
                    $display("  PASS C[%0d][%0d] = %0d", i, j, getC(i,j));
            end
        end

        $display("\nUtilization Monitor Report:");
        $display("  Active PEs now      : %0d / %0d", active_count, N*N);
        $display("  Peak active PEs     : %0d / %0d", peak_utilization, N*N);
        $display("  Total PE-work-cycles: %0d", cumulative_active_cycles);
        $display("  Utilization %%       : %0d%%", utilization_percent);

        $display("\n==============================================");
        if (errors == 0)
            $display(" ALL %0d ELEMENTS CORRECT - ARRAY WORKS!", N*N);
        else
            $display(" %0d ELEMENTS WRONG - CHECK WIRING", errors);
        $display("==============================================\n");

        $finish;
    end

endmodule
