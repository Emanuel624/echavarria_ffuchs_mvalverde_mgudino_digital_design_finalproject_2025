module top_test (
    input  logic       clk,
    input  logic       reset_n,
    
    input  logic       pi_spi_sclk,
    input  logic       pi_spi_mosi,
    input  logic       pi_spi_cs_n,
    
    output logic [7:0] leds,
    output logic [6:0] hex0,
    output logic [6:0] hex1
);

    // Synchronize
    logic [1:0] sclk_sync;
    logic [1:0] mosi_sync;
    logic [1:0] cs_sync;
    
    always_ff @(posedge clk) begin
        sclk_sync <= {sclk_sync[0], pi_spi_sclk};
        mosi_sync <= {mosi_sync[0], pi_spi_mosi};
        cs_sync <= {cs_sync[0], pi_spi_cs_n};
    end
    
    // Count SCLK toggles
    logic [23:0] toggle_count;
    logic sclk_prev;
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            toggle_count <= 0;
            sclk_prev <= 0;
        end else begin
            sclk_prev <= sclk_sync[1];
            if (sclk_sync[1] != sclk_prev) begin
                toggle_count <= toggle_count + 1;
            end
        end
    end
    
    // Show toggle count and pin states
    assign leds = toggle_count[7:0];
    assign hex0 = sclk_sync[1] ? 7'b1111001 : 7'b1000000;
    assign hex1 = mosi_sync[1] ? 7'b1111001 : 7'b1000000;

endmodule