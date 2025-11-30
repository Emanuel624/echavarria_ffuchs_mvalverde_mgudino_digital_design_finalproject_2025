module arm(
  input  logic        clk, reset,
  output logic [31:0] PC,
  input  logic [31:0] Instr,
  output logic        MemWrite,
  output logic [31:0] ALUResult, WriteData,
  input  logic [31:0] ReadData,
  output logic [2:0]  ALUControl,  // Exportar para led_controller
  output logic        RegWrite     // Exportar para led_controller
);

  logic [3:0] ALUFlags;
  logic       ALUSrc, MemtoReg, PCSrc;
  logic [1:0] RegSrc, ImmSrc;

  // Control
  controllerc u_controllerc (
    clk, reset, Instr[31:12], ALUFlags,
    RegSrc, RegWrite, ImmSrc,
    ALUSrc, ALUControl,
    MemWrite, MemtoReg, PCSrc
  );

  // Datapath
  datapath u_datapathdp (
    clk, reset,
    RegSrc, RegWrite, ImmSrc,
    ALUSrc, ALUControl,
    MemtoReg, PCSrc,
    ALUFlags, PC, Instr,
    ALUResult, WriteData, ReadData
  );

endmodule