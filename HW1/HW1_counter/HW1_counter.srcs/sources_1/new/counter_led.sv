`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2026 09:22:45 PM
// Design Name: 
// Module Name: counter_led
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


module counter_led (
    input  logic       clk,
    input  logic       reset,
    output logic [3:0] led
);

    logic [3:0] counter;

    always_ff @(posedge clk) begin
        if (reset)
            counter <= 4'b0000;
        else
            counter <= counter + 4'd1;
    end

    assign led = counter;

endmodule