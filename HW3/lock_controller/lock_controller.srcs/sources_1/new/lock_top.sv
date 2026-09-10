`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 08:09:06 PM
// Design Name: 
// Module Name: lock_top
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


module lock_top (
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] digit_in,
    output logic       unlocked_led
);

    logic [3:0] digit_clean;

    debounce_digit debounce_inst (
        .clk            (clk),
        .rst            (rst),
        .digit_in_raw   (digit_in),
        .digit_in_clean (digit_clean)
    );

    lock_controller lock_inst (
        .clk          (clk),
        .rst          (rst),
        .digit_in     (digit_clean),
        .unlocked_led (unlocked_led)
    );

endmodule