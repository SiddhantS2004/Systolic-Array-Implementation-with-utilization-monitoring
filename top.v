`timescale 1ns / 1ps
module top #(
    parameter N          = 4,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire [N*DATA_WIDTH-1 : 0]    a_flat,
    input  wire [N*DATA_WIDTH-1 : 0]    b_flat,

    output wire [N*N*ACC_WIDTH-1 : 0]   c_out,

    output wire [7:0]                   active_count,
    output wire [7:0]                   peak_utilization,
    output wire [31:0]                  cumulative_active_cycles,
    output wire [7:0]                   utilization_percent
);


    wire [N*DATA_WIDTH-1:0] a_skewed;
    wire [N*DATA_WIDTH-1:0] b_skewed;
    wire [N*N-1:0]          pe_active;

       skew_buffer #(.N(N), .DATA_WIDTH(DATA_WIDTH)) u_skew_a (
        .clk      (clk),
        .rst      (rst),
        .data_in  (a_flat),
        .data_out (a_skewed)
    );


    skew_buffer #(.N(N), .DATA_WIDTH(DATA_WIDTH)) u_skew_b (
        .clk      (clk),
        .rst      (rst),
        .data_in  (b_flat),
        .data_out (b_skewed)
    );

   
    systolic_array #(.N(N), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) u_sa (
        .clk       (clk),
        .rst       (rst),
        .a_in      (a_skewed),
        .b_in      (b_skewed),
        .c_out     (c_out),
        .pe_active (pe_active)
    );

    utilization_monitor #(.N(N)) u_util (
        .clk                      (clk),
        .rst                      (rst),
        .pe_active_flags          (pe_active),
        .active_count             (active_count),
        .peak_utilization         (peak_utilization),
        .cumulative_active_cycles (cumulative_active_cycles),
        .utilization_percent      (utilization_percent)
    );

endmodule

