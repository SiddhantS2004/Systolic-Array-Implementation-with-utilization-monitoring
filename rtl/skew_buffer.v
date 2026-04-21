`timescale 1ns / 1ps
module skew_buffer #(
    parameter N          = 4,   
    parameter DATA_WIDTH = 8     
)(
    input  wire                       clk,
    input  wire                       rst,
    input  wire [N*DATA_WIDTH-1 : 0]  data_in,   
    output wire [N*DATA_WIDTH-1 : 0]  data_out   // each lane delayed by index
);

    reg [DATA_WIDTH-1:0] delay_regs [0:N-1][0:N-2];

    genvar i, d;

 
    assign data_out[DATA_WIDTH-1 : 0] = data_in[DATA_WIDTH-1 : 0];

    generate
        for (i = 1; i < N; i = i + 1) begin : gen_lane

            always @(posedge clk) begin
                if (rst)
                    delay_regs[i][0] <= {DATA_WIDTH{1'b0}};
                else
                    delay_regs[i][0] <= data_in[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];
            end

            for (d = 1; d < i; d = d + 1) begin : gen_stage
                always @(posedge clk) begin
                    if (rst)
                        delay_regs[i][d] <= {DATA_WIDTH{1'b0}};
                    else
                        delay_regs[i][d] <= delay_regs[i][d-1];
                end
            end

            assign data_out[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH] =
                   delay_regs[i][i-1];

        end
    endgenerate

endmodule

