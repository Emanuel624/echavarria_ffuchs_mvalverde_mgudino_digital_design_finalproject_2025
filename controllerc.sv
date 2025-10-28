
module controllerc (
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] Instr,      // pasa la instrucción completa
  input  logic [3:0]  ALUFlags,

  output logic [1:0]  RegSrc,
  output logic        RegWrite,
  output logic [1:0]  ImmSrc,
  output logic        ALUSrc,
  output logic [1:0]  ALUControl,
  output logic        MemWrite,
  output logic        MemtoReg,
  output logic        PCSrc
);

  logic [1:0] FlagW;
  logic       PCS, RegW, MemW;

  // Decoder principal (usa campos de Instr)
  decoderdec u_decoderdec (
    Instr[27:26],      // Op
    Instr[25:20],      // Funct
    Instr[15:12],      // Rd[15:12]
    FlagW, PCS, RegW, MemW,
    MemtoReg, ALUSrc, ImmSrc, RegSrc, ALUControl
  );

  // Lógica de condición (tu archivo define 'condlogic')
  condlogic u_condlogic (
    clk, reset,
    Instr[31:28],      // Cond
    ALUFlags,
    FlagW, PCS, RegW, MemW,
    PCSrc, RegWrite, MemWrite
  );

endmodule

