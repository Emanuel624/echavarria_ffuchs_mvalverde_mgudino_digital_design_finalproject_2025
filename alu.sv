module alu (
  input  logic [31:0] A,
  input  logic [31:0] B,
  input  logic [2:0]  ALUControl,   // 000=ADD, 001=SUB, 010=AND, 011=ORR, 100=MUL, 101=DIV
  output logic [31:0] Result,
  output logic [3:0]  ALUFlags      // {N,Z,C,V}
);
  // Internos
  logic [31:0] sum_add, sum_sub;
  logic        c_add, c_sub;
  logic        n, z, c, v;

  // ADD (A + B)
  logic [32:0] add33;
  assign add33   = {1'b0, A} + {1'b0, B};
  assign sum_add = add33[31:0];
  assign c_add   = add33[32];  // carry-out

  // SUB (A - B) = A + (~B) + 1
  logic [32:0] sub33;
  assign sub33   = {1'b0, A} + {1'b0, ~B} + 33'd1;
  assign sum_sub = sub33[31:0];
  assign c_sub   = sub33[32];  // en ARM, C = NOT borrow = carry-out de esta suma

  // MUL (A * B) - resultado de 32 bits (los bajos)
  logic [63:0] mul64;
  assign mul64   = A * B;

  // DIV (A / B) - división sin signo
  logic [31:0] div_result;
  assign div_result = (B != 32'b0) ? (A / B) : 32'b0;  // protección contra división por cero

  // Resultado según operación
  always_comb begin
    unique case (ALUControl)
      3'b000: Result = sum_add;        // ADD
      3'b001: Result = sum_sub;        // SUB
      3'b010: Result = (A & B);        // AND
      3'b011: Result = (A | B);        // ORR
      3'b100: Result = mul64[31:0];    // MUL (32 bits bajos)
      3'b101: Result = div_result;     // DIV
      default: Result = 32'b0;
    endcase
  end

  // Flags
  // N: bit 31 del resultado
  // Z: resultado == 0
  // C,V: dependen de la operación (para AND/ORR/MUL/DIV se ponen 0)
  always_comb begin
    n = Result[31];
    z = (Result == 32'b0);

    unique case (ALUControl)
      3'b000: begin // ADD
        c = c_add;
        v = (A[31] == B[31]) && (Result[31] != A[31]);
      end
      3'b001: begin // SUB
        c = c_sub;
        v = (A[31] != B[31]) && (Result[31] != A[31]);
      end
      default: begin // AND / ORR / MUL / DIV
        c = 1'b0;
        v = 1'b0;
      end
    endcase
  end

  assign ALUFlags = {n, z, c, v};

endmodule