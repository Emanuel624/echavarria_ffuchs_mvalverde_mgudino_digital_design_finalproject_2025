
module flopenr #(
  parameter WIDTH = 8
)(
  input  logic              clk,
  input  logic              reset,
  input  logic              en,
  input  logic [WIDTH-1:0]  d,
  output logic [WIDTH-1:0]  q
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset)      q <= '0;   // limpia a 0 (ancho WIDTH)
    else if (en)    q <= d;    // carga cuando enable=1
    // else: mantiene valor
  end
endmodule
