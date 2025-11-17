module regfile (
  input  logic        clk,
  input  logic        we3,
  input  logic [3:0]  ra1, ra2, wa3,
  input  logic [31:0] wd3, r15,
  output logic [31:0] rd1, rd2
);

  // 15 registros físicos (R0..R14). R15 (PC)
  // INICIALIZAR todos a 0
  logic [31:0] rf [14:0] = '{default: 32'h0};

  // Escritura sincrónica.
  always_ff @(posedge clk) begin
    if (we3 && (wa3 != 4'd15)) begin
      rf[wa3] <= wd3;
    end
  end

  // Lecturas combinacionales
  always_comb begin
    if (ra1 == 4'd15) rd1 = r15;
    else              rd1 = rf[ra1];
  end

  always_comb begin
    if (ra2 == 4'd15) rd2 = r15;
    else              rd2 = rf[ra2];
  end

endmodule