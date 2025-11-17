// =========================================================
// DMEM - Memoria de Datos (RAM)
// Versión HÍBRIDA: Inferida en simulación, IP en síntesis
// =========================================================

module dmem (
  input  logic        clk,    // Reloj
  input  logic        we,     // Write Enable
  input  logic [31:0] a,      // Dirección (bytes)
  input  logic [31:0] wd,     // Write Data
  output logic [31:0] rd      // Read Data
);

`ifdef SIMULATION
  // =====================================================
  // SIMULACIÓN: Memoria inferida (más rápida)
  // =====================================================
  // RAM de 2048 palabras = 8 KB
  logic [31:0] RAM [0:2047];
  
  // Inicialización opcional (todo en 0)
  initial begin
    for (int i = 0; i < 2048; i++) begin
      RAM[i] = 32'h00000000;
    end
  end
  
  // Lectura combinacional
  // Dirección dividida por 4 (word-aligned)
  // a[12:2] = índice de 0 a 2047
  assign rd = RAM[a[12:2]];
  
  // Escritura sincrónica
  always_ff @(posedge clk) begin
    if (we) begin
      RAM[a[12:2]] <= wd;
    end
  end

`else
  // =====================================================
  // SÍNTESIS: RAM del IP Catalog (optimizada para FPGA)
  // =====================================================
  
  // Convertir dirección de bytes a índice de palabra
  // Para 2048 palabras: 11 bits de dirección
  wire [10:0] ram_address;
  assign ram_address = a[12:2];  // a / 4
  
  // Instanciar RAM del IP Catalog
  // IMPORTANTE: Genera este módulo en Quartus:
  //   Tools → IP Catalog → "RAM: 1-PORT"
  //   - Width: 32 bits
  //   - Depth: 2048 words
  //   - Name: data_ram
  ram ram_inst (
    .address(ram_address),  // 11 bits (0-2047)
    .clock(clk),            // Reloj del sistema
    .data(wd),              // Datos a escribir
    .wren(we),              // Write enable
    .q(rd)                  // Datos leídos
  );
`endif

endmodule

// =========================================================
// NOTAS:
// =========================================================
//
// 1. TAMAÑO DE MEMORIA:
//    - 2048 palabras × 4 bytes/palabra = 8 KB total
//    - Direcciones válidas: 0 a 8188 (de 4 en 4)
//    - Índices válidos: 0 a 2047
//
// 2. DIRECCIONAMIENTO:
//    Dirección (bytes)  →  Índice RAM
//    ─────────────────     ──────────
//         0         →         0
//         4         →         1
//         8         →         2
//        100        →        25
//       8188        →      2047
//
// 3. BITS DE DIRECCIÓN:
//    a[12:2] = 11 bits = 2048 posiciones
//    
// 4. PARA CAMBIAR TAMAÑO:
//    - 1 KB   (256 words):   RAM[0:255],    a[9:2]   (8 bits)
//    - 2 KB   (512 words):   RAM[0:511],    a[10:2]  (9 bits)
//    - 4 KB   (1024 words):  RAM[0:1023],   a[11:2]  (10 bits)
//    - 8 KB   (2048 words):  RAM[0:2047],   a[12:2]  (11 bits) ← ACTUAL
//    - 16 KB  (4096 words):  RAM[0:4095],   a[13:2]  (12 bits)
//    - 32 KB  (8192 words):  RAM[0:8191],   a[14:2]  (13 bits)
//
// 5. PARA VGA:
//    Si necesitas framebuffer, mapea así:
//    - 0x0000-0x0FFF: Datos del procesador (4 KB)
//    - 0x1000-0x1FFF: Framebuffer VGA (4 KB)
//
// =========================================================