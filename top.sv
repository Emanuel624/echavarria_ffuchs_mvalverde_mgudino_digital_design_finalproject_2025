// top.sv
module top (
    input  logic       clk,
    input  logic       reset_n,
    
    // SPI from Raspberry Pi
    input  logic       pi_spi_sclk,
    input  logic       pi_spi_mosi,
    input  logic       pi_spi_cs_n,
    
    // Outputs
    output logic [7:0] leds,
    output logic [6:0] hex0,
    output logic [6:0] hex1
);

    // Received byte from SPI
    logic [7:0] received_byte;
    
    // SPI Slave instance
    spi_slave_receiver spi_slave (
        .clk(clk),
        .reset_n(reset_n),
        .spi_sclk(pi_spi_sclk),
        .spi_mosi(pi_spi_mosi),
        .spi_cs_n(pi_spi_cs_n),
        .data_out(received_byte)
    );
    
    // Display received byte on LEDs
    assign leds = received_byte;
    
    // Convert to BCD
    logic [3:0] hundreds, tens, ones;
    
    bin_to_bcd bcd_converter (
        .binary(received_byte),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );
    
    // Display ones digit
    seven_seg_decoder decoder_ones (
        .digit(ones),
        .segments(hex0)
    );
    
    // Display tens digit
    seven_seg_decoder decoder_tens (
        .digit(tens),
        .segments(hex1)
    );

endmodule