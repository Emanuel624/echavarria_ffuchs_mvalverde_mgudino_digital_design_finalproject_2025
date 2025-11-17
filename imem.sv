// =========================================================
// IMEM - Memoria de instrucciones
// Usa memoria inferida en simulación, ROM IP en síntesis
// =========================================================
module imem (
  input  logic        clk,    // Reloj (solo para ROM IP en síntesis)
  input  logic [31:0] a,      // Dirección del PC (32 bits)
  output logic [31:0] rd      // Instrucción leída
);

`ifdef SIMULATION
  // =====================================================
  // SIMULACIÓN: Usar memoria inferida (más rápido)
  // =====================================================
  logic [31:0] ROM [0:255];
  
  initial begin
    $readmemh("program.mif", ROM);
  end
  
  // Lectura combinacional
  assign rd = ROM[a[9:2]];

`else
  // =====================================================
  // SÍNTESIS: Usar ROM del IP Catalog
  // =====================================================
  wire [7:0] rom_address;
  assign rom_address = a[9:2];
  
  rom rom_inst (
    .address(rom_address),
    .clock(clk),
    .q(rd)
  );
`endif

endmodule 	