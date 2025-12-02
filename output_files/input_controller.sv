module input_controller (
  input  logic        clk,
  input  logic        reset,
  input  logic [7:0]  SW_A,
  input  logic [7:0]  SW_B,
  input  logic        BTN_LOAD,
  output logic        write_en,
  output logic [31:0] write_addr,
  output logic [31:0] write_data
);

  logic btn_r1, btn_r2, btn_pulse;
  logic [1:0] state;
  
  parameter STATE_IDLE = 2'b00;
  parameter STATE_WRITE_A = 2'b01;
  parameter STATE_WRITE_B = 2'b10;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      btn_r1 <= 1'b0;
      btn_r2 <= 1'b0;
    end else begin
      btn_r1 <= BTN_LOAD;
      btn_r2 <= btn_r1;
    end
  end

  assign btn_pulse = btn_r1 & ~btn_r2;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= STATE_IDLE;
      write_en <= 1'b0;
      write_addr <= 32'b0;
      write_data <= 32'b0;
    end else begin
      case (state)
        STATE_IDLE: begin
          write_en <= 1'b0;
          if (btn_pulse) begin
            state <= STATE_WRITE_A;
          end
        end

        STATE_WRITE_A: begin
          write_en <= 1'b1;
          write_addr <= 32'd0;
          write_data <= {24'b0, SW_A};
          state <= STATE_WRITE_B;
        end

        STATE_WRITE_B: begin
          write_en <= 1'b1;
          write_addr <= 32'd4;
          write_data <= {24'b0, SW_B};
          state <= STATE_IDLE;
        end

        default: state <= STATE_IDLE;
      endcase
    end
  end

endmodule