`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2026 07:52:38 PM
// Design Name: 
// Module Name: decoder_top
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


module decoder_top (
    input  logic [1:0] code4,
    input  logic [2:0] code8,

    output logic [3:0] out4,
    output logic [7:0] out8
);

    decoder #(
        .WIDTH(4)
    ) decoder_4 (
        .code(code4),
        .out(out4)
    );

    decoder #(
        .WIDTH(8)
    ) decoder_8 (
        .code(code8),
        .out(out8)
    );

endmodule
