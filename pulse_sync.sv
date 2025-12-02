module pulse_sync (
    input  logic clk_dst,
    input  logic reset_n,
    input  logic pulse_in,
    output logic pulse_out
);

    logic s1, s2, s3;

    always_ff @(posedge clk_dst or negedge reset_n) begin
        if (!reset_n) begin
            s1 <= 0;
            s2 <= 0;
            s3 <= 0;
        end else begin
            s1 <= pulse_in;
            s2 <= s1;
            s3 <= s2;
        end
    end

    assign pulse_out = s2 & ~s3; 

endmodule
