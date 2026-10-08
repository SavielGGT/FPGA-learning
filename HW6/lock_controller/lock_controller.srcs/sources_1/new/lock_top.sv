`timescale 1ns / 1ps

module lock_top (
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] digit_in,
    input  logic       enter_btn,
    output logic       unlocked_led
);

    logic [3:0] digit_clean;
    logic       enter_pulse;

    debounce_digit debounce_inst (
        .clk            (clk),
        .rst            (rst),
        .digit_in_raw   (digit_in),
        .digit_in_clean (digit_clean)
    );

    debounce_button debounce_btn_inst (
        .clk       (clk),
        .rst       (rst),
        .btn_raw   (enter_btn),
        .btn_pulse (enter_pulse)
    );

    lock_controller lock_inst (
        .clk          (clk),
        .rst          (rst),
        .digit_in     (digit_clean),
        .enter_pulse  (enter_pulse),
        .unlocked_led (unlocked_led)
    );

endmodule