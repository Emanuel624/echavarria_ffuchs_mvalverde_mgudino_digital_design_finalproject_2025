module display_controller (
  input  logic [31:0] result_value,
  output logic [6:0]  seg_code      // 7-segmentos único
);

  logic [3:0] bcd_ones;

  // Convertir binario a BCD
  binary_to_bcd bcd_conv (
    .binary(result_value),
    .bcd_ones(bcd_ones),
    .bcd_tens()                      // No usamos decenas
  );

  // Convertir dígito de unidades a 7-segmentos
  bcd_to_7seg seg_conv (
    .bcd_digit(bcd_ones),
    .seg_code(seg_code)
  );

endmodule