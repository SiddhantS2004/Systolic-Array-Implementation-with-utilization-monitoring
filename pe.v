`timescale 1ns / 1ps
module pe #(
    parameter DATA_WIDTH = 8,   
    parameter ACC_WIDTH  = 32   
)(
    input  wire                  clk,    
    input  wire                  rst,    

    input  wire [DATA_WIDTH-1:0] in_a,   
    input  wire [DATA_WIDTH-1:0] in_b,   

    output reg  [DATA_WIDTH-1:0] out_a,  
    output reg  [DATA_WIDTH-1:0] out_b,  

    output reg  [ACC_WIDTH-1:0]  acc,    
    output wire                  active  
);

    
    assign active = (in_a != {DATA_WIDTH{1'b0}}) &&
                    (in_b != {DATA_WIDTH{1'b0}});

    always @(posedge clk) begin
        if (rst) begin
           
            acc   <= {ACC_WIDTH{1'b0}};
            out_a <= {DATA_WIDTH{1'b0}};
            out_b <= {DATA_WIDTH{1'b0}};
        end else begin
           
            acc   <= acc + ({{(ACC_WIDTH-DATA_WIDTH){1'b0}}, in_a} *
                            {{(ACC_WIDTH-DATA_WIDTH){1'b0}}, in_b});
           
            out_a <= in_a;
            out_b <= in_b;
        end
    end

endmodule

