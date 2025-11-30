// calc_display.sv
module calc_display (
    input  logic        clk,
    input  logic        reset_n,
    
    input  logic        video_on,
    input  logic [9:0]  pixel_x,
    input  logic [9:0]  pixel_y,
    
    input  logic [7:0]  key_ascii,
    input  logic        key_pressed,
    
    output logic [7:0]  vga_r,
    output logic [7:0]  vga_g,
    output logic [7:0]  vga_b
);

    logic [7:0] display_buffer [0:9];
    logic [3:0] display_length;
    
    logic [7:0] last_key;
    logic [7:0] highlight_counter;
    logic       button_highlight;
    
    integer i;
    
    // ---------------------
    // State for display + highlight
    // ---------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            display_length    <= 4'd0;
            last_key          <= 8'h00;
            highlight_counter <= 8'd0;
            button_highlight  <= 1'b0;
            for (i = 0; i < 10; i = i + 1) display_buffer[i] <= 8'h20;
        end else begin
            if (highlight_counter > 0) begin
                highlight_counter <= highlight_counter - 8'd1;
                button_highlight  <= 1'b1;
            end else begin
                button_highlight  <= 1'b0;
            end
            
            if (key_pressed) begin
                case (key_ascii)
                    8'd27: begin  // AC (Clear) - ESC
                        for (i = 0; i < 10; i = i + 1) display_buffer[i] <= 8'h20;
                        display_length <= 4'd0;
                    end
                    
                    8'd8: begin  // DEL (Backspace)
                        if (display_length > 0) begin
                            display_length <= display_length - 4'd1;
                            display_buffer[display_length - 1] <= 8'h20;
                        end
                    end
                    
                    8'd10: begin
                        // Enter: aquí podrías evaluar la expresión más adelante
                    end
                    
                    default: begin
                        // Only accept real calculator chars: digits and + - x / =
                        if (display_length < 10) begin
                            if ( (key_ascii >= 8'd48 && key_ascii <= 8'd57) ||   // '0'..'9'
                                 key_ascii == 8'd43  ||                          // '+'
                                 key_ascii == 8'd45  ||                          // '-'
                                 key_ascii == 8'd42  ||                          // 'x' (*)
                                 key_ascii == 8'd47  ||                          // '/'
                                 key_ascii == 8'd61 ) begin                      // '='
                                display_buffer[display_length] <= key_ascii;
                                display_length                 <= display_length + 4'd1;
                            end
                        end
                    end
                endcase
                
                last_key          <= key_ascii;
                highlight_counter <= 8'd12;
            end
        end
    end
    
    // ------------------------------
    // Top display area
    // ------------------------------
    logic [3:0] char_index;
    logic [4:0] char_x;
    logic [4:0] char_y;
    logic       char_pixel;
    logic       in_display_area;
    logic       in_button_area;
    logic [3:0] button_row, button_col;
    logic [7:0] button_ascii;
    logic [7:0] button_label_ascii;
    logic       button_border;
    
    assign in_display_area = (pixel_y >= 50 && pixel_y < 110 && 
                              pixel_x >= 100 && pixel_x < 540);
    
    assign char_index = (pixel_x >= 100) ? ((pixel_x - 10'd100) / 10'd40) : 4'd0;
    assign char_x     = (pixel_x >= 100) ? ((pixel_x - 10'd100) % 10'd40) : 5'd0;
    
    logic [5:0] char_y_temp;
    assign char_y_temp = (pixel_y >= 50) ? (pixel_y - 10'd50) : 6'd0;
    assign char_y      = char_y_temp[5:1];
    
    logic [7:0] current_char;
    assign current_char = (char_index < display_length) ? 
                          display_buffer[char_index] : 8'h20;
    
    char_block char_gen (
        .ascii_code(current_char),
        .char_x    (char_x),
        .char_y    (char_y),
        .pixel     (char_pixel)
    );
    
    // ------------------------------
    // Button grid area
    // ------------------------------
    assign in_button_area = (pixel_y >= 150 && pixel_y < 450 && 
                             pixel_x >= 100 && pixel_x < 540);
    
    assign button_row = (pixel_y >= 150) ? ((pixel_y - 10'd150) / 10'd75) : 4'd0;
    assign button_col = (pixel_x >= 100) ? ((pixel_x - 10'd100) / 10'd88) : 4'd0;
    
    logic [6:0] btn_x, btn_y;
    assign btn_x = (pixel_x >= 100) ? ((pixel_x - 10'd100) % 10'd88) : 7'd0;
    assign btn_y = (pixel_y >= 150) ? ((pixel_y - 10'd150) % 10'd75) : 7'd0;
    
    assign button_border = (btn_x < 4 || btn_x >= 84 || btn_y < 4 || btn_y >= 71);
    
    // Functional map (what each button actually does)
    always_comb begin
        button_ascii = 8'h20;
        unique case ({button_row, button_col})
            8'h00: button_ascii = 8'd55;  // 7
            8'h01: button_ascii = 8'd56;  // 8
            8'h02: button_ascii = 8'd57;  // 9
            8'h03: button_ascii = 8'd47;  // '/'
            8'h04: button_ascii = 8'd42;  // 'x' (*)
            
            8'h10: button_ascii = 8'd52;  // 4
            8'h11: button_ascii = 8'd53;  // 5
            8'h12: button_ascii = 8'd54;  // 6
            8'h13: button_ascii = 8'd42;  // 'x' (*)
            8'h14: button_ascii = 8'd27;  // AC (ESC)
            
            8'h20: button_ascii = 8'd49;  // 1
            8'h21: button_ascii = 8'd50;  // 2
            8'h22: button_ascii = 8'd51;  // 3
            8'h23: button_ascii = 8'd45;  // '-'
            8'h24: button_ascii = 8'd8;   // DEL
            
            8'h30: button_ascii = 8'd48;  // 0
            8'h32: button_ascii = 8'd43;  // '+'
            8'h34: button_ascii = 8'd61;  // '='
            
            default: button_ascii = 8'h20;
        endcase
    end
    
    // Label for each button:
    // 27 -> 'A' (AC), 8 -> 'D' (DEL), others are themselves
    always_comb begin
        unique case (button_ascii)
            8'd27: button_label_ascii = 8'd65; // 'A'
            8'd8:  button_label_ascii = 8'd68; // 'D'
            default: button_label_ascii = button_ascii;
        endcase
    end
    
    logic button_char_pixel;
    logic [4:0] btn_char_x, btn_char_y;

    // Better centering for characters inside button:
    // inner content area: approx 8..80 in x, 8..72 in y
    // scaled down by /2 to map to 0..32 range
    assign btn_char_x = (btn_x > 7 && btn_x < 81) ? ((btn_x - 7'd8) >> 1) : 5'd0;
    assign btn_char_y = (btn_y > 7 && btn_y < 73) ? ((btn_y - 7'd8) >> 1) : 5'd0;
    
    char_block button_char (
        .ascii_code(button_label_ascii),
        .char_x    (btn_char_x),
        .char_y    (btn_char_y),
        .pixel     (button_char_pixel)
    );
    
    // Highlight if this button's functional code == last_key
    logic this_button_highlight;
    assign this_button_highlight = button_highlight && (button_ascii == last_key);
    
    // ------------------------------
    // Final color composition
    // ------------------------------
    always_comb begin
        if (!video_on) begin
            vga_r = 8'h00;
            vga_g = 8'h00;
            vga_b = 8'h00;
        end else if (in_display_area) begin
            if (char_pixel) begin
                vga_r = 8'h00;
                vga_g = 8'h00;
                vga_b = 8'h00;
            end else begin
                vga_r = 8'hFF;
                vga_g = 8'hFF;
                vga_b = 8'hFF;
            end
        end else if (in_button_area) begin
            if (button_border) begin
                vga_r = 8'h40;
                vga_g = 8'h40;
                vga_b = 8'h40;
            end else begin
                if (this_button_highlight) begin
                    vga_r = 8'h80;
                    vga_g = 8'hA0;
                    vga_b = 8'hFF;
                end else begin
                    vga_r = 8'hC0;
                    vga_g = 8'hC0;
                    vga_b = 8'hC0;
                end
                
                if (button_char_pixel) begin
                    vga_r = 8'h00;
                    vga_g = 8'h00;
                    vga_b = 8'h00;
                end
            end
        end else begin
            vga_r = 8'h00;
            vga_g = 8'h20;
            vga_b = 8'h40;
        end
    end

endmodule
