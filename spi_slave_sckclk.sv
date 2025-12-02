// spi_slave_sckclk.sv
// SPI slave (mode 0: CPOL=0, CPHA=0) using SCK as the only clock for shifters.
// - Sample MOSI on  posedge SCK
// - Shift  MISO on negedge SCK
// - Present MSB from tx_latch before the first rising edge of each frame
// - Initialize tx_shift from tx_latch on the first falling edge of the frame
// - Echo: data received in frame N is sent back in frame N+1 (tx_latch)
// Note: data_out is published at CS rising (end of frame).

module spi_slave_sckclk (
    input  logic spi_sclk,
    input  logic spi_mosi,
    input  logic spi_cs_n,   // active-low
    output logic spi_miso,

    output logic [7:0] data_out
);
    logic [7:0] rx_shift;
    logic [7:0] tx_shift;
    logic [7:0] tx_latch;    // holds the byte to echo on the next frame
    logic [2:0] bit_cnt;     // counts received bits (0..7) within a frame

    // ---------------------------
    // End of frame: CS rising
    //   - Publish the just-received byte to data_out
    //   - Choose what to echo next time (tx_latch <= rx_shift)
    // ---------------------------
    always_ff @(posedge spi_cs_n) begin
        data_out <= rx_shift;      // last byte received in this frame
        tx_latch <= rx_shift;      // echo next frame
    end

    // ---------------------------
    // RX path (mode 0): sample MOSI on posedge SCK
    // ---------------------------
    always_ff @(posedge spi_sclk) begin
        if (!spi_cs_n) begin
            rx_shift <= {rx_shift[6:0], spi_mosi};  // MSB-first in
            bit_cnt  <= bit_cnt + 3'd1;            // 0..7
        end else begin
            bit_cnt  <= 3'd0;                      // reset between frames
        end
    end

    // ---------------------------
    // TX path (mode 0): update on negedge SCK
    //   - For the very first bit of the frame (bit_cnt==0), we haven't had
    //     a falling edge yet; MISO must already show the MSB. We drive MISO
    //     from tx_latch[7] while bit_cnt==0.
    //   - On the first falling edge (still within bit_cnt==0 window),
    //     initialize tx_shift from tx_latch. On subsequent falls, shift.
    // ---------------------------
    always_ff @(negedge spi_sclk) begin
        if (!spi_cs_n) begin
            if (bit_cnt == 3'd0) begin
                // First falling edge of this frame: preload from tx_latch
                tx_shift <= {tx_latch[6:0], 1'b0};
            end else begin
                // Subsequent falling edges: shift left
                tx_shift <= {tx_shift[6:0], 1'b0};
            end
        end
        // When CS high: keep tx_shift as-is; it will be re-initialized next frame
    end

    // ---------------------------
    // Drive MISO:
    //   - While selected (CS low):
    //       * before first rising edge (bit_cnt==0), output tx_latch[7]
    //       * after that, output tx_shift[7]
    //   - When not selected, drive 0 (or tri-state if your board allows)
    // ---------------------------
    assign spi_miso = (!spi_cs_n)
                      ? ((bit_cnt == 3'd0) ? tx_latch[7] : tx_shift[7])
                      : 1'b0;

endmodule
