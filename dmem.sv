module dmem (
  input  logic        clk,
  input  logic        we,
  input  logic [31:0] a,
  input  logic [31:0] wd,
  output logic [31:0] rd,
  // Nueva entrada para cargar
  input  logic        load_en,
  // Salidas
  output logic [31:0] result_suma,
  output logic [31:0] result_resta,
  output logic [31:0] result_mult,
  output logic [31:0] result_div,
  output logic [31:0] result_pow
);

  logic [31:0] RAM[63:0];
  
  initial $readmemh("C:/Users/Usuario/Desktop/TEC II 2025/Taller_DD/Proyecto_Final/echavarria_ffuchs_mvalverde_mgudino_digital_design_finalproject_2025/dmem_init.dat", RAM);
  
  assign rd = RAM[a[7:2]];
  
  always_ff @(posedge clk) begin
    // Escritura del ARM (normal)
    if (we)
      RAM[a[7:2]] <= wd;
    
    // Cuando presionas el switch, carga valores quemados
    if (load_en) begin
      RAM[0] <= 32'd10;    // Carga 10 en RAM[0]
      RAM[1] <= 32'd5;     // Carga 5 en RAM[1]
    end
  end

  assign result_suma  = RAM[2];
  assign result_resta = RAM[3];
  assign result_mult  = RAM[4];
  assign result_div   = RAM[5];
  assign result_pow   = RAM[6];

endmodule