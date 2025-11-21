`timescale 1ps / 1ps

// =========================================================
// TOP BÁSICO - Sin periféricos
// Solo procesador + ROM + RAM para verificar ejecución
// =========================================================

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
  // PROCESADOR ARM
  // =====================================================
  arm arm (
    .clk(clk),
    .reset(reset),
    .PC(PC),
    .Instr(Instr),
    .MemWrite(MemWrite),
    .ALUResult(ALUResult),
    .WriteData(WriteData),
    .ReadData(ReadData)
  );

  // =====================================================
  // MEMORIA DE INSTRUCCIONES (ROM)
  // =====================================================
  imem imem (
    .clk(clk),
    .a(PC),
    .rd(Instr)
  );

  // =====================================================
  // MEMORIA DE DATOS (RAM)
  // =====================================================
  dmem dmem (
    .clk(clk),
    .we(MemWrite),
    .a(ALUResult),
    .wd(WriteData),
    .rd(ReadData)
  );

  // =====================================================
  // SALIDAS
  // =====================================================
  assign DataAdr = ALUResult;
  assign LED = Instr[7:0];

endmodule