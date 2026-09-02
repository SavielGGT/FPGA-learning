`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2026 07:18:14 PM
// Design Name: 
// Module Name: tb_counter
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



module tb_counter;

    reg        clk;
    reg        rst;
    reg        load;
    reg  [3:0] data_in;
    reg        en;
    reg        up_down;

    wire [3:0] count;

    counter dut (
        .clk     (clk),
        .rst     (rst),
        .load    (load),
        .data_in (data_in),
        .en      (en),
        .up_down (up_down),
        .count   (count)
    );

    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;

    task automatic check_count(
        input [3:0] expected,
        input string name
    );
    begin
        if (count === expected)
            $display("PASS: %s, count = %0d", name, count);
        else
            $display(
                "FAIL: %s, expected %0d, got %0d",
                name, expected, count
            );
    end
    endtask

    initial begin

        rst     = 1'b0;
        load    = 1'b0;
        data_in = 4'd0;
        en      = 1'b0;
        up_down = 1'b0;

        #2;

        rst = 1'b1;

        @(posedge clk);
        #1;

        rst = 1'b0;

        load    = 1'b1;
        data_in = 4'd10;

        @(posedge clk);
        #1;

        load = 1'b0;

        check_count(4'd10, "LOAD");

        en      = 1'b1;
        up_down = 1'b1;

        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;

        check_count(4'd13, "COUNT UP to 13");

        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;

        check_count(4'd0, "COUNT UP overflow");

        en = 1'b0;

        @(posedge clk); #1;
        @(posedge clk); #1;

        check_count(4'd0, "HOLD");

        en      = 1'b1;
        up_down = 1'b0;

        @(posedge clk);
        #1;

        check_count(4'd15, "COUNT DOWN overflow");

        load    = 1'b1;
        data_in = 4'd5;
        en      = 1'b1;
        up_down = 1'b1;

        @(posedge clk);
        #1;

        load = 1'b0;

        check_count(4'd5, "LOAD priority");

        en = 1'b0;

        #10;
        $finish;

    end

endmodule
