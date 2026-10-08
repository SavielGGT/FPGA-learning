`timescale 1ns / 1ps

module lock_controller (
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] digit_in,
    input  logic       enter_pulse,
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

    // Current FSM state
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= LOCKED;
        else
            state <= next_state;
    end

    // Next-state logic
    always_comb begin
        next_state = state;

        // Change state only when Enter is pressed
        if (enter_pulse) begin
            case (state)

                LOCKED: begin
                    if (digit_in == CODE0)
                        next_state = WAIT_D2;
                    else
                        next_state = LOCKED;
                end

                WAIT_D2: begin
                    if (digit_in == CODE1)
                        next_state = WAIT_D3;
                    else
                        next_state = LOCKED;
                end

                WAIT_D3: begin
                    if (digit_in == CODE2)
                        next_state = UNLOCKED;
                    else
                        next_state = LOCKED;
                end

                UNLOCKED: begin
                    next_state = UNLOCKED;
                end

                default: begin
                    next_state = LOCKED;
                end

            endcase
        end
    end

    // LED is ON when lock is opened
    always_comb begin
        unlocked_led = (state == UNLOCKED);
    end

    // Integrated Logic Analyzer
    ila_0 ila_inst (
        .clk    (clk),
        .probe0 (state),
        .probe1 (next_state),
        .probe2 (digit_in),
        .probe3 (enter_pulse),
        .probe4 (unlocked_led)
    );

endmodule