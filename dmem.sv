// =========================================================
// DMEM - Memoria de Datos (RAM)
// Versión optimizada para síntesis en FPGA de Intel/Altera
// =========================================================

module dmem (
  input  logic        clk,    // Reloj
  input  logic        we,     // Write Enable
  input  logic [31:0] a,      // Dirección
  input  logic [31:0] wd,     // Write Data
  output logic [31:0] rd      // Read Data
);

  // RAM de 64 palabras de 32 bits
  // Quartus infiere esto como Block RAM (M10K) en la FPGA
  logic [31:0] RAM [63:0];

  // OPCION A: RAM sin inicializar (recomendado para datos)
  // Comentar la siguiente sección si no necesitas inicialización
  
  // OPCION B: RAM inicializada con .mif (opcional)
  // Descomenta si quieres pre-cargar datos en la RAM
  // initial begin
  //   $readmemh("data.mif", RAM);
  // end

  // Lectura combinacional
  // Dirección dividida por 4 (word-aligned)
  assign rd = RAM[a[31:2]];

  // Escritura sincrónica
  always_ff @(posedge clk) begin
    if (we) begin
      RAM[a[31:2]] <= wd;
    end
  end

  // NOTA: Para simulación y debugging, puedes inicializar a cero:
  // initial begin
  //   for (int i = 0; i < 64; i++) RAM[i] = 32'h0;
  // end

endmodule