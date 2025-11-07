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
  // CAMBIO: Usa clk_div en lugar de clk para que sea lento
  // =====================================================
  arm  arm  (clk_div, reset, PC, Instr, MemWrite, ALUResult, WriteData, ReadData);
  imem imem (PC, Instr);
  dmem dmem (clk_div, MemWrite, ALUResult, WriteData, ReadData);

  // Instantiate LED controller
  led_controller led_ctrl (
    .clk(clk_div),      // reloj dividido
    .reset(reset),
    .Instr(Instr),
    .PC(PC),
    .LED(LED)
  );

  // Asignar ALUResult a DataAdr para que el testbench pueda verlo
  assign DataAdr = ALUResult;

endmodule