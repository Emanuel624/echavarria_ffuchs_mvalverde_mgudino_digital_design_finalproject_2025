module top (
  input  logic        clk,
  input  logic        reset,
  input  logic [2:0]  SW,          // Switches para seleccionar operación
  output logic [31:0] WriteData,
  output logic [31:0] DataAdr,
  output logic        MemWrite,
  output logic [9:0]  LED          // 10 LEDs para mostrar en binario
);
  logic [31:0] PC, Instr, ReadData, ALUResult;
  
  // Señales para display
  logic [31:0] selected_result;
  logic [31:0] suma, resta, mult, div_result, pow_result;

  // =====================================================
  // INSTANCIA DEL PROCESADOR ARM
  // =====================================================
  arm arm_inst (
    .clk(clk), 
    .reset(reset), 
    .PC(PC), 
    .Instr(Instr), 
    .MemWrite(MemWrite), 
    .ALUResult(ALUResult), 
    .WriteData(WriteData), 
    .ReadData(ReadData)
  );
  
  imem imem (PC, Instr);
  dmem dmem (
    .clk(clk), 
    .we(MemWrite), 
    .a(ALUResult), 
    .wd(WriteData), 
    .rd(ReadData),
    .result_suma(suma),
    .result_resta(resta),
    .result_mult(mult),
    .result_div(div_result),
    .result_pow(pow_result)
  );

  // =====================================================
  // LÓGICA DE DISPLAY EN LEDs BINARIOS
  // =====================================================
  // Selector: qué resultado mostrar basado en switches
  result_selector selector (
    .selector(SW),
    .suma(suma),
    .resta(resta),
    .mult(mult),
    .div_result(div_result),
    .pow_result(pow_result),
    .result(selected_result)
  );

  // Mostrar resultado en binario en los 10 LEDs
  // LED[9:0] = bits del resultado [9:0]
  assign LED = selected_result[9:0];

  // =====================================================
  // SALIDAS
  // =====================================================
  assign DataAdr = ALUResult;

endmodule