`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 07:25:55 PM
// Design Name: 
// Module Name: tb_debounce_digit
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

module tb_debounce_digit;

    logic       clk;
    logic       rst;
    logic [3:0] digit_in_raw;
    logic [3:0] digit_in_clean;

    debounce_digit #(
        .CLK_FREQ_HZ (100_000_000),
        .DEBOUNCE_MS (1)
    ) dut (
        .clk            (clk),
        .rst            (rst),
        .digit_in_raw   (digit_in_raw),
        .digit_in_clean (digit_in_clean)
    );

    always #5 clk = ~clk;

    initial begin
        clk          = 1'b0;
        rst          = 1'b1;
        digit_in_raw = 4'd0;

        #20;
        rst = 1'b0;

        // Simulated button bounce
        #100;
        digit_in_raw = 4'd5;
        #100;
        digit_in_raw = 4'd0;
        #100;
        digit_in_raw = 4'd5;
        #100;
        digit_in_raw = 4'd0;
        #100;
        digit_in_raw = 4'd5;

        // Hold stable long enough
        #1_100_000;

        if (digit_in_clean == 4'd5)
            $display("PASS: debounce accepted digit 5");
        else
            $display("FAIL: debounce output = %0d", digit_in_clean);

        $finish;
    end

endmodule