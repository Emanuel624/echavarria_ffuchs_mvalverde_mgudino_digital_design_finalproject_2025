module led_controller (
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] Instr,
  input  logic [31:0] PC,
  input  logic [31:0] ALUResult,
  input  logic [2:0]  ALUControl,
  input  logic        RegWrite,
  output logic [7:0]  LED
);

  logic is_data_processing;
  logic is_add_op;
  logic is_sub_op;
  logic is_mul_op;
  logic is_mov_op;
  
  assign is_data_processing = (Instr[27:26] == 2'b00);
  
  always_comb begin
    is_add_op = 1'b0;
    is_sub_op = 1'b0;
    is_mul_op = 1'b0;
    is_mov_op = 1'b0;
    
    case (ALUControl)
      3'b000: is_add_op = 1'b1;
      3'b001: is_sub_op = 1'b1;
      3'b100: is_mul_op = 1'b1;
      default: is_mov_op = 1'b1;
    endcase
  end
  
  logic add_executed, sub_executed, mul_executed, mov_executed;
  
  assign add_executed = is_add_op && RegWrite;
  assign sub_executed = is_sub_op && RegWrite;
  assign mul_executed = is_mul_op && RegWrite;
  assign mov_executed = (Instr[27:26] == 2'b00) && (Instr[25:20] == 6'b001101) && RegWrite;

  logic add_flag, sub_flag, mul_flag, mov_flag, heartbeat;
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      add_flag  <= 1'b0;
      sub_flag  <= 1'b0;
      mul_flag  <= 1'b0;
      mov_flag  <= 1'b0;
      heartbeat <= 1'b0;
    end else begin
      heartbeat <= ~heartbeat;
      
      if (add_executed)  add_flag  <= 1'b1;
      if (sub_executed)  sub_flag  <= 1'b1;
      if (mul_executed)  mul_flag  <= 1'b1;
      if (mov_executed)  mov_flag  <= 1'b1;
    end
  end

  logic result_valid;
  assign result_valid = (ALUResult == 32'd0) || (ALUResult == 32'd7) || (ALUResult == 32'd10) || (ALUResult == 32'd12) || (ALUResult == 32'd17) || (ALUResult == 32'd24);
  
  // =========================================================
  // MODO DEBUG - LEDs para ver qué pasa internamente
  // =========================================================
  assign LED[0] = add_flag;                    // ADD ejecutado
  assign LED[1] = RegWrite;                    // DEBUG: ¿Está RegWrite en 1?
  assign LED[2] = ALUControl[0];               // DEBUG: Bit 0 de ALUControl
  assign LED[3] = ALUControl[1];               // DEBUG: Bit 1 de ALUControl
  assign LED[4] = ALUControl[2];               // DEBUG: Bit 2 de ALUControl
  assign LED[5] = heartbeat;                   // Heartbeat (parpadea)
  assign LED[6] = RegWrite;                    // RegWrite
  assign LED[7] = is_data_processing;          // Data processing

endmodule