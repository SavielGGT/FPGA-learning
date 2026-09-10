`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2026 07:15:48 PM
// Design Name: 
// Module Name: lock_controller
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


module lock_controller (
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] digit_in,
    output logic       unlocked_led
);

    typedef enum logic [1:0] {
        LOCKED,
        WAIT_D2,
        WAIT_D3,
        UNLOCKED
    } state_t;

    state_t state, next_state;

    localparam logic [3:0] CODE0 = 4'd5;
    localparam logic [3:0] CODE1 = 4'd3;
    localparam logic [3:0] CODE2 = 4'd7;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= LOCKED;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        case (state)
            LOCKED:
                if (digit_in == CODE0)
                    next_state = WAIT_D2;
                else
                    next_state = LOCKED;

            WAIT_D2:
                if (digit_in == CODE1)
                    next_state = WAIT_D3;
                else
                    next_state = LOCKED;

            WAIT_D3:
                if (digit_in == CODE2)
                    next_state = UNLOCKED;
                else
                    next_state = LOCKED;

            UNLOCKED:
                next_state = UNLOCKED;

            default:
                next_state = LOCKED;
        endcase
    end

    always_comb begin
        unlocked_led = (state == UNLOCKED);
    end

endmodule
