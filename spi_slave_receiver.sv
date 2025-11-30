// -------------------------------------------------------------
// spi_slave_receiver.sv  (Fixed Version)
// Generates data_valid = 1 for ONE clk cycle every time
// a full 8-bit SPI byte is received.
//
// SPI Mode 0: CPOL = 0, CPHA = 0
// Sample on rising edge of SCLK
// -------------------------------------------------------------
module spi_slave_receiver (
    input  logic       clk,       // <-- lo vamos a conectar a clk_25mhz
    input  logic       reset_n,
    
    // SPI lines from Raspberry Pi
    input  logic       spi_sclk,
    input  logic       spi_mosi,
    input  logic       spi_cs_n,
    
    // Outputs
    output logic [7:0] data_out,
    output logic       data_valid
);

    // --------------------------
    // Synchronizers
    // --------------------------
    logic [1:0] sclk_sync;
    logic [1:0] mosi_sync;
    logic [1:0] cs_sync;

    logic       sclk_prev;
    logic [7:0] shift_reg;
    logic [3:0] bit_count;

    // CS active low
    wire cs_active = !cs_sync[1];

    // Detect rising edge of SCLK (after sync)
    wire sclk_rising = (sclk_sync[1] & ~sclk_prev);

    // -----------------------------------------------------------
    // Main logic
    // -----------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sclk_sync  <= 2'b0;
            mosi_sync  <= 2'b0;
            cs_sync    <= 2'b11;
            sclk_prev  <= 1'b0;
            shift_reg  <= 8'd0;
            bit_count  <= 4'd0;
            data_out   <= 8'd0;
            data_valid <= 1'b0;
        end else begin
            // Sync SPI signals into clock domain
            sclk_sync <= {sclk_sync[0], spi_sclk};
            mosi_sync <= {mosi_sync[0], spi_mosi};
            cs_sync   <= {cs_sync[0],   spi_cs_n};

            sclk_prev <= sclk_sync[1];

            // Default: no new byte
            data_valid <= 1'b0;

            // ---------------------------------------------------
            // When CS is active and SCLK rises, sample bit
            // ---------------------------------------------------
            if (cs_active && sclk_rising) begin
                shift_reg <= {shift_reg[6:0], mosi_sync[1]};

                if (bit_count == 4'd7) begin
                    // 8 bits received → latch and pulse valid
                    data_out   <= {shift_reg[6:0], mosi_sync[1]};
                    data_valid <= 1'b1;
                    bit_count  <= 4'd0;
                end else begin
                    bit_count <= bit_count + 4'd1;
                end
            end

            // If CS goes inactive → reset counter
            if (!cs_active) begin
                bit_count <= 4'd0;
            end
        end
    end

endmodule
