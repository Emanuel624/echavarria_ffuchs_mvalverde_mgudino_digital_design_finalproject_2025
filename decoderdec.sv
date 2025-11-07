
module decoderdec (
  input  logic [1:0] Op,
  input  logic [5:0] Funct,
  input  logic [3:0] Rd,
  output logic [1:0] FlagW,
  output logic       PCS, RegW, MemW,
  output logic       MemtoReg, ALUSrc,
  output logic [1:0] ImmSrc, RegSrc, ALUControl
);

  logic [9:0] controls;
  logic       Branch, ALUOp;

  // -----------------------
  // Decoder
  // -----------------------
  always_comb begin
    // valor por defecto 
    controls = 10'b0000000000;

    // Op[1:0] con don't-cares permitidos
    casex (Op)
      // Data-processing (immediate vs register) según Funct[5]
      2'b00: begin
        if (Funct[5]) controls = 10'b0000101001;  // DP imm
        else          controls = 10'b0000001001;  // DP reg
      end

      // LDR/STR diferenciado por Funct[0]
      2'b01: begin
        if (Funct[0]) controls = 10'b0001111000;  // LDR
        else          controls = 10'b1001110100;  // STR
      end

      // B (branch)
      2'b10: begin
        controls = 10'b0110100010;
      end

      // Default
      default: begin
        controls = 10'b0000000000; // 10'bxxxxxxxxxx para sim-only
      end
    endcase
  end

  // Desempaquetado de la palabra de control
  // {RegSrc[1:0], ImmSrc[1:0], ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp}
  assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

  // -----------------------
  // ALU Decoder
  // -----------------------
  always_comb begin
    // valores por defecto
    ALUControl = 2'b00;     // ADD por defecto
    FlagW      = 2'b00;    

    if (ALUOp) begin
      // Cuál DP instruction?
      unique case (Funct[4:1])
        4'b0100: ALUControl = 2'b00; // ADD
        4'b0010: ALUControl = 2'b01; // SUB
        4'b0000: ALUControl = 2'b10; // AND
        4'b1100: ALUControl = 2'b11; // ORR
        default: ALUControl = 2'b00; // por seguridad
      endcase

      // Actualización de flags si S bit está en 1
      // (C & V solo para aritméticas ADD/SUB, distinguir ALUControl)
      FlagW[1] = Funct[0]; // NZ
      FlagW[0] = Funct[0] & ((ALUControl == 2'b00) || (ALUControl == 2'b01)); // CV
    end
  end

  // -----------------------
  // PC Sourcing Logic
  // -----------------------
  assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

endmodule
