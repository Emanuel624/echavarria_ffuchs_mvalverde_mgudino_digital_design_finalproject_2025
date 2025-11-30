// bin_to_bcd.sv
module bin_to_bcd (
    input  logic [7:0]  binary,
    output logic [3:0]  hundreds,
    output logic [3:0]  tens,
    output logic [3:0]  ones
);

    always_comb begin
        hundreds = binary / 100;
        tens = (binary % 100) / 10;
        ones = binary % 10;
    end

endmodule