`timescale 1ps / 1ps

module testbench();

  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;
  logic [7:0]  LED;

  top_sim dut (
    .clk      (clk),
    .reset    (reset),
    .WriteData(WriteData),
    .DataAdr  (DataAdr),
    .MemWrite (MemWrite),
    .LED      (LED)
  );

  always #5 clk = ~clk;

  initial begin
    clk   = 1'b0;
    reset = 1'b1;
    #22;
    reset = 1'b0;
  end

  initial begin
    wait (!reset);
    
    $display("\n");
    $display("╔══════════════════════════════════════════════════════════╗");
    $display("║        PRUEBA: LECTURA DE DIFERENTES PALABRAS RAM       ║");
    $display("║   Las instrucciones LDR ejecutan y leen desde RAM        ║");
    $display("╚══════════════════════════════════════════════════════════╝");
    $display("");
    
    $display("PROGRAMA QUE SE EJECUTA:");
    $display("─────────────────────────");
    $display("  MOV R0, #0      → R0 = 0");
    $display("  LDR R1, [R0]    → R1 = RAM[0] (dirección 0)");
    $display("  LDR R2, [R0, #4]   → R2 = RAM[1] (dirección 4)");
    $display("  LDR R3, [R0, #8]   → R3 = RAM[2] (dirección 8)");
    $display("  LDR R4, [R0, #12]  → R4 = RAM[3] (dirección 12)");
    $display("  LDR R5, [R0, #16]  → R5 = RAM[4] (dirección 16)");
    $display("  LDR R6, [R0, #20]  → R6 = RAM[5] (dirección 20)");
    $display("  BRANCH INFINITO");
    $display("");
    
    $display("VALORES ESPERADOS EN REGISTROS:");
    $display("─────────────────────────────────");
    $display("  R1 = 100 (0x00000064)  ← RAM[0]");
    $display("  R2 = 111 (0x0000006F)  ← RAM[1]");
    $display("  R3 = 222 (0x000000DE)  ← RAM[2]");
    $display("  R4 = 333 (0x0000014D)  ← RAM[3]");
    $display("  R5 = 444 (0x000001BC)  ← RAM[4]");
    $display("  R6 = 200 (0x000000C8)  ← RAM[5]");
    $display("");
    
    // Esperar a que termine la ejecución de las instrucciones
    #400;  // Suficiente tiempo para que se ejecuten todas las LDR
    
    $display("VALORES LEÍDOS EN REGISTROS:");
    $display("──────────────────────────────");
    
    check_register(1, 32'd100, "R1 (RAM[0])");
    check_register(2, 32'd111, "R2 (RAM[1])");
    check_register(3, 32'd222, "R3 (RAM[2])");
    check_register(4, 32'd333, "R4 (RAM[3])");
    check_register(5, 32'd444, "R5 (RAM[4])");
    check_register(6, 32'd200, "R6 (RAM[5])");
    
    $display("");
    $display("╚══════════════════════════════════════════════════════════╝");
    $display("");
    $stop;
  end
  
  task check_register(input [3:0] reg_num, input [31:0] expected, input string desc);
    logic [31:0] actual;
    actual = dut.arm.u_datapathdp.rf.rf[reg_num];
    
    $display("%s", desc);
    $display("  Actual:   0x%08h (%3d)", actual, actual);
    $display("  Esperado: 0x%08h (%3d)", expected, expected);
    
    if (actual === expected) begin
      $display("  ✓ CORRECTO");
    end else begin
      $display("  ✗ INCORRECTO - Diferencia: %d", actual - expected);
    end
    $display("");
  endtask

endmodule