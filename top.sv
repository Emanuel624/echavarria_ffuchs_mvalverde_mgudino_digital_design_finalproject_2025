module top (
  input  logic        clk,
  input  logic        reset,
  input  logic [2:0]  SW,
  input  logic        SW_LOAD,
  output logic [31:0] WriteData,
  output logic [31:0] DataAdr,
  output logic        MemWrite,
  output logic [9:0]  LED
);

  logic [31:0] PC, Instr, ReadData, ALUResult;
  logic [31:0] selected_result;
  logic [31:0] suma, resta, mult, div_result, pow_result;
  logic sw_r1, sw_r2, sw_pulse;
  logic load_en;

  // =====================================================
  // DEBOUNCE Y DETECTOR DE FLANCO
  // =====================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sw_r1 <= 1'b0;
      sw_r2 <= 1'b0;
    end else begin
      sw_r1 <= SW_LOAD;
      sw_r2 <= sw_r1;
    end
  end

  assign sw_pulse = sw_r1 & ~sw_r2;

  // =====================================================
  // ACTIVAR CARGA CUANDO DETECTA FLANCO
  // =====================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      load_en <= 1'b0;
    end else begin
      if (sw_pulse) begin
        load_en <= 1'b1;      // Se activa cuando sube el switch
      end else begin
        load_en <= 1'b0;      // Se desactiva el siguiente ciclo
      end
    end
  end

  // =====================================================
  // ARM PROCESSOR
  // =====================================================
  arm arm_inst (
    .clk(clk), .reset(reset), .PC(PC), .Instr(Instr),
    .MemWrite(MemWrite), .ALUResult(ALUResult),
    .WriteData(WriteData), .ReadData(ReadData)
  );
  
  imem imem (PC, Instr);
  
  // =====================================================
  // MEMORIA
  // =====================================================
  dmem dmem (
    .clk(clk), 
    .we(MemWrite),
    .a(ALUResult),
    .wd(WriteData),
    .rd(ReadData),
    .load_en(load_en),
    .result_suma(suma),
    .result_resta(resta),
    .result_mult(mult),
    .result_div(div_result),
    .result_pow(pow_result)
  );

  // =====================================================
  // SELECTOR DE RESULTADOS
  // =====================================================
  result_selector selector (
    .selector(SW),
    .suma(suma), .resta(resta), .mult(mult),
    .div_result(div_result), .pow_result(pow_result),
    .result(selected_result)
  );

  // =====================================================
  // SALIDAS
  // =====================================================
  assign LED = selected_result[9:0];
  assign DataAdr = ALUResult;

endmodule