module imem (
  input  logic [31:0] a,
  output logic [31:0] rd
);

  logic [31:0] RAM[63:0];
  
  initial $readmemh("C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/echavarria_ffuchs_mvalverde_mgudino_digital_design_finalproject_2025/memfile.dat", RAM);
  
  assign rd = RAM[a[7:2]]; // word-aligned

endmodule