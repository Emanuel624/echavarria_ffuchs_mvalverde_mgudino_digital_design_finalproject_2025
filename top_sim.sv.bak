module top_sim (
  input  logic        clk,
  input  logic        reset,
  output logic [31:0] WriteData,
  output logic [31:0] DataAdr,
  output logic        MemWrite,
  output logic [7:0]  LED
);
  logic [31:0] PC, Instr, ReadData, ALUResult;

  // =====================================================
  // Instantiate processor and memories
  // SIN DIVISOR DE RELOJ - para simulación rápida
  // =====================================================
  arm  arm  (clk, reset, PC, Instr, MemWrite, ALUResult, WriteData, ReadData);
  imem imem (PC, Instr);
  dmem dmem (clk, MemWrite, ALUResult, WriteData, ReadData);

  // Instantiate LED controller
  led_controller led_ctrl (
    .clk(clk),
    .reset(reset),
    .Instr(Instr),
    .PC(PC),
    .LED(LED)
  );

  // Asignar ALUResult a DataAdr para que el testbench pueda verlo
  assign DataAdr = ALUResult;

endmodule