module binary_to_bcd (
  input  logic [31:0] binary,
  output logic [3:0]  bcd_ones,    // Dígito de las unidades
  output logic [3:0]  bcd_tens     // Dígito de las decenas
);

  // Para números pequeños (0-99), usamos lógica combinacional
  // Tomamos solo los 7 bits inferiores para trabajar con 0-127
  logic [6:0] num;
  assign num = binary[6:0];  // Usa solo los 7 bits inferiores
  
  always_comb begin
    // Convertir a BCD (2 dígitos)
    bcd_tens = num / 10;      // Decenas
    bcd_ones = num % 10;      // Unidades
  end

endmodule