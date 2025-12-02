module dmem (
  input  logic        clk,
  input  logic        we,
  input  logic [31:0] a,
  input  logic [31:0] wd,
  output logic [31:0] rd,

  // Entradas originales
  input  logic        load_en,
  input  logic        reset_en,

  // NUEVAS entradas desde la calculadora
  input  logic        calc_store_en,   // 1 ciclo cuando se presiona el botón EVALUATE
  input  logic [31:0] calc_a,          // operando A (desde switches, extendido a 32 bits)
  input  logic [31:0] calc_b,          // operando B
  input  logic [2:0]  calc_op,         // código de operación (0=+,1=-,2=*,3=/,4=pow)

  // Salidas de resultados (calculados por el CPU y guardados en la RAM)
  output logic [31:0] result_suma,
  output logic [31:0] result_resta,
  output logic [31:0] result_mult,
  output logic [31:0] result_div,
  output logic [31:0] result_pow
);

  logic [31:0] RAM[63:0];
  
  initial $readmemh("C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/echavarria_ffuchs_mvalverde_mgudino_digital_design_finalproject_2025/dmem_init.dat",RAM);
  
  // Lectura normal (ARM)
  assign rd = RAM[a[7:2]];

  always_ff @(posedge clk) begin
    // RESET: limpia operandos (y puedes limpiar más direcciones si quieres)
    if (reset_en) begin
      RAM[0] <= 32'd0;   // A
      RAM[1] <= 32'd0;   // B
      RAM[7] <= 32'd0;   // op
    end
    else begin
      // Escritura normal del ARM
      if (we)
        RAM[a[7:2]] <= wd;
      
      // Carga "manual" antigua (si aún quieres tener un botón LOAD por hardware)
      if (load_en) begin
        RAM[0] <= 32'd10;
        RAM[1] <= 32'd5;
      end

      // NUEVO: cuando la calculadora quiere evaluar, guarda A, B y op en la RAM
      if (calc_store_en) begin
        RAM[0] <= calc_a;                       // Operando A
        RAM[1] <= calc_b;                       // Operando B
        RAM[7] <= {29'd0, calc_op};            // Guardamos op en RAM[7] (solo 3 bits útiles)
      end
    end
  end

  // Los resultados los escribe el programa del ARM en estas direcciones:
  //  RAM[2] → suma, RAM[3] → resta, RAM[4] → mult, RAM[5] → div, RAM[6] → pow
  assign result_suma  = RAM[2];
  assign result_resta = RAM[3];
  assign result_mult  = RAM[4];
  assign result_div   = RAM[5];
  assign result_pow   = RAM[6];

endmodule
