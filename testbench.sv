module testbench();
  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

  // instantiate device under test (DUT)
  top dut (clk, reset, WriteData, DataAdr, MemWrite);

  // init test
  initial begin
    clk   = 1'b0;
    reset = 1'b1;
    #22;
    reset = 1'b0;
  end

  // generate clock to sequence tests
  always #5 clk = ~clk;

  // Trace ALU inputs and outputs
  initial begin
    $monitor("T:%0t | PC=%h | Instr=%h | SrcA=%h | SrcB=%h | ALURes=%h | ExtImm=%h | ALUSrc=%b | RegWr=%b",
             $time, dut.arm.PC, dut.arm.Instr,
             dut.arm.u_datapathdp.SrcA,
             dut.arm.u_datapathdp.SrcB,
             dut.arm.u_datapathdp.ALUResult,
             dut.arm.u_datapathdp.ExtImm,
             dut.arm.u_controllerc.ALUSrc,
             dut.arm.u_controllerc.RegWrite);
  end

  // check that 7 gets written to address 0x64 (100)
  always @(negedge clk) begin
    if (MemWrite) begin
      $display("\n*** MemWrite at T:%0t | DA=%d (0x%h) | WD=%d (0x%h)", 
               $time, DataAdr, DataAdr, WriteData, WriteData);
      
      if ((DataAdr === 32'd100) && (WriteData === 32'd7)) begin
        $display("*** Simulation SUCCEEDED ***");
        $stop;
      end
      else begin
        $display("*** Simulation FAILED ***");
        $stop;
      end
    end
  end
endmodule