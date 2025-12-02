module top (
  input  logic        clk,
  input  logic        reset,
  input  logic [2:0]  SW,
  input  logic        SW_LOAD,
  input  logic        SW_RESET,
  output logic [31:0] WriteData,
  output logic [31:0] DataAdr,
  output logic        MemWrite,
  output logic [9:0]  LED
);

  logic [31:0] PC, Instr, ReadData, ALUResult;
  logic [31:0] selected_result;
  logic [31:0] suma, resta, mult, div_result, pow_result;
  
  // Señales para LOAD
  logic load_r1, load_r2, load_pulse;
  logic load_en;
  
  // Señales para RESET
  logic reset_r1, reset_r2, reset_pulse;
  logic reset_en;

  // =====================================================
  // DEBOUNCE Y DETECTOR DE FLANCO PARA SW_LOAD
  // =====================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      load_r1 <= 1'b0;
      load_r2 <= 1'b0;
    end else begin
      load_r1 <= SW_LOAD;
      load_r2 <= load_r1;
    end
  end

  assign load_pulse = load_r1 & ~load_r2;

  // =====================================================
  // DEBOUNCE Y DETECTOR DE FLANCO PARA SW_RESET
  // =====================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      reset_r1 <= 1'b0;
      reset_r2 <= 1'b0;
    end else begin
      reset_r1 <= SW_RESET;
      reset_r2 <= reset_r1;
    end
  end

  assign reset_pulse = reset_r1 & ~reset_r2;

  // =====================================================
  // ACTIVAR CARGA CUANDO DETECTA FLANCO EN SW_LOAD
  // =====================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      load_en <= 1'b0;
    end else begin
      if (load_pulse) begin
        load_en <= 1'b1;
      end else begin
        load_en <= 1'b0;
      end
    end
  end

  // =====================================================
  // ACTIVAR RESET CUANDO DETECTA FLANCO EN SW_RESET
  // =====================================================
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      reset_en <= 1'b0;
    end else begin
      if (reset_pulse) begin
        reset_en <= 1'b1;
      end else begin
        reset_en <= 1'b0;
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
    .reset_en(reset_en),
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