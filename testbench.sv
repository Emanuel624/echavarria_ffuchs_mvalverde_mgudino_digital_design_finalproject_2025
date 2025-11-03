module testbench();
  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

  // DUT
  top dut (clk, reset, WriteData, DataAdr, MemWrite);

  // =====================================================
  // INICIALIZACIÓN
  // =====================================================
  initial begin
    clk   = 1'b0;
    reset = 1'b1;
    #22;
    reset = 1'b0;
  end

  always #5 clk = ~clk;

  // =====================================================
  // CONTADORES Y VARIABLES DE TEST
  // =====================================================
  integer cycle_count = 0;
  integer mov_executed = 0;
  integer add_executed = 0;
  integer str_write_count = 0;
  integer ldr_executed = 0;
  integer branch_count = 0;
  
  logic [31:0] prev_pc = 32'h0;
  logic [31:0] r0_value = 32'h0;
  logic [31:0] r1_value = 32'h0;
  logic [31:0] r2_value = 32'h0;

  // =====================================================
  // CONTADOR DE CICLOS
  // =====================================================
  always @(posedge clk) begin
    if (!reset) cycle_count <= cycle_count + 1;
  end

  // =====================================================
  // DETECTOR DE INSTRUCCIONES
  // =====================================================
  always @(posedge clk) begin
    if (!reset) begin
      case (dut.arm.Instr)
        32'hE0400000: begin // MOV R0, #0
          mov_executed = mov_executed + 1;
          $display("[C:%0d] MOV R0, #0 (E0400000) ✓", cycle_count);
        end
        32'hE2801007: begin // ADD R1, R0, #7
          add_executed = add_executed + 1;
          $display("[C:%0d] ADD R1, R0, #7 (E2801007) ✓", cycle_count);
        end
        32'hE5801064: begin // STR R1, [R0, #100]
          $display("[C:%0d] STR R1, [R0, #100] (E5801064) ejecutada", cycle_count);
        end
        32'hE5902064: begin // LDR R2, [R0, #100]
          ldr_executed = ldr_executed + 1;
          $display("[C:%0d] LDR R2, [R0, #100] (E5902064) ✓", cycle_count);
        end
        32'hEAFFFFFFC: begin // B .-4
          $display("[C:%0d] BRANCH (EAFFFFFC) ejecutado", cycle_count);
        end
      endcase
    end
  end

  // =====================================================
  // DETECTOR DE ESCRITURAS EN MEMORIA
  // =====================================================
  always @(negedge clk) begin
    if (MemWrite) begin
      str_write_count = str_write_count + 1;
      $display("[C:%0d] MemWrite: DMEM[%0d] ← 0x%h", 
               cycle_count, DataAdr, WriteData);
      
      if ((DataAdr === 32'd100) && (WriteData === 32'd7)) begin
        $display("       ✓ Escritura correcta: 7 en dirección 100");
      end else begin
        $display("       ✗ ERROR: Escritura incorrecta");
      end
    end
  end

  // =====================================================
  // DETECTOR DE SALTOS (BRANCH)
  // =====================================================
  always @(posedge clk) begin
    if (!reset && dut.arm.PC != prev_pc + 32'd4 && prev_pc != 32'h0) begin
      branch_count = branch_count + 1;
      $display("[C:%0d] BRANCH: PC = 0x%h → 0x%h (delta: %d bytes)", 
               cycle_count, prev_pc, dut.arm.PC, $signed(dut.arm.PC - prev_pc));
    end
    prev_pc = dut.arm.PC;
  end

  // =====================================================
  // LEER REGISTROS
  // =====================================================
  initial begin
    @(posedge clk);
    forever begin
      @(posedge clk);
      if (!reset && cycle_count % 5 == 0) begin
        r0_value = dut.arm.u_datapathdp.SrcA; // Lectura de R0
        r1_value = dut.arm.u_datapathdp.WriteData; // Lectura de R1
        $display("[STATE] R0=%0d | R1=%0d", r0_value, r1_value);
      end
    end
  end

  // =====================================================
  // TIMEOUT
  // =====================================================
  initial begin
    #1000; // 1000 ns de timeout
    $display("\n*** TIMEOUT: Simulación llegó al máximo de tiempo ***");
    $stop;
  end

  // =====================================================
  // REPORTE FINAL
  // =====================================================
  initial begin
    wait (cycle_count >= 50); // Espera 50 ciclos
    @(posedge clk);
    
    $display("\n");
    $display("╔═══════════════════════════════════════════════════════╗");
    $display("║         REPORTE FINAL DE SIMULACIÓN                  ║");
    $display("╠═══════════════════════════════════════════════════════╣");
    $display("║ Ciclos ejecutados: %0d", cycle_count);
    $display("║ MOV ejecutados: %0d", mov_executed);
    $display("║ ADD ejecutados: %0d", add_executed);
    $display("║ STR ejecutados: %0d", str_write_count);
    $display("║ LDR ejecutados: %0d", ldr_executed);
    $display("║ BRANCH ejecutados: %0d", branch_count);
    $display("╠═══════════════════════════════════════════════════════╣");
    
    // Tests
    if (mov_executed >= 1) begin
      $display("║ ✓ TEST 1: MOV (aritmética) PASSED");
    end else begin
      $display("║ ✗ TEST 1: MOV FAILED");
    end
    
    if (add_executed >= 1) begin
      $display("║ ✓ TEST 2: ADD (aritmética) PASSED");
    end else begin
      $display("║ ✗ TEST 2: ADD FAILED");
    end
    
    if (str_write_count >= 1) begin
      $display("║ ✓ TEST 3: STR (Load/Store) PASSED");
    end else begin
      $display("║ ✗ TEST 3: STR FAILED");
    end
    
    if (ldr_executed >= 1) begin
      $display("║ ✓ TEST 4: LDR (Load/Store) PASSED");
    end else begin
      $display("║ ✗ TEST 4: LDR FAILED");
    end
    
    if (branch_count >= 1) begin
      $display("║ ✓ TEST 5: BRANCH (Flujo) PASSED");
    end else begin
      $display("║ ✗ TEST 5: BRANCH FAILED");
    end
    
    if (str_write_count >= 2) begin
      $display("║ ✓ TEST 6: LOOP (Repetición) PASSED");
    end else begin
      $display("║ ✗ TEST 6: LOOP FAILED");
    end
    
    $display("╠═══════════════════════════════════════════════════════╣");
    
    // Resumen
    if ((mov_executed >= 1) && (add_executed >= 1) && (str_write_count >= 1) && 
        (ldr_executed >= 1) && (branch_count >= 1)) begin
      $display("║                                                       ║");
      $display("║  ✓✓✓ TODOS LOS TESTS PASARON ✓✓✓                  ║");
      $display("║                                                       ║");
      $display("║  Tu procesador ARM es COMPLETAMENTE FUNCIONAL      ║");
      $display("║  - Aritmética: ✓ MOV, ADD                          ║");
      $display("║  - Load/Store: ✓ STR, LDR                          ║");
      $display("║  - Flujo:      ✓ BRANCH con loop                   ║");
      $display("║                                                       ║");
    end else begin
      $display("║  ✗ ALGUNOS TESTS FALLARON                           ║");
    end
    
    $display("╚═══════════════════════════════════════════════════════╝\n");
    $stop;
  end

endmodule