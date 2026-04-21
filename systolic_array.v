`timescale 1ns / 1ps

module systolic_array #(
    parameter N          = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                          clk,
    input  wire                          rst,

       input  wire [N*DATA_WIDTH-1 : 0]     a_in,
    input  wire [N*DATA_WIDTH-1 : 0]     b_in,

     output wire [N*N*ACC_WIDTH-1 : 0]    c_out,
    output wire [N*N-1 : 0]              pe_active
);

    wire [DATA_WIDTH-1:0] a_wire [0:N-1][0:N];
    wire [DATA_WIDTH-1:0] b_wire [0:N]  [0:N-1];

    genvar i, j;

    generate
        for (i = 0; i < N; i = i + 1) begin : conn_a_in
            assign a_wire[i][0] = a_in[(i+1)*DATA_WIDTH-1 : i*DATA_WIDTH];
        end
    endgenerate

    generate
        for (j = 0; j < N; j = j + 1) begin : conn_b_in
            assign b_wire[0][j] = b_in[(j+1)*DATA_WIDTH-1 : j*DATA_WIDTH];
        end
    endgenerate

    generate
        for (i = 0; i < N; i = i + 1) begin : row
            for (j = 0; j < N; j = j + 1) begin : col

                pe #(
                    .DATA_WIDTH (DATA_WIDTH),
                    .ACC_WIDTH  (ACC_WIDTH)
                ) u_pe (
                    .clk    (clk),
                    .rst    (rst),
                    .in_a   (a_wire[i][j]),          // from left
                    .in_b   (b_wire[i][j]),          // from top
                    .out_a  (a_wire[i][j+1]),        // to right
                    .out_b  (b_wire[i+1][j]),        // to bottom
                    .acc    (c_out[(i*N+j+1)*ACC_WIDTH-1 : (i*N+j)*ACC_WIDTH]),
                    .active (pe_active[i*N+j])
                );

            end
        end
    endgenerate

endmodule

