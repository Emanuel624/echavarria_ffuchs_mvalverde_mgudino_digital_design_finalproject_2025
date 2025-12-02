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
    $display("   • Operando 1: 3");
    $display("   • Operando 2: 2\n");
    
    print_program_info();
    
    // Esperar a que se ejecuten todas las operaciones
    #20000;
    
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
    
    repeat(100) begin
      @(posedge clk);
      if (!reset) begin
        cycle++;
        if (cycle <= 100) begin
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
    $display("   ➕ SUMA:           3 + 2 = 5");
    $display("   ➖ RESTA:          3 - 2 = 1");
    $display("   ✖️  MULTIPLICACIÓN: 3 × 2 = 6");
    $display("   ➗ DIVISIÓN:        3 ÷ 2 = 1");
    $display("   ⬆️  POTENCIA:        3 ^ 2 = 9\n");
  endtask

  task print_verification_results();
    logic [31:0] r1, r2, r3, r4, r5, r6, r7, r8;
    logic [31:0] ram0, ram1, ram2, ram3, ram4, ram5, ram6;
    integer suma_ok, resta_ok, mult_ok, div_ok, pow_ok;
    
    print_separator();
    $display("\n🔍 VERIFICACIÓN DE RESULTADOS:\n");
    
    // Leer registros
    r1 = dut.arm.u_datapathdp.rf.rf[1];
    r2 = dut.arm.u_datapathdp.rf.rf[2];
    r3 = dut.arm.u_datapathdp.rf.rf[3];
    r4 = dut.arm.u_datapathdp.rf.rf[4];
    r5 = dut.arm.u_datapathdp.rf.rf[5];
    r6 = dut.arm.u_datapathdp.rf.rf[6];
    r7 = dut.arm.u_datapathdp.rf.rf[7];
    r8 = dut.arm.u_datapathdp.rf.rf[8];
    
    // Leer valores de dmem
    ram0 = dut.dmem.RAM[0];
    ram1 = dut.dmem.RAM[1];
    ram2 = dut.dmem.RAM[2];
    ram3 = dut.dmem.RAM[3];
    ram4 = dut.dmem.RAM[4];
    ram5 = dut.dmem.RAM[5];
    ram6 = dut.dmem.RAM[6];
    
    // Verificar operaciones
    suma_ok  = (ram2 === 32'd5) ? 1 : 0;
    resta_ok = (ram3 === 32'd1) ? 1 : 0;
    mult_ok  = (ram4 === 32'd6) ? 1 : 0;
    div_ok   = (ram5 === 32'd1) ? 1 : 0;
    pow_ok   = (ram6 === 32'd9) ? 1 : 0;
    
    $display("📌 VALORES EN REGISTROS:");
    $display("   R1 = %d (esperado: 3) %s", r1, (r1 === 32'd3) ? "✅ OK" : "❌ FAIL");
    $display("   R2 = %d (esperado: 2) %s", r2, (r2 === 32'd2) ? "✅ OK" : "❌ FAIL");
    $display("   R3 = %d (esperado: 5) %s", r3, (r3 === 32'd5) ? "✅ OK" : "❌ FAIL");
    $display("   R4 = %d (esperado: 1) %s", r4, (r4 === 32'd1) ? "✅ OK" : "❌ FAIL");
    $display("   R5 = %d (esperado: 6) %s", r5, (r5 === 32'd6) ? "✅ OK" : "❌ FAIL");
    $display("   R6 = %d (esperado: 1) %s", r6, (r6 === 32'd1) ? "✅ OK" : "❌ FAIL");
    $display("   R8 = %d (esperado: 9) %s\n", r8, (r8 === 32'd9) ? "✅ OK" : "❌ FAIL");
    
    $display("📌 VALORES EN MEMORIA (dmem):");
    $display("   RAM[0] = %d (operando 1: 3)", ram0);
    $display("   RAM[1] = %d (operando 2: 2)", ram1);
    $display("   ➕ RAM[2] (SUMA)           = %d (esperado: 5) %s", ram2, suma_ok ? "✅ OK" : "❌ FAIL");
    $display("   ➖ RAM[3] (RESTA)          = %d (esperado: 1) %s", ram3, resta_ok ? "✅ OK" : "❌ FAIL");
    $display("   ✖️  RAM[4] (MULTIPLICACIÓN) = %d (esperado: 6) %s", ram4, mult_ok ? "✅ OK" : "❌ FAIL");
    $display("   ➗ RAM[5] (DIVISIÓN)       = %d (esperado: 1) %s", ram5, div_ok ? "✅ OK" : "❌ FAIL");
    $display("   ⬆️  RAM[6] (POTENCIA)      = %d (esperado: 9) %s\n", ram6, pow_ok ? "✅ OK" : "❌ FAIL");
    
    print_separator();
    $display("\n📊 REPORTE FINAL:\n");
    
    if (suma_ok && resta_ok && mult_ok && div_ok && pow_ok) begin
      $display("   ✅✅✅✅✅ TODAS LAS OPERACIONES CORRECTAS ✅✅✅✅✅");
      $display("   ✅ Suma correcta         (3 + 2 = 5)");
      $display("   ✅ Resta correcta        (3 - 2 = 1)");
      $display("   ✅ Multiplicación correcta (3 × 2 = 6)");
      $display("   ✅ División correcta     (3 ÷ 2 = 1)");
      $display("   ✅ Potencia correcta     (3 ^ 2 = 9)\n");
    end else begin
      $display("   ❌ ALGUNAS OPERACIONES FALLARON\n");
      if (!suma_ok)  $display("   ❌ Suma: esperado 5, obtenido %d\n", ram2);
      if (!resta_ok) $display("   ❌ Resta: esperado 1, obtenido %d\n", ram3);
      if (!mult_ok)  $display("   ❌ Multiplicación: esperado 6, obtenido %d\n", ram4);
      if (!div_ok)   $display("   ❌ División: esperado 1, obtenido %d\n", ram5);
      if (!pow_ok)   $display("   ❌ Potencia: esperado 9, obtenido %d\n", ram6);
    end
    
    $display("   Ciclos ejecutados: %d\n", cycle);
    
  endtask

endmodule