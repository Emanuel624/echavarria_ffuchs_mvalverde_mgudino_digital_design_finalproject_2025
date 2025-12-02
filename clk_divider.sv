
module clk_divider (
    input  logic clk_50mhz,
    input  logic reset_n,
    output logic clk_25mhz
);

    logic clk_div;
    
    always_ff @(posedge clk_50mhz or negedge reset_n) begin
        if (!reset_n)
            clk_div <= 1'b0;
        else
            clk_div <= ~clk_div;
    end
    
    assign clk_25mhz = clk_div;

endmodule