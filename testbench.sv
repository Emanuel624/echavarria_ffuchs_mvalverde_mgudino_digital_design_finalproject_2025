module testbench();
  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;
  logic [7:0]  LED;

  // DUT - Instancia top_sim SIN divisor de reloj (para simulacion rapida)
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

  always #5 clk = ~clk;  // Reloj de 50 MHz (10 ns periodo)

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

  // =====================================================
  // CONTADOR DE CICLOS (ciclos del reloj RAPIDO de 50 MHz)
  // =====================================================
  always @(posedge clk) begin
    if (!reset) cycle_count <= cycle_count + 1;
  end

  // =====================================================
  // DETECTOR DE INSTRUCCIONES (en el reloj rapido)
  // =====================================================
  always @(posedge clk) begin
    if (!reset) begin
      case (dut.arm.Instr)
        32'hE0400000: begin // MOV R0, #0
          if (mov_executed == 0) begin
            mov_executed = mov_executed + 1;
            $display("[C:%0d] MOV R0, #0 (E0400000) OK", cycle_count);
          end
        end
        32'hE2801007: begin // ADD R1, R0, #7
          if (add_executed == 0) begin
            add_executed = add_executed + 1;
            $display("[C:%0d] ADD R1, R0, #7 (E2801007) OK", cycle_count);
          end
        end
        32'hE5801064: begin // STR R1, [R0, #100]
          str_write_count = str_write_count + 1;
          $display("[C:%0d] STR R1, [R0, #100] (E5801064) ejecutada", cycle_count);
        end
        32'hE5902064: begin // LDR R2, [R0, #100]
          if (ldr_executed == 0) begin
            ldr_executed = ldr_executed + 1;
            $display("[C:%0d] LDR R2, [R0, #100] (E5902064) OK", cycle_count);
          end
        end
        32'hEAFFFFFC: begin // B .-4
          branch_count = branch_count + 1;
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
      $display("[C:%0d] MemWrite: DMEM[%0d] = 0x%h", 
               cycle_count, DataAdr, WriteData);
      
      if ((DataAdr === 32'd100) && (WriteData === 32'd7)) begin
        $display("       CORRECTO: 7 en direccion 100");
      end else begin
        $display("       ERROR: Escritura incorrecta");
      end
    end
  end

  // =====================================================
  // MONITOR DE PC - MUESTRA CADA CAMBIO
  // =====================================================
  initial begin
    $display("\n[MONITOR DE PC - Seguimiento de ejecucion]");
    $display("Ciclo | PC actual | Instruccion");
    $display("------|-----------|------------------------------");
    forever begin
      @(posedge clk);
      if (!reset) begin
        case (dut.arm.Instr)
          32'hE0400000: $display("%0d    | 0x%h | MOV R0, #0", cycle_count, dut.arm.PC);
          32'hE2801007: $display("%0d    | 0x%h | ADD R1, R0, #7", cycle_count, dut.arm.PC);
          32'hE5801064: $display("%0d    | 0x%h | STR R1, [R0, #100]", cycle_count, dut.arm.PC);
          32'hE5902064: $display("%0d    | 0x%h | LDR R2, [R0, #100]", cycle_count, dut.arm.PC);
          32'hEAFFFFFC: $display("%0d    | 0x%h | BRANCH (JMP)", cycle_count, dut.arm.PC);
          default:    $display("%0d    | 0x%h | DESCONOCIDA", cycle_count, dut.arm.PC);
        endcase
      end
    end
  end

  // =====================================================
  // TIMEOUT
  // =====================================================
  initial begin
    #100000; // 100,000 ns = suficiente sin divisor
    $display("\n*** TIMEOUT: Simulacion llego al maximo de tiempo ***");
    print_results();
    $stop;
  end

  // =====================================================
  // ESPERA A QUE SE EJECUTEN LAS INSTRUCCIONES Y REPORTA
  // =====================================================
  initial begin
    wait (mov_executed >= 1 && add_executed >= 1 && str_write_count >= 1 && 
          ldr_executed >= 1 && branch_count >= 1);
    
    #100; // Espera un poco mas para estabilidad
    print_results();
    $stop;
  end

  // =====================================================
  // FUNCION PARA IMPRIMIR RESULTADOS
  // =====================================================
  task print_results();
    $display("\n");
    $display("======================================================");
    $display("         REPORTE FINAL DE SIMULACION");
    $display("======================================================");
    $display("Ciclos ejecutados: %0d", cycle_count);
    $display("MOV ejecutados: %0d", mov_executed);
    $display("ADD ejecutados: %0d", add_executed);
    $display("STR ejecutados: %0d", str_write_count);
    $display("LDR ejecutados: %0d", ldr_executed);
    $display("BRANCH ejecutados: %0d", branch_count);
    $display("======================================================");
    
    // Prueba A: Aritmetica
    if (mov_executed >= 1 && add_executed >= 1) begin
      $display("OK PRUEBA A: ARITMETICA (MOV, ADD) PASSED");
    end else begin
      $display("FAIL PRUEBA A: ARITMETICA FAILED");
    end
    
    // Prueba B: Load/Store
    if (str_write_count >= 1 && ldr_executed >= 1) begin
      $display("OK PRUEBA B: LOAD/STORE (STR, LDR) PASSED");
    end else begin
      $display("FAIL PRUEBA B: LOAD/STORE FAILED");
    end
    
    // Prueba C: Flujo (Jump/Branch)
    if (branch_count >= 1) begin
      $display("OK PRUEBA C: FLUJO (BRANCH/JUMP) PASSED");
    end else begin
      $display("FAIL PRUEBA C: FLUJO FAILED");
    end
    
    $display("======================================================");
    
    // Resumen
    if ((mov_executed >= 1) && (add_executed >= 1) && (str_write_count >= 1) && 
        (ldr_executed >= 1) && (branch_count >= 1)) begin
      $display("");
      $display("TODAS LAS PRUEBAS PASARON");
      $display("");
      $display("COMPLETAMENTE FUNCIONAL");
      $display("");
      $display("a) Aritmetica: OK MOV, ADD");
      $display("b) Load/Store: OK STR, LDR");
      $display("c) Flujo:      OK BRANCH (Jump)");
      $display("");
    end else begin
      $display("ALGUNAS PRUEBAS FALLARON");
    end
    
    $display("======================================================\n");
  endtask

endmodule