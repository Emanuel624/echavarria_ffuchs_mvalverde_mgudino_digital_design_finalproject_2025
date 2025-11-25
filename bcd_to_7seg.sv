module bcd_to_7seg (
  input  logic [3:0] bcd_digit,
  output logic [6:0] seg_code     // 7 segmentos: {a, b, c, d, e, f, g}
);

  // Tabla de verdad para dígitos 0-9
  // Formato: {a, b, c, d, e, f, g} donde:
  // a = top, b = top-right, c = bottom-right, d = bottom, e = bottom-left, f = top-left, g = middle
  // Activos en alto (1 = enciende el segmento)
  always_comb begin
    case(bcd_digit)
      4'h0: seg_code = 7'b1110111;  // 0
      4'h1: seg_code = 7'b0010100;  // 1
      4'h2: seg_code = 7'b1011101;  // 2
      4'h3: seg_code = 7'b1011001;  // 3
      4'h4: seg_code = 7'b0110100;  // 4
      4'h5: seg_code = 7'b1101001;  // 5
      4'h6: seg_code = 7'b1101111;  // 6
      4'h7: seg_code = 7'b1010100;  // 7
      4'h8: seg_code = 7'b1111111;  // 8
      4'h9: seg_code = 7'b1111001;  // 9
      default: seg_code = 7'b0000000;  // Apagado
    endcase
  end

endmodule