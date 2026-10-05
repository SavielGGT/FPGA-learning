`timescale 1ns / 1ps

module frame_receiver (
    // External pixel interface
    input  wire        pixel_clk,
    input  wire [7:0]  pixel_data,
    input  wire        pixel_valid,
    output wire        pixel_ready,

    // Start from MicroBlaze through AXI GPIO
    input  wire        start,

    // AXI4-Stream clock/reset
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m_axis_aclk CLK" *)
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_aclk, ASSOCIATED_BUSIF M_AXIS, ASSOCIATED_RESET m_axis_aresetn" *)
    input wire m_axis_aclk,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 m_axis_aresetn RST" *)
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_aresetn, POLARITY ACTIVE_LOW" *)
    input wire m_axis_aresetn,

    // AXI4-Stream master
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *)
    output wire [31:0] m_axis_tdata,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *)
    output wire        m_axis_tvalid,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *)
    input  wire        m_axis_tready,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TKEEP" *)
    output wire [3:0]  m_axis_tkeep,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *)
    output wire        m_axis_tlast
);

    // 320 * 200 = 64000 pixels = 64000 bytes
    localparam integer FRAME_BYTES = 64000;

    // ------------------------------------------------------------
    // Synchronize START into pixel_clk domain
    // ------------------------------------------------------------

    reg start_meta;
    reg start_sync;
    reg start_sync_d;

    always @(posedge pixel_clk or negedge m_axis_aresetn) begin
        if (!m_axis_aresetn) begin
            start_meta   <= 1'b0;
            start_sync   <= 1'b0;
            start_sync_d <= 1'b0;
        end
        else begin
            start_meta   <= start;
            start_sync   <= start_meta;
            start_sync_d <= start_sync;
        end
    end

    wire start_pulse;

    assign start_pulse = start_sync & ~start_sync_d;


    // ------------------------------------------------------------
    // Pack 4 x 8-bit pixels into one 32-bit word
    // ------------------------------------------------------------

    reg [31:0] pack_reg;
    reg [1:0]  pack_count;

    reg [15:0] pixel_count;

    reg active;

    reg [32:0] fifo_din;
    reg        fifo_wr_en;

    wire fifo_full;
    wire fifo_wr_rst_busy;

    // We can accept a byte if receiver is active.
    // If we already have 3 bytes, we need FIFO space for the 4th.
    assign pixel_ready =
        active &&
        !fifo_wr_rst_busy &&
        ((pack_count != 2'd3) || !fifo_full);


    always @(posedge pixel_clk or negedge m_axis_aresetn) begin
        if (!m_axis_aresetn) begin
            pack_reg    <= 32'd0;
            pack_count  <= 2'd0;
            pixel_count <= 16'd0;
            active      <= 1'b0;

            fifo_din    <= 33'd0;
            fifo_wr_en  <= 1'b0;
        end
        else begin
            fifo_wr_en <= 1'b0;

            // Start of a new frame
            if (start_pulse) begin
                pack_reg    <= 32'd0;
                pack_count  <= 2'd0;
                pixel_count <= 16'd0;
                active      <= 1'b1;
            end

            // Accept one pixel
            if (active && pixel_valid && pixel_ready) begin

                case (pack_count)

                    2'd0: begin
                        pack_reg[7:0] <= pixel_data;
                        pack_count    <= 2'd1;
                    end

                    2'd1: begin
                        pack_reg[15:8] <= pixel_data;
                        pack_count     <= 2'd2;
                    end

                    2'd2: begin
                        pack_reg[23:16] <= pixel_data;
                        pack_count      <= 2'd3;
                    end

                    2'd3: begin
                        // Fourth byte -> complete 32-bit word
                        fifo_din[31:0] <= {
                            pixel_data,
                            pack_reg[23:0]
                        };

                        // Last word of the frame
                        fifo_din[32] <=
                            (pixel_count == FRAME_BYTES - 1);

                        fifo_wr_en <= 1'b1;
                        pack_count <= 2'd0;
                    end

                endcase

                // Last pixel
                if (pixel_count == FRAME_BYTES - 1) begin
                    active <= 1'b0;
                end
                else begin
                    pixel_count <= pixel_count + 1'b1;
                end
            end
        end
    end


    // ------------------------------------------------------------
    // Asynchronous FIFO
    //
    // 33 bits:
    // [31:0] = data
    // [32]   = TLAST
    // ------------------------------------------------------------

    wire [32:0] fifo_dout;
    wire        fifo_empty;
    wire        fifo_rd_rst_busy;

    wire fifo_rd_en;

    assign fifo_rd_en =
        m_axis_tready &&
        !fifo_empty &&
        !fifo_rd_rst_busy;


    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE    ("auto"),
        .FIFO_WRITE_DEPTH    (512),

        .WRITE_DATA_WIDTH    (33),
        .READ_DATA_WIDTH     (33),

        .READ_MODE           ("fwft"),
        .FIFO_READ_LATENCY   (0),

        .CDC_SYNC_STAGES     (2),

        .DOUT_RESET_VALUE    ("0"),
        .FULL_RESET_VALUE    (0),

        .USE_ADV_FEATURES    ("0000"),
        .WAKEUP_TIME         (0),

        .WR_DATA_COUNT_WIDTH (10),
        .RD_DATA_COUNT_WIDTH (10)
    )
    pixel_fifo (
        .rst            (~m_axis_aresetn),

        .wr_clk         (pixel_clk),
        .wr_en          (fifo_wr_en),
        .din            (fifo_din),
        .full           (fifo_full),
        .wr_rst_busy    (fifo_wr_rst_busy),

        .rd_clk         (m_axis_aclk),
        .rd_en          (fifo_rd_en),
        .dout           (fifo_dout),
        .empty          (fifo_empty),
        .rd_rst_busy    (fifo_rd_rst_busy),

        .sleep          (1'b0),

        .overflow       (),
        .underflow      (),
        .prog_full      (),
        .prog_empty     (),
        .wr_data_count  (),
        .rd_data_count  (),
        .almost_full    (),
        .almost_empty   (),
        .wr_ack         (),
        .data_valid     (),

        .injectsbiterr  (1'b0),
        .injectdbiterr  (1'b0),
        .sbiterr        (),
        .dbiterr        ()
    );


    // ------------------------------------------------------------
    // AXI4-Stream output
    // ------------------------------------------------------------

    assign m_axis_tdata  = fifo_dout[31:0];
    assign m_axis_tlast  = fifo_dout[32];

    assign m_axis_tvalid =
        !fifo_empty &&
        !fifo_rd_rst_busy;

    // Every 32-bit word contains 4 valid bytes
    assign m_axis_tkeep = 4'b1111;

endmodule