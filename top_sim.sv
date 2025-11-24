`timescale 1ps / 1ps

// =========================================================
// TOP BÁSICO - Sin periféricos
// Procesador + Memoria Interna (imem y dmem)
// CORREGIDO: imem NO necesita clk (lectura combinacional)
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
  // MEMORIA DE INSTRUCCIONES (INTERNA)
  // CAMBIO: Removido .clk(clk) porque imem es combinacional
  // =====================================================
  imem imem (
    .a(PC),
    .rd(Instr)
  );

  // =====================================================
  // MEMORIA DE DATOS (INTERNA)
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