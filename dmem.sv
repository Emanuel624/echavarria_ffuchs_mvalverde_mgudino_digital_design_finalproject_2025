module dmem (
  input  logic        clk,
  input  logic        we,
  input  logic [31:0] a, wd,
  output logic [31:0] rd
);
  // 64 palabras de 32 bits: índices 0..63
  logic [31:0] RAM [0:63];

  // Lectura combinacional
  assign rd = RAM[a[31:2]];

  // Escritura sincrónica
  always_ff @(posedge clk) begin
    if (we) RAM[a[31:2]] <= wd;
  end
endmodule
