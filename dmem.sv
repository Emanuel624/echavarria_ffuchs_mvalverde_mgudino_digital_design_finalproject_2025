module dmem (
  input  logic        clk,
  input  logic        we,
  input  logic [31:0] a,
  input  logic [31:0] wd,
  output logic [31:0] rd
);

  logic [31:0] RAM[63:0];
  
  // Cargar valores iniciales desde archivo
  initial $readmemh("C:/Users/Usuario/Desktop/TEC II 2025/Taller_DD/Proyecto_Final/echavarria_ffuchs_mvalverde_mgudino_digital_design_finalproject_2025/dmem_init.dat", RAM);
  
  assign rd = RAM[a[7:2]];
  
  always_ff @(posedge clk)
    if (we)
      RAM[a[7:2]] <= wd;

endmodule
