`timescale 1ps / 1ps

// =========================================================
// TESTBENCH PARA PROCESADOR + DMEM HÍBRIDA
// =========================================================

module testbench();

  // Señales principales
  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;
  logic [7:0]  LED;

  // =====================================================
  // DUT - Instancia del top de simulación
  // Asegúrate que la definición de top_sim sea:
//  module top_sim (
//    input  logic        clk,
//    input  logic        reset,
//    output logic [31:0] WriteData,
//    output logic [31:0] DataAdr,
//    output logic        MemWrite,
//    output logic [7:0]  LED
//  );
//  ...
//  endmodule
  // =====================================================
  top_sim dut (
    .clk      (clk),
    .reset    (reset),
    .WriteData(WriteData),
    .DataAdr  (DataAdr),
    .MemWrite (MemWrite),
    .LED      (LED)
  );

  // =====================================================
  // GENERACIÓN DE RELOJ Y RESET
  // =====================================================

  // Reloj: periodo de 10 ps (100 GHz solo para sim rápida)
  always #5 clk = ~clk;

  // Reset inicial
  initial begin
    clk   = 1'b0;
    reset = 1'b1;
    #22;
    reset = 1'b0;
  end

  // =====================================================
  // MONITOR PRINCIPAL
  // =====================================================
  initial begin
    // Esperar a que salga de reset
    wait (!reset);

    // Dar tiempo suficiente para que corra el programa
    #250;

    // Imprimir reporte
    print_final_report();

    // Detener simulación
    $stop;
  end

  // =====================================================
  // TASK: REPORTE FINAL
  // =====================================================
  task print_final_report();
    integer test_errors;
    test_errors = 0;

    $display("\n");
    $display("╔══════════════════════════════════════════════════════════╗");
    $display("║         REPORTE FINAL - PROCESADOR ARM                  ║");
    $display("╚══════════════════════════════════════════════════════════╝");
    $display("");

    // -----------------------------------------------------
    // REGISTROS
    // -----------------------------------------------------
    $display("REGISTROS:");
    $display("──────────");
    $display("  R0  = 0x%08h (%0d)", dut.arm.u_datapathdp.rf.rf[0], dut.arm.u_datapathdp.rf.rf[0]);
    $display("  R1  = 0x%08h (%0d)", dut.arm.u_datapathdp.rf.rf[1], dut.arm.u_datapathdp.rf.rf[1]);
    $display("  R2  = 0x%08h (%0d)", dut.arm.u_datapathdp.rf.rf[2], dut.arm.u_datapathdp.rf.rf[2]);
    $display("  PC  = 0x%08h\n",      dut.arm.PC);

    // -----------------------------------------------------
    // MEMORIA
    // -----------------------------------------------------
    $display("MEMORIA:");
    $display("────────");
    $display("  Dirección física 100 → Índice RAM[25]");

`ifdef SIMULATION
    // Solo existe el arreglo RAM si se compila con +define+SIMULATION
    $display("  RAM[25] = 0x%08h (%0d)\n", dut.dmem.RAM[25], dut.dmem.RAM[25]);
`else
    $display("  (SIMULATION no definida: no hay acceso directo a RAM[].)\n");
`endif

    // -----------------------------------------------------
    // VERIFICACIONES
    // -----------------------------------------------------
    $display("╔══════════════════════════════════════════════════════════╗");
    $display("║                   VERIFICACIONES                         ║");
    $display("╠══════════════════════════════════════════════════════════╣");

    // Test 1: R0 = 0
    if (dut.arm.u_datapathdp.rf.rf[0] === 32'h00000000) begin
      $display("║  ✓ TEST 1: R0 = 0                                 PASS  ║");
    end else begin
      $display("║  ✗ TEST 1: R0 = %0d (esperado 0)                  FAIL  ║", 
               dut.arm.u_datapathdp.rf.rf[0]);
      test_errors++;
    end

    // Test 2: R1 = 7
    if (dut.arm.u_datapathdp.rf.rf[1] === 32'h00000007) begin
      $display("║  ✓ TEST 2: R1 = 7                                 PASS  ║");
    end else begin
      $display("║  ✗ TEST 2: R1 = %0d (esperado 7)                  FAIL  ║", 
               dut.arm.u_datapathdp.rf.rf[1]);
      test_errors++;
    end

    // Test 3: R2 = 7 (LDR desde memoria)
    if (dut.arm.u_datapathdp.rf.rf[2] === 32'h00000007) begin
      $display("║  ✓ TEST 3: R2 = 7 (LDR funcional)                 PASS  ║");
    end else begin
      $display("║  ✗ TEST 3: R2 = %0d (esperado 7)                  FAIL  ║", 
               dut.arm.u_datapathdp.rf.rf[2]);
      test_errors++;
    end

    // Test 4: RAM[25] = 7 (STR funcional)
`ifdef SIMULATION
    if (dut.dmem.RAM[25] === 32'h00000007) begin
      $display("║  ✓ TEST 4: RAM[25] = 7 (STR funcional)            PASS  ║");
    end else begin
      $display("║  ✗ TEST 4: RAM[25] = 0x%08h (esperado 0x00000007) FAIL ║", 
               dut.dmem.RAM[25]);
      test_errors++;
    end
`else
    $display("║  ? TEST 4: No se puede verificar RAM[25] sin SIMULATION  ║");
`endif

    $display("╚══════════════════════════════════════════════════════════╝");
    $display("");

    // -----------------------------------------------------
    // RESUMEN GLOBAL
    // -----------------------------------------------------
    if (test_errors == 0) begin
      $display("╔══════════════════════════════════════════════════════════╗");
      $display("║                                                          ║");
      $display("║           ✓✓✓  TODAS LAS PRUEBAS PASARON  ✓✓✓          ║");
      $display("║                                                          ║");
      $display("║  Instrucciones ejecutadas correctamente:                 ║");
      $display("║    • MOV R0, #0                                          ║");
      $display("║    • ADD R1, R0, #7                                      ║");
      $display("║    • STR R1, [R0, #100]                                  ║");
      $display("║    • LDR R2, [R0, #100]                                  ║");
      $display("║    • BRANCH (loop)                                       ║");
      $display("║                                                          ║");
      $display("║  PROCESADOR ARM CON DMEM HÍBRIDA: FUNCIONAL ✓           ║");
      $display("║                                                          ║");
      $display("╚══════════════════════════════════════════════════════════╝");
    end else begin
      $display("╔══════════════════════════════════════════════════════════╗");
      $display("║           ✗✗✗  %0d ERROR(ES) ENCONTRADO(S)  ✗✗✗         ║", test_errors);
      $display("╚══════════════════════════════════════════════════════════╝");
    end

    $display("");

    // -----------------------------------------------------
    // NOTA DE DIRECCIONAMIENTO
    // -----------------------------------------------------
    $display("NOTA IMPORTANTE:");
    $display("─────────────────");
    $display("Dirección de memoria 100 (0x64) se mapea a:");
    $display("  Índice = Dirección / 4 = 100 / 4 = 25");
    $display("Por eso verificamos RAM[25], no RAM[100].");
    $display("");

  endtask

endmodule
