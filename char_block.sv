// char_block.sv
module char_block (
    input  logic [7:0] ascii_code,
    input  logic [4:0] char_x,
    input  logic [4:0] char_y,
    output logic       pixel
);

    always_comb begin
        pixel = 1'b0;
        
        case (ascii_code)
            8'd48: begin  // '0'
                if ((char_x >= 8 && char_x <= 24) && 
                    ((char_y >= 4 && char_y <= 8) || (char_y >= 24 && char_y <= 28))) pixel = 1'b1;
                if (((char_x >= 4 && char_x <= 8) || (char_x >= 24 && char_x <= 28)) && 
                    (char_y >= 8 && char_y <= 24)) pixel = 1'b1;
            end
            
            8'd49: begin  // '1'
                if (char_x >= 16 && char_x <= 20 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
                if (char_x >= 12 && char_x <= 16 && char_y >= 8 && char_y <= 12) pixel = 1'b1;
            end
            
            8'd50: begin  // '2'
                if (char_y >= 4 && char_y <= 8 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 8 && char_y <= 14) pixel = 1'b1;
                if (char_x >= 8 && char_x <= 12 && char_y >= 18 && char_y <= 24) pixel = 1'b1;
            end
            
            8'd51: begin  // '3'
                if (char_y >= 4 && char_y <= 8 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 8 && char_y <= 24) pixel = 1'b1;
            end
            
            8'd52: begin  // '4'
                if (char_x >= 8 && char_x <= 12 && char_y >= 4 && char_y <= 18) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
            end
            
            8'd53: begin  // '5'
                if (char_y >= 4 && char_y <= 8 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_x >= 8 && char_x <= 12 && char_y >= 4 && char_y <= 14) pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 14 && char_y <= 24) pixel = 1'b1;
            end
            
            8'd54: begin  // '6'
                if (char_y >= 4 && char_y <= 8 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_x >= 8 && char_x <= 12 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 14 && char_y <= 24) pixel = 1'b1;
            end
            
            8'd55: begin  // '7'
                if (char_y >= 4 && char_y <= 8 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
            end
            
            8'd56: begin  // '8'
                if (char_y >= 4 && char_y <= 8 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (((char_x >= 4 && char_x <= 8) || (char_x >= 24 && char_x <= 28)) && 
                    (char_y >= 8 && char_y <= 24)) pixel = 1'b1;
            end
            
            8'd57: begin  // '9'
                if (char_y >= 4 && char_y <= 8 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
                if (char_x >= 8 && char_x <= 12 && char_y >= 4 && char_y <= 14) pixel = 1'b1;
            end
            
            8'd43: begin  // '+'
                if (char_x >= 14 && char_x <= 18 && char_y >= 8 && char_y <= 24) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
            end
            
            8'd45: begin  // '-'
                if (char_y >= 14 && char_y <= 18 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
            end
            
            8'd42: begin  // 'x' (multiply) – THICK X
                if (char_x >= 6 && char_x <= 26) begin
                    // Main diagonal (y ~ x)
                    if (char_y >= (char_x - 1) && char_y <= (char_x + 1))
                        pixel = 1'b1;
                    // Other diagonal (y ~ 31 - x)
                    if (char_y >= (31 - char_x - 1) && char_y <= (31 - char_x + 1))
                        pixel = 1'b1;
                end
            end

            8'd47: begin  // '/' – THICK slash
                if (char_x >= 6 && char_x <= 26) begin
                    // y ≈ 31 - x  (3-pixel wide)
                    if ( (char_y == (31 - char_x)) ||
                         (char_y == (30 - char_x)) ||
                         (char_y == (32 - char_x)) )
                        pixel = 1'b1;
                end
            end
            
            8'd61: begin  // '='
                if (char_y >= 12 && char_y <= 15 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 17 && char_y <= 20 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
            end

            // 'A' (for AC)
            8'd65: begin  // 'A'
                if (char_y >= 4 && char_y <= 8 && char_x >= 10 && char_x <= 22) pixel = 1'b1;
                if (char_x >= 8 && char_x <= 12 && char_y >= 4 && char_y <= 28)  pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
                if (char_y >= 16 && char_y <= 20 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
            end
            
            // 'C'
            8'd67: begin  // 'C'
                if (char_y >= 4 && char_y <= 8 && char_x >= 10 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 10 && char_x <= 24) pixel = 1'b1;
                if (char_x >= 8 && char_x <= 12 && char_y >= 6 && char_y <= 26) pixel = 1'b1;
            end
            
            // 'D' (for DEL)
            8'd68: begin  // 'D'
                if (char_x >= 8 && char_x <= 12 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
                if (char_y >= 4 && char_y <= 8 && char_x >= 10 && char_x <= 22) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 10 && char_x <= 22) pixel = 1'b1;
                if (char_x >= 20 && char_x <= 24 && char_y >= 8 && char_y <= 24) pixel = 1'b1;
            end
            
            // 'E'
            8'd69: begin  // 'E'
                if (char_x >= 8 && char_x <= 12 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
                if (char_y >= 4 && char_y <= 8 && char_x >= 10 && char_x <= 24) pixel = 1'b1;
                if (char_y >= 14 && char_y <= 18 && char_x >= 10 && char_x <= 20) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 10 && char_x <= 24) pixel = 1'b1;
            end
            
            // 'L'
            8'd76: begin  // 'L'
                if (char_x >= 8 && char_x <= 12 && char_y >= 4 && char_y <= 28) pixel = 1'b1;
                if (char_y >= 24 && char_y <= 28 && char_x >= 8 && char_x <= 24) pixel = 1'b1;
            end

            default: pixel = 1'b0;
        endcase
    end

endmodule
