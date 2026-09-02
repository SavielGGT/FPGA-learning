`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2026 06:30:47 PM
// Design Name: 
// Module Name: decoder
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


module decoder #(
    parameter int WIDTH = 4,
    parameter int IN_WIDTH = $clog2(WIDTH)
)(
    input  logic [IN_WIDTH-1:0] code,
    output logic [WIDTH-1:0]    out
);

    always_comb begin
        out = '0;

        if (code < WIDTH)
            out[code] = 1'b1;
    end

endmodule
