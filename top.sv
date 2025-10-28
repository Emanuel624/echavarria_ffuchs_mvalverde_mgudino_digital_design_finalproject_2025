module top (
  input  logic        clk,
  input  logic        reset,
  output logic [31:0] WriteData,
  output logic [31:0] DataAdr,
  output logic        MemWrite
);
  logic [31:0] PC, Instr, ReadData, ALUResult;

  // instantiate processor and memories
  arm  arm  (clk, reset, PC, Instr, MemWrite, ALUResult, WriteData, ReadData);
  imem imem (PC, Instr);
  dmem dmem (clk, MemWrite, ALUResult, WriteData, ReadData);

  // Asignar ALUResult a DataAdr para que el testbench pueda verlo
  assign DataAdr = ALUResult;

endmodule