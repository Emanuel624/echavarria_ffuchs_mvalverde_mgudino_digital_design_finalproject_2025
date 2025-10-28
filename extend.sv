module extend (
  input  logic [23:0] Instr,
  input  logic [1:0]  ImmSrc,
  output logic [31:0] ExtImm
);
  always_comb begin
    // valor por defecto (evita latches)
    ExtImm = 32'b0;

    case (ImmSrc)
      // 8-bit unsigned immediate
      2'b00: ExtImm = {24'b0, Instr[7:0]};

      // 12-bit unsigned immediate
      2'b01: ExtImm = {20'b0, Instr[11:0]};

      // 24-bit two's complement shifted branch (sign-extend & << 2)
      2'b10: ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00};

      // undefined → mantiene el default (32'b0) para síntesis
      default: /* ExtImm = 32'b0 */;
    endcase
  end
endmodule
