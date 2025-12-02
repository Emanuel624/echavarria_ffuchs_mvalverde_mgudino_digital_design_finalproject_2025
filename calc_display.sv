module calc_display (
    input  logic        clk,
    input  logic        reset_n,

    input  logic        video_on,
    input  logic [9:0]  pixel_x,
    input  logic [9:0]  pixel_y,

    // Valores a mostrar
    input  logic [31:0] a_val,        // A (desde switches)
    input  logic [31:0] b_val,        // B (desde switches)
    input  logic [2:0]  op_code,      // 0=+,1=-,2=*,3=/,4=pow
    input  logic        op_selected,  // 1 si ya se eligió operador
    input  logic        op_highlight, // 1 cuando se acaba de presionar la tecla de operador
    input  logic [31:0] result_value, // resultado desde el CPU/dmem
    input  logic        show_result,  // 1 => capturar/mostrar resultado

    // VGA colores
    output logic [7:0]  vga_r,
    output logic [7:0]  vga_g,
    output logic [7:0]  vga_b
);

    // =====================================================
    // Función pow local (solo para op_code = 4)
    // pow(a_val, b_val), usando 5 bits del exponente (0..31)
    // =====================================================
    function automatic [31:0] pow_func(
        input logic [31:0] base_full,
        input logic [31:0] exp_full
    );
        logic [31:0] base;
        logic [4:0]  e;
        logic [31:0] res;
        int i;
        begin
            base = base_full;
            e    = exp_full[4:0];    // máx 31
            res  = 32'd1;
            for (i = 0; i < 32; i++) begin
                if (i < e)
                    res = res * base;
            end
            pow_func = res;
        end
    endfunction

    // =====================================================
    // resultado mostrado (estable en pantalla)
    //    + usamos pow_func cuando op_code = 4 (^) en vez del CPU
    // =====================================================
    logic [31:0] result_latched;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            result_latched <= 32'd0;
        end else if (show_result) begin
            if (op_code == 3'd4) begin
                // ^ → usamos pow(a_val, b_val)
                result_latched <= pow_func(a_val, b_val);
            end else begin
                // otros operadores → usamos resultado del CPU
                result_latched <= result_value;
            end
        end
    end

    // =====================================================
    // Conversión a decimal:
    //   - A y B: 2 dígitos (0..99)
    //   - Resultado: hasta 5 dígitos (0..99999), con signo
    // =====================================================

    function automatic [15:0] to_dec2(input logic [31:0] value);
        logic [31:0] v;
        logic [7:0] d0, d1;
        begin
            v  = value;
            d0 = "0" + (v % 10);
            v  = v / 10;
            d1 = "0" + (v % 10);
            to_dec2 = {d1, d0};
        end
    endfunction

    // Devuelve 5 bytes: D4 D3 D2 D1 D0
    function automatic [39:0] to_dec5(input logic [31:0] value);
        logic [31:0] v;
        logic [7:0] d0, d1, d2, d3, d4;
        begin
            v  = value;
            d0 = "0" + (v % 10);
            v  = v / 10;
            d1 = "0" + (v % 10);
            v  = v / 10;
            d2 = "0" + (v % 10);
            v  = v / 10;
            d3 = "0" + (v % 10);
            v  = v / 10;
            d4 = "0" + (v % 10);
            to_dec5 = {d4, d3, d2, d1, d0};
        end
    endfunction

    // A y B en 2 dígitos (0..99)
    logic [15:0] a_digits, b_digits;
    // Resultado |R| en 5 dígitos (0..99999)
    logic [39:0] r_digits5;
    logic        result_negative;
    logic [31:0] result_abs;

    always_comb begin
        a_digits = to_dec2(a_val);
        b_digits = to_dec2(b_val);

        // Manejo de signo del resultado
        result_negative = result_latched[31];
        if (result_negative)
            result_abs = (~result_latched) + 32'd1;  // valor absoluto de R
        else
            result_abs = result_latched;

        r_digits5 = to_dec5(result_abs);
    end

    // =====================================================
    // Línea de texto: A A op B B = [5 chars de resultado]
    // indices: 0..10 (máx 11 chars)
    //
    // Usamos:
    //   [0] A decena
    //   [1] A unidad
    //   [2] op
    //   [3] B decena
    //   [4] B unidad
    //   [5] '='
    //   [6] D4  (o '-' si negativo)
    //   [7] D3
    //   [8] D2
    //   [9] D1
    //   [10]D0
    // =====================================================
    logic [7:0] line [0:10];

    integer i;
    always_comb begin
        // Por defecto todo espacios
        for (i = 0; i <= 10; i = i + 1)
            line[i] = 8'h20; // ' '

        // A (2 dígitos)
        line[0] = a_digits[15:8];  // decena
        line[1] = a_digits[7:0];   // unidad

        // Operador en el medio (texto solo para referencia,
        // el dibujo real del símbolo se hace a mano)
        if (op_selected) begin
            case (op_code)
                3'd0: line[2] = 8'd43;   // '+'
                3'd1: line[2] = 8'd45;   // '-'
                3'd2: line[2] = 8'd42;   // '*', se dibuja como 'x'
                3'd3: line[2] = 8'd47;   // '/'
                3'd4: line[2] = 8'd94;   // '^'
                default: line[2] = 8'h20;
            endcase
        end

        // B (2 dígitos)
        line[3] = b_digits[15:8];
        line[4] = b_digits[7:0];

        // Resultado solo si show_result = 1
        if (show_result) begin
            line[5] = 8'd61;  // '='

            // D4..D0
            line[6]  = r_digits5[39:32]; // D4
            line[7]  = r_digits5[31:24]; // D3
            line[8]  = r_digits5[23:16]; // D2
            line[9]  = r_digits5[15:8];  // D1
            line[10] = r_digits5[7:0];   // D0

            // signo: si negativo, forzamos el char más significativo a '-'
            if (result_negative) begin
                line[6] = 8'd45; // '-'
            end
        end
    end

    // =====================================================
    // Área de display de texto (banda superior)
    // =====================================================
    logic       in_display_area;
    logic [3:0] char_index;
    logic [4:0] char_x;
    logic [4:0] char_y;

    assign in_display_area = (pixel_y >= 50 && pixel_y < 110 &&
                              pixel_x >= 100 && pixel_x < 540);

    assign char_index = (pixel_x >= 100) ? ((pixel_x - 10'd100) / 10'd40) : 4'd0;
    assign char_x     = (pixel_x >= 100) ? ((pixel_x - 10'd100) % 10'd40) : 5'd0;

    logic [5:0] char_y_temp;
    assign char_y_temp = (pixel_y >= 50) ? (pixel_y - 10'd50) : 6'd0;
    assign char_y      = char_y_temp[5:1];  // escala a 0..31 aprox

    logic [7:0] current_char;
    always_comb begin
        if (char_index <= 4'd10)
            current_char = line[char_index];
        else
            current_char = 8'h20;
    end

    
   
    logic char_pixel_raw;
    logic char_pixel;

    char_block char_gen (
        .ascii_code(current_char),
        .char_x    (char_x),
        .char_y    (char_y),
        .pixel     (char_pixel_raw)
    );

    
    assign char_pixel = (char_x == 5'd39) ? 1'b0 : char_pixel_raw;

   
    logic nice_zero_pixel;
    logic [2:0] zx, zy;  // 0..7 dentro de una rejilla 8x8

    assign zx = char_x[4:2];  // 0..7
    assign zy = char_y[4:2];  // 0..7

    always_comb begin
        nice_zero_pixel = 1'b0;

        // Solo si estamos en el área de display y el char actual es '0'
        if (in_display_area && (current_char == 8'd48)) begin
            // Zero tipo 8x8
            nice_zero_pixel =
                // TOP
                ((zy == 3'd1) && (zx >= 3'd2 && zx <= 3'd5)) ||
                // BOTTOM
                ((zy == 3'd6) && (zx >= 3'd2 && zx <= 3'd5)) ||
                // LEFT
                ((zx == 3'd2) && (zy >= 3'd2 && zy <= 3'd5)) ||
                // RIGHT
                ((zx == 3'd5) && (zy >= 3'd2 && zy <= 3'd5));
        end
    end

    // =====================================================
    // Operador en la banda superior: 
    // + usamos nice_zero_pixel para los ceros
    // =====================================================
    logic op_top_pixel;
    logic [3:0] top_x4, top_y4; 

    assign top_x4 = char_x[4:1];   
    assign top_y4 = char_y[4:1];

    always_comb begin
        op_top_pixel = 1'b0;

        if (in_display_area && (char_index == 4'd2)) begin
            // Celda del operador (posición 2)
            unique case (op_code)
                // + (centrado, grueso)
                3'd0: begin
                    op_top_pixel =
                        ((top_x4 >= 4'd7 && top_x4 <= 4'd8) &&
                         (top_y4 >= 4'd3 && top_y4 <= 4'd12)) ||
                        ((top_y4 >= 4'd7 && top_y4 <= 4'd8) &&
                         (top_x4 >= 4'd3 && top_x4 <= 4'd12));
                end

                // - (horizontal grueso centrado)
                3'd1: begin
                    op_top_pixel =
                        (top_y4 >= 4'd7 && top_y4 <= 4'd8) &&
                        (top_x4 >= 4'd3 && top_x4 <= 4'd12);
                end

                // x (diagonal cruz, más bonita y centrada)
                3'd2: begin
                    op_top_pixel =
                        // diagonal principal (↘) gruesa
                        (((top_x4 == top_y4) ||
                          (top_x4 == top_y4 + 1) ||
                          (top_x4 + 1 == top_y4)) &&
                         (top_x4 >= 4'd4 && top_x4 <= 4'd11)) ||

                        // diagonal secundaria (↙) gruesa
                        (((top_x4 + top_y4 == 4'd15) ||
                          (top_x4 + top_y4 == 4'd14) ||
                          (top_x4 + top_y4 == 4'd16)) &&
                         (top_x4 >= 4'd4 && top_x4 <= 4'd11));
                end

                // / (slash gruesa)
                3'd3: begin
                    op_top_pixel =
                        (top_x4 + top_y4 == 4'd13) ||
                        (top_x4 + top_y4 == 4'd14) ||
                        (top_x4 + top_y4 == 4'd15);
                end

                // ^ (caret limpio tipo potencia)
                3'd4: begin
                    op_top_pixel = 1'b0;
                    unique case (top_y4)
                        4'd4: op_top_pixel =
                            (top_x4 >= 4'd7 && top_x4 <= 4'd9);               // cumbre ancha
                        4'd5: op_top_pixel =
                            (top_x4 == 4'd7 || top_x4 == 4'd9);               // bajando
                        4'd6, 4'd7: op_top_pixel =
                            (top_x4 == 4'd6 || top_x4 == 4'd10);
                        4'd8, 4'd9: op_top_pixel =
                            (top_x4 == 4'd5 || top_x4 == 4'd11);
                        4'd10, 4'd11: op_top_pixel =
                            (top_x4 == 4'd4 || top_x4 == 4'd12);              // base
                        default: op_top_pixel = 1'b0;
                    endcase
                end

                default: op_top_pixel = char_pixel;
            endcase
        end else if (in_display_area && (current_char == 8'd48)) begin
            // Cualquier celda que contenga un '0' en la banda superior
            // usa el zero bonito
            op_top_pixel = nice_zero_pixel;
        end else begin
            // Otros caracteres usan el font normal
            op_top_pixel = char_pixel;
        end
    end

    // =====================================================
    // Fila de botones para operadores: +  -  x  /  ^
    // cada botón 100x100
    // =====================================================
    logic       in_op_btn_area;
    logic [2:0] btn_index;      // 0..4
    logic [6:0] btn_x, btn_y;   // 0..99 dentro del botón
    logic       op_btn_border;
    logic       this_btn_selected;
    logic       op_btn_pixel;   // pixel del símbolo dentro del botón

    // Área de botones: y entre 200..300, x entre 70..570 (5 botones de 100 px)
    assign in_op_btn_area = (pixel_y >= 200 && pixel_y < 300 &&
                             pixel_x >= 70  && pixel_x < 570);

    // Índice de botón 0..4
    assign btn_index = (in_op_btn_area)
                     ? ((pixel_x - 10'd70) / 10'd100)
                     : 3'd0;

    // Coordenadas dentro del botón (0..99)
    assign btn_x = (in_op_btn_area) ? ((pixel_x - 10'd70) % 10'd100) : 7'd0;
    assign btn_y = (in_op_btn_area) ? (pixel_y - 10'd200)           : 7'd0;

    // Borde del botón
    assign op_btn_border = (btn_x < 4 || btn_x >= 96 || btn_y < 4 || btn_y >= 96);

    // ¿Este botón corresponde al op_code actual?
    always_comb begin
        this_btn_selected = 1'b0;
        if (op_selected) begin
            case (op_code)
                3'd0: this_btn_selected = (btn_index == 3'd0); // +
                3'd1: this_btn_selected = (btn_index == 3'd1); // -
                3'd2: this_btn_selected = (btn_index == 3'd2); // x
                3'd3: this_btn_selected = (btn_index == 3'd3); // /
                3'd4: this_btn_selected = (btn_index == 3'd4); // ^
                default: this_btn_selected = 1'b0;
            endcase
        end
    end

    // Coords reducidos dentro del botón para dibujar el símbolo centrado
    // Escalamos 0..99 → 0..15
    logic [3:0] btn_x4, btn_y4; // 0..15
    assign btn_x4 = btn_x[6:3];
    assign btn_y4 = btn_y[6:3];

    // Dibujamos manualmente +, -, x, /, ^ (grandes y centrados)
    always_comb begin
        op_btn_pixel = 1'b0;

        if (in_op_btn_area && !op_btn_border) begin
            unique case (btn_index)
                // '+'
                3'd0: begin
                    op_btn_pixel =
                        // barra vertical centrada
                        ((btn_x4 >= 4'd7 && btn_x4 <= 4'd8) &&
                         (btn_y4 >= 4'd3 && btn_y4 <= 4'd12)) ||
                        // barra horizontal centrada
                        ((btn_y4 >= 4'd7 && btn_y4 <= 4'd8) &&
                         (btn_x4 >= 4'd3 && btn_x4 <= 4'd12));
                end

                // '-'
                3'd1: begin
                    op_btn_pixel =
                        (btn_y4 >= 4'd7 && btn_y4 <= 4'd8) &&
                        (btn_x4 >= 4'd3 && btn_x4 <= 4'd12);
                end

                // 'x' (cruz diagonal grande y centrada)
                3'd2: begin
                    op_btn_pixel =
                        // diagonal principal (↘) gruesa
                        (((btn_x4 == btn_y4) ||
                          (btn_x4 == btn_y4 + 1) ||
                          (btn_x4 + 1 == btn_y4)) &&
                         (btn_x4 >= 4'd4 && btn_x4 <= 4'd11)) ||

                        // diagonal secundaria (↙) gruesa
                        (((btn_x4 + btn_y4 == 4'd15) ||
                          (btn_x4 + btn_y4 == 4'd14) ||
                          (btn_x4 + btn_y4 == 4'd16)) &&
                         (btn_x4 >= 4'd4 && btn_x4 <= 4'd11));
                end

                // '/' gruesa
                3'd3: begin
                    op_btn_pixel =
                        (btn_x4 + btn_y4 == 4'd13) ||
                        (btn_x4 + btn_y4 == 4'd14) ||
                        (btn_x4 + btn_y4 == 4'd15);
                end

                // '^' (caret de potencia, bien formado)
                3'd4: begin
                    op_btn_pixel = 1'b0;
                    unique case (btn_y4)
                        4'd4: op_btn_pixel =
                            (btn_x4 >= 4'd7 && btn_x4 <= 4'd9);            // cumbre
                        4'd5: op_btn_pixel =
                            (btn_x4 == 4'd7 || btn_x4 == 4'd9);
                        4'd6, 4'd7: op_btn_pixel =
                            (btn_x4 == 4'd6 || btn_x4 == 4'd10);
                        4'd8, 4'd9: op_btn_pixel =
                            (btn_x4 == 4'd5 || btn_x4 == 4'd11);
                        4'd10, 4'd11: op_btn_pixel =
                            (btn_x4 == 4'd4 || btn_x4 == 4'd12);           // base
                        default: op_btn_pixel = 1'b0;
                    endcase
                end

                default: op_btn_pixel = 1'b0;
            endcase
        end
    end

    // =====================================================
    // Colores finales 
    // =====================================================
    always_comb begin
        if (!video_on) begin
            vga_r = 8'h00;
            vga_g = 8'h00;
            vga_b = 8'h00;
        end
        else if (in_display_area) begin
            // Banda superior: expresión A op B = R
            if (op_top_pixel) begin
                // operador en el índice 2: podemos resaltar si op_highlight
                if ((char_index == 4'd2) && op_highlight) begin
                    // operador en azul para el flash
                    vga_r = 8'h00;
                    vga_g = 8'h00;
                    vga_b = 8'hFF;
                end else begin
                    // texto normal negro
                    vga_r = 8'h00;
                    vga_g = 8'h00;
                    vga_b = 8'h00;
                end
            end else begin
                // fondo blanco
                vga_r = 8'hFF;
                vga_g = 8'hFF;
                vga_b = 8'hFF;
            end
        end
        else if (in_op_btn_area) begin
            // Fila de botones de operadores
            if (op_btn_border) begin
                // borde gris oscuro
                vga_r = 8'h40;
                vga_g = 8'h40;
                vga_b = 8'h40;
            end else begin
                // relleno del botón
                if (this_btn_selected) begin
                    // botón del operador seleccionado → más oscuro / resaltado
                    vga_r = 8'h80;
                    vga_g = 8'hA0;
                    vga_b = 8'hFF;
                end else begin
                    vga_r = 8'hC0;
                    vga_g = 8'hC0;
                    vga_b = 8'hC0;
                end

                // símbolo del botón encima (centrado y grande)
                if (op_btn_pixel) begin
                    vga_r = 8'h00;
                    vga_g = 8'h00;
                    vga_b = 8'h00;
                end
            end
        end
        else begin
            // Fondo general (azul oscuro suave)
            vga_r = 8'h00;
            vga_g = 8'h20;
            vga_b = 8'h40;
        end
    end

endmodule
