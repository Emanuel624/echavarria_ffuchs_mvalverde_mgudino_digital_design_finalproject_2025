// vga_sync.sv
module vga_sync (
    input  logic       clk_25mhz,
    input  logic       reset_n,
    
    output logic       hsync,
    output logic       vsync,
    output logic       video_on,
    output logic [9:0] pixel_x,
    output logic [9:0] pixel_y
);

    localparam H_DISPLAY = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;
    
    localparam V_DISPLAY = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;
    
    logic [9:0] h_count;
    logic [9:0] v_count;
    
    always_ff @(posedge clk_25mhz or negedge reset_n) begin
        if (!reset_n) begin
            h_count <= 10'd0;
        end else begin
            if (h_count == (H_TOTAL - 1))
                h_count <= 10'd0;
            else
                h_count <= h_count + 10'd1;
        end
    end
    
    always_ff @(posedge clk_25mhz or negedge reset_n) begin
        if (!reset_n) begin
            v_count <= 10'd0;
        end else begin
            if (h_count == (H_TOTAL - 1)) begin
                if (v_count == (V_TOTAL - 1))
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end
        end
    end
    
    assign hsync = ~((h_count >= (H_DISPLAY + H_FRONT)) && 
                     (h_count < (H_DISPLAY + H_FRONT + H_SYNC)));
    
    assign vsync = ~((v_count >= (V_DISPLAY + V_FRONT)) && 
                     (v_count < (V_DISPLAY + V_FRONT + V_SYNC)));
    
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    
    assign pixel_x = (h_count < H_DISPLAY) ? h_count : 10'd0;
    assign pixel_y = (v_count < V_DISPLAY) ? v_count : 10'd0;

endmodule