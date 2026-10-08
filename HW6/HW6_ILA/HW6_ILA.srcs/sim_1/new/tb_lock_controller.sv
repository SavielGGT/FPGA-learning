`timescale 1ns / 1ps

module tb_lock_controller;

    logic clk = 0;
    logic rst = 0;
    logic [3:0] digit_in = 0;
    logic enter_pulse = 0;
    logic unlocked_led;

    // 125 MHz -> period 8 ns
    always #4 clk = ~clk;

    lock_controller dut (
        .clk          (clk),
        .rst          (rst),
        .digit_in     (digit_in),
        .enter_pulse  (enter_pulse),
        .unlocked_led (unlocked_led)
    );

    task enter_digit(input logic [3:0] digit);
    begin
        digit_in = digit;

        repeat (2) @(negedge clk);

        enter_pulse = 1;
        @(negedge clk);
        enter_pulse = 0;

        repeat (3) @(negedge clk);
    end
    endtask

    initial begin
        // Reset
        rst = 1;
        #20;
        rst = 0;

        repeat (3) @(negedge clk);

        // Correct code: 5 -> 3 -> 7
        enter_digit(4'd5);
        enter_digit(4'd3);
        enter_digit(4'd7);

        repeat (10) @(negedge clk);

        $finish;
    end

endmodule