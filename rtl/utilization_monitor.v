`timescale 1ns / 1ps
module utilization_monitor #(
    parameter N = 4
)(
    input  wire              clk,
    input  wire              rst,
    input  wire [N*N-1 : 0]  pe_active_flags,
    output reg  [7:0]        active_count,
    output reg  [7:0]        peak_utilization,
    output reg  [31:0]       cumulative_active_cycles,
    output reg  [7:0]        utilization_percent
);

    integer k;
    reg [7:0]  cnt;
    reg [31:0] total_cycles;  // counts every clock cycle

    always @(posedge clk) begin
        if (rst) begin
            active_count             <= 8'd0;
            peak_utilization         <= 8'd0;
            cumulative_active_cycles <= 32'd0;
            utilization_percent      <= 8'd0;
            total_cycles             <= 32'd0;
        end else begin

            // Count active PEs this cycle
            cnt = 8'd0;
            for (k = 0; k < N*N; k = k + 1) begin
                if (pe_active_flags[k] == 1'b1)
                    cnt = cnt + 8'd1;
            end
            active_count <= cnt;

            // Update peak
            if (cnt > peak_utilization)
                peak_utilization <= cnt;

            // Accumulate total work cycles
            cumulative_active_cycles <= cumulative_active_cycles + {24'd0, cnt};

            // Count every clock cycle
            total_cycles <= total_cycles + 1;

            // Average utilization % over entire run
            // = (cumulative * 100) / (total_cycles * N*N)
            if (total_cycles > 0)
                utilization_percent <= (cumulative_active_cycles * 100) / 
                                       (total_cycles * (N * N));

        end
    end

endmodule
