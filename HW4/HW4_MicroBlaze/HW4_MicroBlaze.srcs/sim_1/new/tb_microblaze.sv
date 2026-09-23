`timescale 1ns / 1ps

module tb_microblaze;

    logic       sys_clk;
    logic       sys_reset;
    logic [3:0] btns_4bits_tri_i;
    logic [3:0] sws_4bits_tri_i;
    wire  [3:0] leds_4bits_tri_o;

    microblaze_system_wrapper dut (
        .sys_clk            (sys_clk),
        .sys_reset          (sys_reset),
        .btns_4bits_tri_i   (btns_4bits_tri_i),
        .sws_4bits_tri_i    (sws_4bits_tri_i),
        .leds_4bits_tri_o   (leds_4bits_tri_o)
    );

    // Zybo input clock: 125 MHz -> 8 ns period
    always #4 sys_clk = ~sys_clk;

    task automatic press_button(input integer index);
        begin
            btns_4bits_tri_i[index] = 1'b1;
            #10000;   // 10 us
            btns_4bits_tri_i[index] = 1'b0;
            #5000;
        end
    endtask

    initial begin
    sys_clk          = 1'b0;
    sys_reset        = 1'b0;
    btns_4bits_tri_i = 4'b0000;
    sws_4bits_tri_i  = 4'b0000;

    // Active-low reset
    #1000;
    sys_reset = 1'b1;

    // Wait until software starts and turns on first LED
    wait (leds_4bits_tri_o != 4'b0000);

    // Normal forward movement
    #100000;

    // BTN0: faster
    press_button(0);
    #80000;

    // SW0: reverse direction
    sws_4bits_tri_i[0] = 1'b1;
    #80000;

    // BTN1: slower
    press_button(1);
    #100000;

    // BTN2: stop
    press_button(2);
    #100000;

    // BTN2: resume
    press_button(2);
    #100000;

    sws_4bits_tri_i[0] = 1'b0;
    #100000;

    $finish;
end

endmodule