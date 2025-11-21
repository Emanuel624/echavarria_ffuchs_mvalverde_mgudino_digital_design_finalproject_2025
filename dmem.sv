// =========================================================
// DMEM - Memoria de Datos (RAM)
// Versión UNIFICADA: Usa el módulo ram.v para simulación y síntesis
// =========================================================

module dmem (
  input  logic        clk,    // Reloj
  input  logic        we,     // Write Enable
  input  logic [31:0] a,      // Dirección (bytes)
  input  logic [31:0] wd,     // Write Data
  output logic [31:0] rd      // Read Data
);

  // Convertir dirección de bytes a índice de palabra
  // Para 2048 palabras: 11 bits de dirección
  // a[12:2] = índice de 0 a 2047
  wire [10:0] ram_address;
  assign ram_address = a[12:2];  // a / 4
  
  // Instanciar RAM del módulo ram.v
  // NOTA: Este módulo funciona igual en simulación y síntesis
  ram ram_inst (
    .address(ram_address),  // 11 bits (0-2047)
    .clock(clk),            // Reloj del sistema
    .data(wd),              // Datos a escribir
    .wren(we),              // Write enable
    .q(rd)                  // Datos leídos
  );

endmodule
