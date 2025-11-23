module dmem (
  input  logic        clk,
  input  logic        we,
  input  logic [31:0] a,
  input  logic [31:0] wd,
  output logic [31:0] rd
);

  wire [10:0] ram_address = a[31:2];

  ram ram_inst (
    .address(ram_address),
    .clock  (clk),
    .data   (wd),
    .wren   (we),
    .q      (rd)
  );

endmodule