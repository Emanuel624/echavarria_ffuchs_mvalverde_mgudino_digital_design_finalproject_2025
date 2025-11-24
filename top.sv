module top (
  input  logic        clk,
  input  logic        reset,
  output logic [31:0] WriteData,
  output logic [31:0] DataAdr,
  output logic        MemWrite,
  output logic [7:0]  LED
);
  logic [31:0] PC, Instr, ReadData, ALUResult;
  logic        clk_div;  // Reloj dividido (lento)
  
  // Señales adicionales para el led_controller
  logic [2:0] ALUControl;
  logic       RegWrite;

  // =====================================================
  // DIVISOR DE FRECUENCIA
  // =====================================================
  // Divide el reloj de 50 MHz
  // Para ver cada instrucción claramente
  // =====================================================
  logic [24:0] clk_counter;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      clk_counter <= 25'b0;
    end else begin
      clk_counter <= clk_counter + 1'b1;
    end
  end

  // Esto crea un reloj de ~1 Hz (cada instrucción tarda ~1 segundo)
  assign clk_div = clk_counter[24];

  // =====================================================
  // INSTANCIA DEL PROCESADOR ARM
  // =====================================================
  arm arm_inst (
    .clk(clk_div), 
    .reset(reset), 
    .PC(PC), 
    .Instr(Instr), 
    .MemWrite(MemWrite), 
    .ALUResult(ALUResult), 
    .WriteData(WriteData), 
    .ReadData(ReadData),
    .ALUControl(ALUControl),
    .RegWrite(RegWrite)
  );
  
  imem imem (PC, Instr);
  dmem dmem (clk_div, MemWrite, ALUResult, WriteData, ReadData);

  // =====================================================
  // INSTANCIA DEL CONTROLADOR DE LEDs
  // =====================================================
  led_controller led_ctrl (
    .clk(clk_div),           // reloj dividido
    .reset(reset),
    .Instr(Instr),
    .PC(PC),
    .ALUResult(ALUResult),   // Resultado del ALU
    .ALUControl(ALUControl), // Control del ALU (nos dice qué operación se hizo)
    .RegWrite(RegWrite),     // Flag de escritura en registro
    .LED(LED)
  );

  // Asignar ALUResult a DataAdr para que el testbench pueda verlo
  assign DataAdr = ALUResult;

endmodule