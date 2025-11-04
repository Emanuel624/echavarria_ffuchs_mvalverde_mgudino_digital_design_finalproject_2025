module led_controller (
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] Instr,
  input  logic [31:0] PC,
  output logic [7:0]  LED
);
  // Contadores/flags para detectar instrucciones
  logic mov_detected, add_detected, str_detected, ldr_detected, branch_detected;

  // =====================================================
  // DETECTOR DE INSTRUCCIONES (combinacional)
  // =====================================================
  always_comb begin
    mov_detected    = (Instr == 32'hE0400000);  // MOV R0, #0
    add_detected    = (Instr == 32'hE2801007);  // ADD R1, R0, #7
    str_detected    = (Instr == 32'hE5801064);  // STR R1, [R0, #100]
    ldr_detected    = (Instr == 32'hE5902064);  // LDR R2, [R0, #100]
    branch_detected = (Instr == 32'hEAFFFFFC);  // B .-4
  end

  // =====================================================
  // FLIP-FLOPS PARA LATCHEAR EL ESTADO
  // (Una vez que se ejecuta, el LED se enciende)
  // =====================================================
  logic mov_flag, add_flag, str_flag, ldr_flag, branch_flag;
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      mov_flag    <= 1'b0;
      add_flag    <= 1'b0;
      str_flag    <= 1'b0;
      ldr_flag    <= 1'b0;
      branch_flag <= 1'b0;
    end else begin
      if (mov_detected)    mov_flag    <= 1'b1;
      if (add_detected)    add_flag    <= 1'b1;
      if (str_detected)    str_flag    <= 1'b1;
      if (ldr_detected)    ldr_flag    <= 1'b1;
      if (branch_detected) branch_flag <= 1'b1;
    end
  end

  // =====================================================
  // ASIGNACIÓN A LEDs
  // =====================================================
  // LED[0]: MOV ejecutado
  // LED[1]: ADD ejecutado
  // LED[2]: STR ejecutado
  // LED[3]: LDR ejecutado
  // LED[4]: BRANCH ejecutado
  // LED[5]: El reloj mismo (parpadea al ritmo del clk que recibe)
  // LED[6-7]: No se usan
  
  assign LED[0] = mov_flag;
  assign LED[1] = add_flag;
  assign LED[2] = str_flag;
  assign LED[3] = ldr_flag;
  assign LED[4] = branch_flag;
  assign LED[5] = clk;           // Directamente el reloj que recibe
  assign LED[6] = 1'b0;          // Apagado
  assign LED[7] = 1'b0;          // Apagado

endmodule