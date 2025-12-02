module top_system (
    input  logic       clk_50mhz,
    input  logic       reset_n,

    // SPI desde la Raspberry Pi
    input  logic       pi_spi_sclk,
    input  logic       pi_spi_mosi,
    input  logic       pi_spi_cs_n,

    // Switches para A y B (4 bits cada uno)
    input  logic [3:0] sw_a,
    input  logic [3:0] sw_b,

    // Botón para evaluar (sin debounce externo)
    input  logic       btn_eval,

    // VGA
    output logic       vga_clk,
    output logic       vga_blank_n,
    output logic       vga_sync_n,
    output logic       vga_hsync,
    output logic       vga_vsync,
    output logic [7:0] vga_r,
    output logic [7:0] vga_g,
    output logic [7:0] vga_b,

    // LEDs
    output logic [9:0] LED
);

    // =====================================================
    // Reset interno
    // =====================================================
    logic reset;
    assign reset = ~reset_n;

    // =====================================================
    // ------------------  CPU ARM  ------------------------
    // =====================================================
    logic [31:0] PC;
    logic [31:0] Instr;
    logic [31:0] ReadData;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;
    logic        MemWrite;

    logic cpu_reset;
    assign cpu_reset = reset;   

    arm arm_inst (
        .clk       (clk_50mhz),
        .reset     (cpu_reset),
        .PC        (PC),
        .Instr     (Instr),
        .MemWrite  (MemWrite),
        .ALUResult (ALUResult),
        .WriteData (WriteData),
        .ReadData  (ReadData)
    );

    imem imem_inst (
        .a  (PC),
        .rd (Instr)
    );

    // =====================================================
    // Señales de la calculadora (A, B, operador, botón)
    // =====================================================
    logic [31:0] a_reg, b_reg;   // valores para escribir en RAM
    logic [2:0]  op_code_reg;    // 0=+,1=-,2=*,3=/,4=pow
    logic        op_selected;    // 1 => ya se recibió un operador válido

    // Highlight del operador cuando se presiona la tecla
    logic [7:0]  op_hl_counter;
    logic        op_highlight;

    // Pulso 1-ciclo cuando se presiona el botón "EVALUATE"
    logic eval_pulse;

    // Flag para mostrar el resultado en VGA
    logic show_result;

    // =====================================================
    // DEBOUNCE DEL BOTÓN
    // =====================================================
    button_debouncer #(
        .CNTR_MAX(1_000_000)     // ~20 ms @ 50 MHz
    ) deb_eval (
        .clk            (clk_50mhz),
        .reset_n        (reset_n),
        .noisy_in       (btn_eval),
        .debounced_pulse(eval_pulse)
    );

    // Latch de A y B cuando se presiona el botón
    always_ff @(posedge clk_50mhz or negedge reset_n) begin
        if (!reset_n) begin
            a_reg <= 32'd0;
            b_reg <= 32'd0;
        end else if (eval_pulse) begin
            a_reg <= {28'd0, sw_a};   // 4 bits → 32 bits
            b_reg <= {28'd0, sw_b};
        end
    end

    // show_result se activa cuando se presiona el botón
    always_ff @(posedge clk_50mhz or negedge reset_n) begin
        if (!reset_n) begin
            show_result <= 1'b0;
        end else if (eval_pulse) begin
            show_result <= 1'b1;
        end
    end

    // =====================================================
    // SPI: solo usamos el operador desde el teclado
    // =====================================================
    logic [7:0] received_ascii;
    logic       data_valid;   // 1 ciclo por byte recibido

    spi_slave_receiver spi_slave_inst (
        .clk       (clk_50mhz),
        .reset_n   (reset_n),
        .spi_sclk  (pi_spi_sclk),
        .spi_mosi  (pi_spi_mosi),
        .spi_cs_n  (pi_spi_cs_n),
        .data_out  (received_ascii),
        .data_valid(data_valid)
    );

    // Decodificación del operador + contador de highlight
    always_ff @(posedge clk_50mhz or negedge reset_n) begin
        if (!reset_n) begin
            op_code_reg    <= 3'd0;   // por defecto '+'
            op_selected    <= 1'b0;
            op_hl_counter  <= 8'd0;
        end else begin
            // Por defecto, el contador va bajando
            if (op_hl_counter != 8'd0)
                op_hl_counter <= op_hl_counter - 8'd1;

            if (data_valid) begin
                case (received_ascii)
                    8'd43: begin // '+'
                        op_code_reg   <= 3'd0;
                        op_selected   <= 1'b1;
                        op_hl_counter <= 8'd15;  // duración del highlight
                    end
                    8'd45: begin // '-'
                        op_code_reg   <= 3'd1;
                        op_selected   <= 1'b1;
                        op_hl_counter <= 8'd15;
                    end
                    8'd42: begin // '*'
                        op_code_reg   <= 3'd2;
                        op_selected   <= 1'b1;
                        op_hl_counter <= 8'd15;
                    end
                    8'd47: begin // '/'
                        op_code_reg   <= 3'd3;
                        op_selected   <= 1'b1;
                        op_hl_counter <= 8'd15;
                    end
                    8'd10: begin // Enter → potencia ^
                        op_code_reg   <= 3'd4;
                        op_selected   <= 1'b1;
                        op_hl_counter <= 8'd15;
                    end
                    default: ;   // ignoramos cualquier otra tecla
                endcase
            end
        end
    end

    assign op_highlight = (op_hl_counter != 8'd0);

    // =====================================================
    // DATA MEMORY (dmem) con nuevos puertos calc_*
    // =====================================================
    logic [31:0] result_suma;
    logic [31:0] result_resta;
    logic [31:0] result_mult;
    logic [31:0] result_div;
    logic [31:0] result_pow;

    dmem dmem_inst (
        .clk          (clk_50mhz),
        .we           (MemWrite),
        .a            (ALUResult),
        .wd           (WriteData),
        .rd           (ReadData),

        .load_en      (1'b0),
        .reset_en     (1'b0),

        // Cuando se presiona EVALUATE se guardan A, B y op en la RAM
        .calc_store_en(eval_pulse),
        .calc_a       (a_reg),
        .calc_b       (b_reg),
        .calc_op      (op_code_reg),

        .result_suma  (result_suma),
        .result_resta (result_resta),
        .result_mult  (result_mult),
        .result_div   (result_div),
        .result_pow   (result_pow)
    );

    // Selección del resultado según op_code_reg
    logic [31:0] cpu_result_selected;

    always_comb begin
        unique case (op_code_reg)
            3'd0: cpu_result_selected = result_suma;
            3'd1: cpu_result_selected = result_resta;
            3'd2: cpu_result_selected = result_mult;
            3'd3: cpu_result_selected = result_div;
            3'd4: cpu_result_selected = result_pow;
            default: cpu_result_selected = 32'd0;
        endcase
    end

    // Por ahora usamos los LEDs para ver el resultado en binario (para debug)
    assign LED = cpu_result_selected[9:0];

    // =====================================================
    // ------------------  VGA SIDE  -----------------------
    // =====================================================
    logic clk_25mhz;

    clk_divider clkdiv (
        .clk_50mhz (clk_50mhz),
        .reset_n   (reset_n),
        .clk_25mhz (clk_25mhz)
    );

    assign vga_clk = clk_25mhz;

    logic [9:0] pixel_x, pixel_y;
    logic       video_on;

    vga_sync vga_sync_inst (
        .clk_25mhz (clk_25mhz),
        .reset_n   (reset_n),
        .hsync     (vga_hsync),
        .vsync     (vga_vsync),
        .video_on  (video_on),
        .pixel_x   (pixel_x),
        .pixel_y   (pixel_y)
    );

    assign vga_blank_n = video_on;
    assign vga_sync_n  = 1'b0;

    // calc_display:
    // - Muestra A y B en decimal en la parte superior
    // - Muestra el operador cuando op_selected = 1
    // - Enter como '^' (op_code = 4)
    // - Hace highlight del operador cuando op_highlight = 1
    // - Muestra el resultado cuando show_result = 1
    calc_display display_inst (
        .clk          (clk_25mhz),
        .reset_n      (reset_n),
        .video_on     (video_on),
        .pixel_x      (pixel_x),
        .pixel_y      (pixel_y),
        .a_val        ({28'd0, sw_a}),          // valor actual de los switches A
        .b_val        ({28'd0, sw_b}),          // valor actual de los switches B
        .op_code      (op_code_reg),
        .op_selected  (op_selected),
        .op_highlight (op_highlight),
        .result_value (cpu_result_selected),
        .show_result  (show_result),
        .vga_r        (vga_r),
        .vga_g        (vga_g),
        .vga_b        (vga_b)
    );

endmodule


// =============================================================
//  MÓDULO DEBOUNCER PARA UN SOLO BOTÓN → PULSO DE 1 CICLO
// =============================================================
module button_debouncer #(
    parameter integer CNTR_MAX = 1_000_000   // ~20 ms @ 50 MHz
)(
    input  logic clk,
    input  logic reset_n,
    input  logic noisy_in,           
    output logic debounced_pulse     
);

    // Sincronización a clk
    logic sync_0, sync_1;
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= noisy_in;
            sync_1 <= sync_0;
        end
    end

    // Debounced level + contador
    logic debounced_level;
    logic [31:0] cnt;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            debounced_level <= 1'b0;
            cnt             <= 32'd0;
        end else begin
            if (sync_1 != debounced_level) begin
                // Cambió el estado -> resetear contador
                cnt <= 32'd0;
            end else if (cnt < CNTR_MAX) begin
                cnt <= cnt + 32'd1;
            end

            // Cuando se mantiene estable suficiente tiempo, actualizamos el nivel
            if (cnt == CNTR_MAX)
                debounced_level <= sync_1;
        end
    end

    // Generar pulso de 1 ciclo en flanco de subida del nivel debounced
    logic debounced_prev;
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            debounced_prev <= 1'b0;
        else
            debounced_prev <= debounced_level;
    end

    assign debounced_pulse = debounced_level & ~debounced_prev;

endmodule
