// tb_design_1_wrapper_p3.v

`timescale 1ns / 1ps

module tb_design_1_wrapper;

    localparam integer FRAME_BYTES = 64000;

    // -----------------------------------------------------
    // System clock: 100 MHz differential
    // -----------------------------------------------------
    reg diff_clock_rtl_0_clk_p = 1'b0;
    wire diff_clock_rtl_0_clk_n = ~diff_clock_rtl_0_clk_p;

    always #5 diff_clock_rtl_0_clk_p = ~diff_clock_rtl_0_clk_p;


    // -----------------------------------------------------
    // Reset
    // ACTIVE LOW
    // -----------------------------------------------------
    reg reset_rtl_0 = 1'b0;


    // -----------------------------------------------------
    // Button -> AXI GPIO channel 1
    // -----------------------------------------------------
    reg gpio_rtl_0_tri_i = 1'b0;


    // -----------------------------------------------------
    // External pixel interface
    // -----------------------------------------------------
    reg        pixel_clk_0   = 1'b0;
    reg [7:0]  pixel_data_0  = 8'h00;
    reg        pixel_valid_0 = 1'b0;

    wire       pixel_ready_0;

    // Pixel clock = 100 MHz
    always #5 pixel_clk_0 = ~pixel_clk_0;


    // -----------------------------------------------------
    // DUT
    // -----------------------------------------------------
    design_1_wrapper dut (
        .diff_clock_rtl_0_clk_p (diff_clock_rtl_0_clk_p),
        .diff_clock_rtl_0_clk_n (diff_clock_rtl_0_clk_n),

        .reset_rtl_0            (reset_rtl_0),

        .gpio_rtl_0_tri_i       (gpio_rtl_0_tri_i),

        .pixel_clk_0             (pixel_clk_0),
        .pixel_data_0            (pixel_data_0),
        .pixel_valid_0           (pixel_valid_0),
        .pixel_ready_0           (pixel_ready_0)
    );


    // -----------------------------------------------------
    // Send one complete 320x200 frame
    // -----------------------------------------------------
    integer pixel_count;

    task send_frame;
    begin
        pixel_count = 0;

        while (pixel_count < FRAME_BYTES) begin

            @(negedge pixel_clk_0);

            if (pixel_ready_0) begin
                pixel_valid_0 = 1'b1;

                // Test pattern:
                // 00 01 02 ... FF 00 01 ...
                pixel_data_0 = pixel_count[7:0];

                pixel_count = pixel_count + 1;
            end
            else begin
                // Receiver/FIFO temporarily cannot accept data
                pixel_valid_0 = 1'b0;
            end
        end

        @(negedge pixel_clk_0);
        pixel_valid_0 = 1'b0;
        pixel_data_0  = 8'h00;

        $display("[%0t] FRAME SENT: %0d bytes",
                 $time, FRAME_BYTES);
    end
    endtask


    // -----------------------------------------------------
    // Main simulation
    // -----------------------------------------------------
    initial begin

        gpio_rtl_0_tri_i = 1'b0;
        pixel_valid_0    = 1'b0;
        pixel_data_0     = 8'h00;

        // Reset active
        reset_rtl_0 = 1'b0;

        #1000;

        // Release reset
        reset_rtl_0 = 1'b1;

        $display("[%0t] Reset released", $time);


        // Give MicroBlaze time to start executing ELF
        #200000;


        // -------------------------------------------------
        // Press BTN0
        // -------------------------------------------------
        gpio_rtl_0_tri_i = 1'b1;

        $display("[%0t] BTN0 pressed", $time);


        // Wait until MicroBlaze:
        // 1. arms DMA
        // 2. sets START=1
        // 3. frame_receiver becomes ready
        wait (pixel_ready_0 == 1'b1);

        $display("[%0t] pixel_ready = 1, receiver started",
                 $time);


        // Send complete frame
        send_frame();


        // Release button
        gpio_rtl_0_tri_i = 1'b0;

        $display("[%0t] BTN0 released", $time);


        // Give DMA / MicroBlaze some time to finish
        #300000;

        $display("[%0t] Simulation finished", $time);

        $finish;
    end


    // -----------------------------------------------------
    // Safety timeout
    // -----------------------------------------------------
    initial begin
        #5000000;      // 5 ms

        $display("[%0t] TIMEOUT", $time);

        $finish;
    end

endmodule