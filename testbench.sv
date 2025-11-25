`timescale 1ps / 1ps

module testbench();

  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;
  logic [7:0]  LED;
  
  logic [31:0] PC, Instr, ALUResult, ReadData;
  integer      cycle = 0;

  top_sim dut (
    .clk      (clk),
    .reset    (reset),
    .WriteData(WriteData),
    .DataAdr  (DataAdr),
    .MemWrite (MemWrite),
    .LED      (LED)
  );

  assign PC = dut.arm.PC;
  assign Instr = dut.Instr;
  assign ALUResult = dut.ALUResult;
  assign ReadData = dut.ReadData;

  always #5 clk = ~clk;

  initial begin
    clk   = 1'b0;
    reset = 1'b1;
    #22;
    reset = 1'b0;
  end

  initial begin
    wait (!reset);
    
    print_header("ARM: SUMA, RESTA, MULTIPLICACIÓN Y DIVISIÓN");
    print_separator();
    
    $display("\n📋 INFORMACIÓN DEL PROGRAMA:");
    $display("   • Operando 1: 10");
    $display("   • Operando 2: 3\n");
    
    print_program_info();
    
    // Esperar a que se ejecuten todas las operaciones
    #15000;
    
    print_verification_results();
    
    $display("\n");
    print_separator();
    $display("\n✅ Prueba completada\n");
    $stop;
  end

  initial begin
    wait (!reset);
    $display("\n📊 MONITOR DE EJECUCIÓN:");
    $display("─────────────────────────────────────────────────────────────");
    $display("Cycle │  PC (hex)  │ Instr (hex) │ MemWrite │ ALU Result");
    $display("─────────────────────────────────────────────────────────────");
    
    repeat(70) begin
      @(posedge clk);
      if (!reset) begin
        cycle++;
        if (cycle <= 70) begin
          $display("%5d │  0x%08h │ 0x%08h │    %b    │ 0x%08h",
                   cycle, PC, Instr, MemWrite, ALUResult);
        end
      end
    end
  end

  task print_header(string title);
    $display("\n");
    $display("╔════════════════════════════════════════════════════════════╗");
    $display("║ %s", title);
    $display("╚════════════════════════════════════════════════════════════╝");
  endtask

  task print_separator();
    $display("────────────────────────────────────────────────────────────────");
  endtask

  task print_program_info();
    $display("\n📝 OPERACIONES A REALIZAR:");
    $display("   ➕ SUMA:           10 + 3 = 13");
    $display("   ➖ RESTA:          10 - 3 = 7");
    $display("   ✖️  MULTIPLICACIÓN: 10 × 3 = 30");
    $display("   ➗ DIVISIÓN:        10 ÷ 3 = 3\n");
  endtask

  task print_verification_results();
    logic [31:0] r1, r2, r3, r4, r5, r6;
    logic [31:0] ram0, ram1, ram2, ram3, ram4, ram5;
    integer suma_ok, resta_ok, mult_ok, div_ok;
    
    print_separator();
    $display("\n🔍 VERIFICACIÓN DE RESULTADOS:\n");
    
    // Leer registros
    r1 = dut.arm.u_datapathdp.rf.rf[1];
    r2 = dut.arm.u_datapathdp.rf.rf[2];
    r3 = dut.arm.u_datapathdp.rf.rf[3];
    r4 = dut.arm.u_datapathdp.rf.rf[4];
    r5 = dut.arm.u_datapathdp.rf.rf[5];
    r6 = dut.arm.u_datapathdp.rf.rf[6];
    
    // Leer valores de dmem
    ram0 = dut.dmem.RAM[0];
    ram1 = dut.dmem.RAM[1];
    ram2 = dut.dmem.RAM[2];
    ram3 = dut.dmem.RAM[3];
    ram4 = dut.dmem.RAM[4];
    ram5 = dut.dmem.RAM[5];
    
    // Verificar operaciones
    suma_ok  = (ram2 === 32'd13) ? 1 : 0;
    resta_ok = (ram3 === 32'd7) ? 1 : 0;
    mult_ok  = (ram4 === 32'd30) ? 1 : 0;
    div_ok   = (ram5 === 32'd3) ? 1 : 0;
    
    $display("📌 VALORES EN REGISTROS:");
    $display("   R1 = %d (esperado: 10) %s", r1, (r1 === 32'd10) ? "✅ OK" : "❌ FAIL");
    $display("   R2 = %d (esperado: 3) %s", r2, (r2 === 32'd3) ? "✅ OK" : "❌ FAIL");
    $display("   R3 = %d (esperado: 13) %s", r3, (r3 === 32'd13) ? "✅ OK" : "❌ FAIL");
    $display("   R4 = %d (esperado: 7) %s", r4, (r4 === 32'd7) ? "✅ OK" : "❌ FAIL");
    $display("   R5 = %d (esperado: 30) %s", r5, (r5 === 32'd30) ? "✅ OK" : "❌ FAIL");
    $display("   R6 = %d (esperado: 3) %s\n", r6, (r6 === 32'd3) ? "✅ OK" : "❌ FAIL");
    
    $display("📌 VALORES EN MEMORIA (dmem):");
    $display("   RAM[0] = %d (operando 1: 10)", ram0);
    $display("   RAM[1] = %d (operando 2: 3)", ram1);
    $display("   ➕ RAM[2] (SUMA)           = %d (esperado: 13) %s", ram2, suma_ok ? "✅ OK" : "❌ FAIL");
    $display("   ➖ RAM[3] (RESTA)          = %d (esperado: 7) %s", ram3, resta_ok ? "✅ OK" : "❌ FAIL");
    $display("   ✖️  RAM[4] (MULTIPLICACIÓN) = %d (esperado: 30) %s", ram4, mult_ok ? "✅ OK" : "❌ FAIL");
    $display("   ➗ RAM[5] (DIVISIÓN)       = %d (esperado: 3) %s\n", ram5, div_ok ? "✅ OK" : "❌ FAIL");
    
    print_separator();
    $display("\n📊 REPORTE FINAL:\n");
    
    if (suma_ok && resta_ok && mult_ok && div_ok) begin
      $display("   ✅✅✅✅ TODAS LAS OPERACIONES CORRECTAS ✅✅✅✅");
      $display("   ✅ Suma correcta         (10 + 3 = 13)");
      $display("   ✅ Resta correcta        (10 - 3 = 7)");
      $display("   ✅ Multiplicación correcta (10 × 3 = 30)");
      $display("   ✅ División correcta     (10 ÷ 3 = 3)\n");
    end else begin
      $display("   ❌ ALGUNAS OPERACIONES FALLARON\n");
      if (!suma_ok)  $display("   ❌ Suma: esperado 13, obtenido %d\n", ram2);
      if (!resta_ok) $display("   ❌ Resta: esperado 7, obtenido %d\n", ram3);
      if (!mult_ok)  $display("   ❌ Multiplicación: esperado 30, obtenido %d\n", ram4);
      if (!div_ok)   $display("   ❌ División: esperado 3, obtenido %d\n", ram5);
    end
    
    $display("   Ciclos ejecutados: %d\n", cycle);
    
  endtask

endmodule