`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 07:21:13 PM
// Design Name: 
// Module Name: debounce_digit
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

module debounce_digit #(
    parameter integer CLK_FREQ_HZ = 125_000_000,
    parameter integer DEBOUNCE_MS = 10
)(
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] digit_in_raw,
    output logic [3:0] digit_in_clean
);

    localparam integer COUNT_MAX =
        (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;

    localparam integer COUNT_WIDTH =
        $clog2(COUNT_MAX + 1);

    logic [3:0] sync_1;
    logic [3:0] sync_2;
    logic [3:0] candidate;

    logic [COUNT_WIDTH-1:0] counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_1        <= 4'd0;
            sync_2        <= 4'd0;
            candidate     <= 4'd0;
            digit_in_clean <= 4'd0;
            counter       <= '0;
        end
        else begin
            sync_1 <= digit_in_raw;
            sync_2 <= sync_1;

            if (sync_2 != candidate) begin
                candidate <= sync_2;
                counter   <= '0;
            end
            else if (candidate != digit_in_clean) begin
                if (counter == COUNT_MAX - 1) begin
                    digit_in_clean <= candidate;
                    counter        <= '0;
                end
                else begin
                    counter <= counter + 1'b1;
                end
            end
            else begin
                counter <= '0;
            end
        end
    end

endmodule