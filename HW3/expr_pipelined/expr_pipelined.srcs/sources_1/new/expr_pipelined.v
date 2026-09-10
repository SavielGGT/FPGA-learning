`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 09:09:50 PM
// Design Name: 
// Module Name: expr_pipelined
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module expr_pipelined (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    input  wire [7:0]  c,
    input  wire [7:0]  d,
    output reg  [26:0] result
);

    reg [7:0] a_reg;
    reg [7:0] b_reg;
    reg [7:0] c_reg;
    reg [7:0] d_reg;

    wire [8:0]  sum_ab;
    wire [16:0] mult_c;
    wire [17:0] middle;
    wire [8:0]  sum_ad;

    reg [17:0] middle_pipe;
    reg [8:0]  sum_ad_pipe;

    assign sum_ab = a_reg + b_reg;
    assign mult_c = sum_ab * c_reg;
    assign middle = mult_c + d_reg;
    assign sum_ad = a_reg + d_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_reg <= 8'd0;
            b_reg <= 8'd0;
            c_reg <= 8'd0;
            d_reg <= 8'd0;
        end
        else begin
            a_reg <= a;
            b_reg <= b;
            c_reg <= c;
            d_reg <= d;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            middle_pipe <= 18'd0;
            sum_ad_pipe <= 9'd0;
        end
        else begin
            middle_pipe <= middle;
            sum_ad_pipe <= sum_ad;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= 27'd0;
        else
            result <= middle_pipe * sum_ad_pipe;
    end

endmodule
