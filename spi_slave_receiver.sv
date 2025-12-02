module spi_slave_receiver (
    input  logic       clk,
    input  logic       reset_n,
    input  logic       spi_sclk,
    input  logic       spi_mosi,
    input  logic       spi_cs_n,

    output logic [7:0] data_out,
    output logic       data_valid   // NEW: pulses once per received byte
);

    logic [2:0] bit_count;
    logic [7:0] shift_reg;
    logic       sclk_prev;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            bit_count   <= 0;
            shift_reg   <= 0;
            data_out    <= 0;
            data_valid  <= 0;
            sclk_prev   <= 0;
        end 
        else begin
            data_valid <= 0;  // default: no new data

            // Detect rising edge of SCLK while CS is low (mode 0)
            if (!spi_cs_n && spi_sclk && !sclk_prev) begin
                shift_reg <= {shift_reg[6:0], spi_mosi};
                bit_count <= bit_count + 1;

                if (bit_count == 3'd7) begin
                    data_out   <= {shift_reg[6:0], spi_mosi};
                    data_valid <= 1'b1;  // PULSE HERE: 1 cycle per byte
                    bit_count  <= 0;
                end
            end

            sclk_prev <= spi_sclk;
        end
    end

endmodule
