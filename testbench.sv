`timescale 1ps / 1ps

module testbench();
  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;
  logic [7:0]  LED;

  // DUT - Instancia top_sim
  top_sim dut (clk, reset, WriteData, DataAdr, MemWrite, LED);

  // =====================================================
  // INICIALIZACION
  // =====================================================
  initial begin
    clk   = 1'b0;
    reset = 1'b1;
    #22;
    reset = 1'b0;
  end

  always #5 clk = ~clk;

  // =====================================================
  // MONITOR - Espera a que termine
  // =====================================================
  initial begin
    wait(!reset);
    #250; // Esperar suficientes ciclos
    print_final_report();
    $stop;
  end

  // =====================================================
  // REPORTE FINAL
  // =====================================================
  task print_final_report();
    integer test_errors;
    
    test_errors = 0;
    
    $display("\n");
    $display("╔══════════════════════════════════════════════════════════╗");
    $display("║         REPORTE FINAL - PROCESADOR ARM                  ║");
    $display("╚══════════════════════════════════════════════════════════╝");
    $display("");
    
    $display("REGISTROS:");
    $display("──────────");
    $display("  R0  = 0x%08h (%0d)", dut.arm.u_datapathdp.rf.rf[0], dut.arm.u_datapathdp.rf.rf[0]);
    $display("  R1  = 0x%08h (%0d)", dut.arm.u_datapathdp.rf.rf[1], dut.arm.u_datapathdp.rf.rf[1]);
    $display("  R2  = 0x%08h (%0d)", dut.arm.u_datapathdp.rf.rf[2], dut.arm.u_datapathdp.rf.rf[2]);
    $display("  PC  = 0x%08h\n", dut.arm.PC);
    
    $display("MEMORIA:");
    $display("────────");
    $display("  Dirección física 100 → Índice RAM[25]");
    $display("  RAM[25] = 0x%08h (%0d)\n", dut.dmem.RAM[25], dut.dmem.RAM[25]);
    
    // Verificaciones
    $display("╔══════════════════════════════════════════════════════════╗");
    $display("║                   VERIFICACIONES                         ║");
    $display("╠══════════════════════════════════════════════════════════╣");
    
    // Test 1: R0 = 0
    if (dut.arm.u_datapathdp.rf.rf[0] === 32'h00000000) begin
      $display("║  ✓ TEST 1: R0 = 0                                 PASS  ║");
    end else begin
      $display("║  ✗ TEST 1: R0 = %0d (esperado 0)             FAIL  ║", 
               dut.arm.u_datapathdp.rf.rf[0]);
      test_errors = test_errors + 1;
    end
    
    // Test 2: R1 = 7
    if (dut.arm.u_datapathdp.rf.rf[1] === 32'h00000007) begin
      $display("║  ✓ TEST 2: R1 = 7                                 PASS  ║");
    end else begin
      $display("║  ✗ TEST 2: R1 = %0d (esperado 7)             FAIL  ║", 
               dut.arm.u_datapathdp.rf.rf[1]);
      test_errors = test_errors + 1;
    end
    
    // Test 3: R2 = 7
    if (dut.arm.u_datapathdp.rf.rf[2] === 32'h00000007) begin
      $display("║  ✓ TEST 3: R2 = 7 (LDR funcional)                 PASS  ║");
    end else begin
      $display("║  ✗ TEST 3: R2 = %0d (esperado 7)             FAIL  ║", 
               dut.arm.u_datapathdp.rf.rf[2]);
      test_errors = test_errors + 1;
    end
    
    // Test 4: RAM[25] = 7 (dirección 100 → índice 25)
    if (dut.dmem.RAM[25] === 32'h00000007) begin
      $display("║  ✓ TEST 4: RAM[25] = 7 (STR funcional)            PASS  ║");
    end else begin
      $display("║  ✗ TEST 4: RAM[25] = %h (esperado 7)      FAIL  ║", 
               dut.dmem.RAM[25]);
      test_errors = test_errors + 1;
    end
    
    $display("╚══════════════════════════════════════════════════════════╝");
    $display("");
    
    // Resumen
    if (test_errors == 0) begin
      $display("╔══════════════════════════════════════════════════════════╗");
      $display("║                                                          ║");
      $display("║           ✓✓✓  TODAS LAS PRUEBAS PASARON  ✓✓✓          ║");
      $display("║                                                          ║");
      $display("║  Instrucciones ejecutadas correctamente:                ║");
      $display("║    • MOV R0, #0                                          ║");
      $display("║    • ADD R1, R0, #7                                      ║");
      $display("║    • STR R1, [R0, #100]                                  ║");
      $display("║    • LDR R2, [R0, #100]                                  ║");
      $display("║    • BRANCH (loop)                                       ║");
      $display("║                                                          ║");
      $display("║  PROCESADOR ARM CON ROM IP: FUNCIONAL ✓                 ║");
      $display("║                                                          ║");
      $display("╚══════════════════════════════════════════════════════════╝");
    end else begin
      $display("╔══════════════════════════════════════════════════════════╗");
      $display("║           ✗✗✗  %0d ERROR(ES) ENCONTRADO(S)  ✗✗✗         ║", test_errors);
      $display("╚══════════════════════════════════════════════════════════╝");
    end
    
    $display("");
    
    // Explicación del direccionamiento
    $display("NOTA IMPORTANTE:");
    $display("─────────────────");
    $display("Dirección de memoria 100 (0x64) se mapea a:");
    $display("  Índice = Dirección / 4 = 100 / 4 = 25");
    $display("Por eso verificamos RAM[25], no RAM[100]");
    $display("");
    
  endtask

endmodule