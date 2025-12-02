module result_selector (
  input  logic [2:0]  selector,    // SW[2:0]: 000=SUMA, 001=RESTA, 010=MULT, 011=DIV, 100=POW
  input  logic [31:0] suma,        // RAM[2]
  input  logic [31:0] resta,       // RAM[3]
  input  logic [31:0] mult,        // RAM[4]
  input  logic [31:0] div_result,  // RAM[5]
  input  logic [31:0] pow_result,  // RAM[6]
  output logic [31:0] result
);

  always_comb begin
    case(selector)
      3'b000: result = suma;        // SUMA
      3'b001: result = resta;       // RESTA
      3'b010: result = mult;        // MULTIPLICACIÓN
      3'b011: result = div_result;  // DIVISIÓN
      3'b100: result = pow_result;  // POTENCIA
      default: result = 32'b0;
    endcase
  end

endmodule