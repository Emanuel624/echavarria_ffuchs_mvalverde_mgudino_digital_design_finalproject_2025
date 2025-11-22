module arm(
  input  logic        clk, reset,
  output logic [31:0] PC,
  input  logic [31:0] Instr,
  output logic        MemWrite,
  output logic [31:0] ALUResult, WriteData,
  input  logic [31:0] ReadData
);

  logic [3:0] ALUFlags;
  logic       RegWrite, ALUSrc, MemtoReg, PCSrc;
  logic [1:0] RegSrc, ImmSrc;
  logic [2:0] ALUControl;  // ✅ CORREGIDO: [1:0] → [2:0] para MUL y DIV

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