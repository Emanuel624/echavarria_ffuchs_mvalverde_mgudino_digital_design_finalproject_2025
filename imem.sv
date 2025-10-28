module imem (
  input  logic [31:0] a,
  output logic [31:0] rd
);
  logic [31:0] RAM [0:63];

  initial begin
    $readmemh("C:/Users/Usuario/Desktop/TEC II 2025/Taller_DD/Proyecto_Final/echavarria_ffuchs_mvalverde_mgudino_digital_design_finalproject_2025/memfile.dat", RAM);
  end

  assign rd = RAM[a[7:2]];

endmodule