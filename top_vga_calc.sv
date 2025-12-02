// top_vga_calc.sv
module top_vga_calc (
    input  logic       clk_50mhz,
    input  logic       reset_n,
    
    // SPI desde la Raspberry Pi
    input  logic       pi_spi_sclk,
    input  logic       pi_spi_mosi,
    input  logic       pi_spi_cs_n,
    
    // Señales VGA
    output logic       vga_clk,
    output logic       vga_blank_n,
    output logic       vga_sync_n,
    output logic       vga_hsync,
    output logic       vga_vsync,
    output logic [7:0] vga_r,
    output logic [7:0] vga_g,
    output logic [7:0] vga_b,
    
    // LEDs en la FPGA
    output logic [7:0] leds
);

    // -----------------------
    // Clocks y señales internas
    // -----------------------
    logic       clk_25mhz;
    logic       video_on;
    logic [9:0] pixel_x, pixel_y;

    logic [7:0] received_ascii;
    logic       key_pressed_pulse;   // strobe para cada byte recibido

    // -----------------------
    // Divisor 50 MHz -> 25 MHz
    // -----------------------
    clk_divider clk_div_inst (
        .clk_50mhz (clk_50mhz),
        .reset_n   (reset_n),
        .clk_25mhz (clk_25mhz)
    );

    // Clock VGA
    assign vga_clk     = clk_25mhz;
    assign vga_blank_n = video_on;
    assign vga_sync_n  = 1'b0;      // no se usa, amarrado a 0

    // -----------------------
    // SPI Slave corriendo en clk_25mhz
    // -----------------------
    spi_slave_receiver spi_slave_inst (
        .clk        (clk_25mhz),      // IMPORTANTE: mismo dominio que calc_display
        .reset_n    (reset_n),
        .spi_sclk   (pi_spi_sclk),
        .spi_mosi   (pi_spi_mosi),
        .spi_cs_n   (pi_spi_cs_n),
        .data_out   (received_ascii),
        .data_valid (key_pressed_pulse)
    );

    // -----------------------
    // Generador de sincronía VGA
    // -----------------------
    vga_sync vga_sync_inst (
        .clk_25mhz (clk_25mhz),
        .reset_n   (reset_n),
        .hsync     (vga_hsync),
        .vsync     (vga_vsync),
        .video_on  (video_on),
        .pixel_x   (pixel_x),
        .pixel_y   (pixel_y)
    );

    // -----------------------
    // Módulo de display de calculadora
    // -----------------------
    calc_display calc_display_inst (
        .clk         (clk_25mhz),
        .reset_n     (reset_n),
        .video_on    (video_on),
        .pixel_x     (pixel_x),
        .pixel_y     (pixel_y),

        .key_ascii   (received_ascii),
        .key_pressed (key_pressed_pulse),

        .vga_r       (vga_r),
        .vga_g       (vga_g),
        .vga_b       (vga_b)
    );

    // -----------------------
    // Mostrar el último ASCII en los LEDs
    // -----------------------
    assign leds = received_ascii;

endmodule
