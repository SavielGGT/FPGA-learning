`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2026 08:35:32 PM
// Design Name: 
// Module Name: latch_mux
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


module latch_mux (
    input  logic a,
    input  logic b,
    input  logic sel,
    output logic y
);

    always_comb begin
    case (sel)
        1'b0: y = a;
        default: y = b;
    endcase
end

endmodule
