module imem (
  input  logic        clk,
  input  logic [31:0] a,
  output logic [31:0] rd
);

  wire [7:0] rom_address = a[9:2];

  rom rom_inst (
    .address(rom_address),
    .clock  (clk),
    .q      (rd)
  );

endmodule
