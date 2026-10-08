`timescale 1ns / 1ps

module debounce_button (
    input  logic clk,
    input  logic rst,
    input  logic btn_raw,
    output logic btn_pulse
);

    // 2-FF synchronizer
    logic btn_meta;
    logic btn_sync;

    // Debounce
    logic btn_stable;
    logic [19:0] debounce_cnt;

    // Edge detector
    logic btn_stable_d;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_meta <= 1'b0;
            btn_sync <= 1'b0;
        end else begin
            btn_meta <= btn_raw;
            btn_sync <= btn_meta;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_stable   <= 1'b0;
            debounce_cnt <= '0;
        end else begin
            if (btn_sync == btn_stable) begin
                debounce_cnt <= '0;
            end else begin
                if (&debounce_cnt) begin
                    btn_stable   <= btn_sync;
                    debounce_cnt <= '0;
                end else begin
                    debounce_cnt <= debounce_cnt + 1'b1;
                end
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_stable_d <= 1'b0;
            btn_pulse    <= 1'b0;
        end else begin
            btn_stable_d <= btn_stable;
            btn_pulse    <= btn_stable & ~btn_stable_d;
        end
    end

endmodule