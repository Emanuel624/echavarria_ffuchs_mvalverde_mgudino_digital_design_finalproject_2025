module testbench();
  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;
  logic [7:0]  LED;

  // DUT
  top_sim dut (clk, reset, WriteData, DataAdr, MemWrite, LED);

  // Inicialización
  initial begin
    clk   = 1'b0;
    reset = 1'b1;
    #22;
    reset = 1'b0;
  end

  always #5 clk = ~clk;

  integer cycle_count = 0;
  
  always @(posedge clk) begin
    if (!reset) cycle_count <= cycle_count + 1;
  end

  // Monitor completo con TODAS las señales de control
  always @(posedge clk) begin
    if (!reset && cycle_count > 0) begin
      $display("\n========================================");
      $display("CICLO %0d", cycle_count);
      $display("========================================");
      
      // Instrucción actual
      $display("PC     = 0x%h", dut.arm.PC);
      $display("Instr  = 0x%h", dut.arm.Instr);
      
      // Decodificar campos de instrucción
      $display("\n--- CAMPOS DE INSTRUCCION ---");
      $display("Cond[31:28]   = 0x%h (%b)", dut.arm.Instr[31:28], dut.arm.Instr[31:28]);
      $display("Op[27:26]     = 0b%b", dut.arm.Instr[27:26]);
      $display("Funct[25:20]  = 0b%b", dut.arm.Instr[25:20]);
      $display("Rn[19:16]     = R%0d", dut.arm.Instr[19:16]);
      $display("Rd[15:12]     = R%0d", dut.arm.Instr[15:12]);
      $display("Imm12[11:0]   = 0x%h (%0d)", dut.arm.Instr[11:0], dut.arm.Instr[11:0]);
      
      // Señales del decoder
      $display("\n--- SENALES DEL DECODER ---");
      $display("RegSrc    = %b", dut.arm.RegSrc);
      $display("ImmSrc    = %b", dut.arm.ImmSrc);
      $display("ALUSrc    = %b", dut.arm.ALUSrc);
      $display("MemtoReg  = %b", dut.arm.MemtoReg);
      $display("ALUControl= %b", dut.arm.ALUControl);
      
      // Señales antes de condlogic (internas del controlador)
      $display("\n--- SENALES ANTES DE CONDLOGIC ---");
      $display("RegW (antes)  = %b", dut.arm.u_controllerc.RegW);
      $display("MemW (antes)  = %b", dut.arm.u_controllerc.MemW);
      $display("PCS  (antes)  = %b", dut.arm.u_controllerc.PCS);
      
      // Señales de la lógica condicional
      $display("\n--- LOGICA CONDICIONAL ---");
      $display("Flags[NZCV]   = %b", dut.arm.u_controllerc.u_condlogic.Flags);
      $display("CondEx        = %b", dut.arm.u_controllerc.u_condlogic.CondEx);
      $display("FlagW         = %b", dut.arm.u_controllerc.FlagW);
      
      // Señales DESPUÉS de condlogic (finales)
      $display("\n--- SENALES FINALES (DESPUES DE CONDLOGIC) ---");
      $display("RegWrite      = %b", dut.arm.u_controllerc.RegWrite);
      $display("MemWrite      = %b", dut.arm.u_controllerc.MemWrite);
      $display("PCSrc         = %b", dut.arm.PCSrc);
      
      // Datapath
      $display("\n--- DATAPATH ---");
      $display("ExtImm    = 0x%h (%0d)", dut.arm.u_datapathdp.ExtImm, dut.arm.u_datapathdp.ExtImm);
      $display("SrcA      = 0x%h", dut.arm.u_datapathdp.SrcA);
      $display("SrcB      = 0x%h", dut.arm.u_datapathdp.SrcB);
      $display("ALUResult = 0x%h", dut.arm.ALUResult);
      $display("ALUFlags  = %b", dut.arm.ALUFlags);
      $display("WriteData = 0x%h (%0d)", dut.arm.WriteData, dut.arm.WriteData);
      
      // Estado de registros R0-R2
      $display("\n--- REGISTROS ---");
      $display("R0 = 0x%h", dut.arm.u_datapathdp.rf.rf[0]);
      $display("R1 = 0x%h", dut.arm.u_datapathdp.rf.rf[1]);
      $display("R2 = 0x%h", dut.arm.u_datapathdp.rf.rf[2]);
      
      // Identificar instrucción
      $display("\n--- IDENTIFICACION ---");
      case (dut.arm.Instr)
        32'hE0400000: $display(">>> MOV R0, #0");
        32'hE2801007: $display(">>> ADD R1, R0, #7");
        32'hE5801064: $display(">>> STR R1, [R0, #100]");
        32'hE5902064: $display(">>> LDR R2, [R0, #100]");
        32'hEAFFFFFC: $display(">>> BRANCH (loop infinito)");
        default: $display(">>> DESCONOCIDA");
      endcase
      
      // Si es STR o LDR, mostrar info de memoria
      if (dut.arm.Instr[27:26] == 2'b01) begin
        $display("\n--- ACCESO A MEMORIA ---");
        $display("Direccion calculada = %0d (0x%h)", DataAdr, DataAdr);
        if (dut.arm.Instr[20]) // bit L (load)
          $display("Operacion: LOAD (LDR)");
        else
          $display("Operacion: STORE (STR)");
      end
      
      // Detener en branch
      if (dut.arm.Instr == 32'hEAFFFFFC) begin
        $display("\n\n*** BRANCH DETECTADO - TERMINANDO ***\n");
        #50;
        $stop;
      end
    end
  end

  // Timeout
  initial begin
    #100000;
    $display("\n*** TIMEOUT ***");
    $stop;
  end

endmodule