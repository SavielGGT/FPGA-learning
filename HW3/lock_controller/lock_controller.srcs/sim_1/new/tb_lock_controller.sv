`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 07:17:35 PM
// Design Name: 
// Module Name: tb_lock_controller
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


module tb_lock_controller;

    logic       clk;
    logic       rst;
    logic [3:0] digit_in;
    logic       unlocked_led;

    localparam logic [1:0] LOCKED   = 2'b00;
    localparam logic [1:0] WAIT_D2  = 2'b01;
    localparam logic [1:0] WAIT_D3  = 2'b10;
    localparam logic [1:0] UNLOCKED = 2'b11;

    lock_controller dut (
        .clk          (clk),
        .rst          (rst),
        .digit_in     (digit_in),
        .unlocked_led (unlocked_led)
    );

    always #5 clk = ~clk;

    task automatic apply_digit(
        input logic [3:0] digit
    );
        begin
            digit_in = digit;
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk      = 1'b0;
        rst      = 1'b0;
        digit_in = 4'd0;

        // Reset
        #2;
        rst = 1'b1;
        #2;
        rst = 1'b0;

        // Correct sequence

        apply_digit(4'd5);

        if (dut.state == WAIT_D2)
            $display("PASS: LOCKED -> WAIT_D2");
        else
            $display("FAIL: LOCKED -> WAIT_D2");

        apply_digit(4'd3);

        if (dut.state == WAIT_D3)
            $display("PASS: WAIT_D2 -> WAIT_D3");
        else
            $display("FAIL: WAIT_D2 -> WAIT_D3");

        apply_digit(4'd7);

        if (dut.state == UNLOCKED)
            $display("PASS: WAIT_D3 -> UNLOCKED");
        else
            $display("FAIL: WAIT_D3 -> UNLOCKED");

        if (unlocked_led == 1'b1)
            $display("PASS: unlocked_led = 1");
        else
            $display("FAIL: unlocked_led");

        // Reset
        rst = 1'b1;
        #2;
        rst = 1'b0;

        // Wrong digit scenario

        apply_digit(4'd5);

        if (dut.state == WAIT_D2)
            $display("PASS: first digit accepted");
        else
            $display("FAIL: first digit");

        apply_digit(4'd9);

        if (dut.state == LOCKED)
            $display("PASS: wrong digit -> LOCKED");
        else
            $display("FAIL: wrong digit");

        $display("TEST FINISHED");

        #10;
        $finish;
    end

endmodule