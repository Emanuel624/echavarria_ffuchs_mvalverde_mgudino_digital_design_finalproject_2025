module top_vga_test (
    input  logic       clk_50mhz,
    input  logic       reset_n,
    
    output logic       vga_clk,
    output logic       vga_blank_n,
    output logic       vga_sync_n,
    output logic       vga_hsync,
    output logic       vga_vsync,
    output logic [7:0] vga_r,
    output logic [7:0] vga_g,
    output logic [7:0] vga_b,
    
    output logic [7:0] leds
);

    logic clk_div = 1'b0;
    always_ff @(posedge clk_50mhz) begin
        clk_div <= ~clk_div;
    end
    
    assign vga_clk = clk_div;
    
    logic [9:0] hc = 10'd0;
    logic [9:0] vc = 10'd0;
    
    always_ff @(posedge clk_div) begin
        if (hc == 10'd799) begin
            hc <= 10'd0;
            if (vc == 10'd524)
                vc <= 10'd0;
            else
                vc <= vc + 10'd1;
        end else begin
            hc <= hc + 10'd1;
        end
    end
    
    assign vga_hsync = (hc < 10'd656 || hc >= 10'd752);
    assign vga_vsync = (vc < 10'd490 || vc >= 10'd492);
    
    wire display = (hc < 10'd640) && (vc < 10'd480);
    assign vga_blank_n = display;
    assign vga_sync_n = 1'b0;
    
    // Color stripes based on X position
    wire [2:0] stripe = hc[9:7];  // 8 vertical stripes
    
    always_comb begin
        if (display) begin
            case (stripe)
                3'd0: begin vga_r = 8'hFF; vga_g = 8'hFF; vga_b = 8'hFF; end  // White
                3'd1: begin vga_r = 8'hFF; vga_g = 8'hFF; vga_b = 8'h00; end  // Yellow
                3'd2: begin vga_r = 8'h00; vga_g = 8'hFF; vga_b = 8'hFF; end  // Cyan
                3'd3: begin vga_r = 8'h00; vga_g = 8'hFF; vga_b = 8'h00; end  // Green
                3'd4: begin vga_r = 8'hFF; vga_g = 8'h00; vga_b = 8'hFF; end  // Magenta
                3'd5: begin vga_r = 8'hFF; vga_g = 8'h00; vga_b = 8'h00; end  // Red
                3'd6: begin vga_r = 8'h00; vga_g = 8'h00; vga_b = 8'hFF; end  // Blue
                3'd7: begin vga_r = 8'h00; vga_g = 8'h00; vga_b = 8'h00; end  // Black
            endcase
        end else begin
            vga_r = 8'h00;
            vga_g = 8'h00;
            vga_b = 8'h00;
        end
    end
    
    assign leds = stripe;  // Show which stripe (0-7)

endmodule