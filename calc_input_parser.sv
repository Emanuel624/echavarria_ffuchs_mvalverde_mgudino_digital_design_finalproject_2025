module calc_input_parser (
    input  logic        clk,
    input  logic        reset_n,

    input  logic [7:0]  key_ascii,
    input  logic        key_pressed,

    output logic [31:0] op_a_int,
    output logic [31:0] op_b_int,
    output logic [2:0]  op_code,
    output logic        op_enter_pulse
);

    // -------------------------
    // EDGE DETECTOR
    // -------------------------
    logic key_prev;
    logic key_edge;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            key_prev <= 1'b0;
        else
            key_prev <= key_pressed;
    end

    assign key_edge = key_pressed & ~key_prev;

    // -------------------------
    // Internal state
    // -------------------------
    logic [31:0] a_reg, b_reg;
    logic [2:0]  op_reg;
    logic [2:0]  a_digits, b_digits;
    logic        has_op;

    logic enter_pulse_r;

    assign op_a_int       = a_reg;
    assign op_b_int       = b_reg;
    assign op_code        = op_reg;
    assign op_enter_pulse = enter_pulse_r;

    // digit helper
    function automatic logic is_digit(input [7:0] c);
        return (c >= 8'd48 && c <= 8'd57);  // '0'..'9'
    endfunction

    // -------------------------
    // Main logic
    // -------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            a_reg         <= 32'd0;
            b_reg         <= 32'd0;
            op_reg        <= 3'd0;
            a_digits      <= 3'd0;
            b_digits      <= 3'd0;
            has_op        <= 1'b0;
            enter_pulse_r <= 1'b0;
        end 
        else begin
            enter_pulse_r <= 1'b0;

            if (key_edge) begin

                // ------------------------------------------
                // AC / CLEAR
                // ------------------------------------------
                if (key_ascii == 8'd27) begin
                    a_reg    <= 32'd0;
                    b_reg    <= 32'd0;
                    op_reg   <= 3'd0;
                    a_digits <= 3'd0;
                    b_digits <= 3'd0;
                    has_op   <= 1'b0;
                end

                // ------------------------------------------
                // BACKSPACE
                // ------------------------------------------
                else if (key_ascii == 8'd8) begin
                    if (has_op && b_digits > 0) begin
                        b_reg    <= b_reg / 10;
                        b_digits <= b_digits - 1;
                    end
                    else if (!has_op && a_digits > 0) begin
                        a_reg    <= a_reg / 10;
                        a_digits <= a_digits - 1;
                    end
                end

                // ------------------------------------------
                // ENTER
                // ------------------------------------------
                else if (key_ascii == 8'd10) begin
                    if (a_digits > 0 && has_op && b_digits > 0)
                        enter_pulse_r <= 1'b1;
                end

                // ------------------------------------------
                // OPERATORS
                // ------------------------------------------
                else if (key_ascii == "+" || key_ascii == "-" ||
                         key_ascii == "*" || key_ascii == "/") begin

                    // POW detection (**)
                    if (key_ascii == 8'd42) begin // '*'
                        if (has_op && op_reg == 3'd2 && b_digits == 0) begin
                            op_reg <= 3'd4; // POW
                        end
                        else if (!has_op && a_digits > 0) begin
                            op_reg <= 3'd2; // MUL
                            has_op <= 1'b1;
                        end
                    end 
                    else if (!has_op && a_digits > 0) begin
                        case (key_ascii)
                            "+": op_reg <= 3'd0;
                            "-": op_reg <= 3'd1;
                            "/": op_reg <= 3'd3;
                        endcase
                        has_op <= 1'b1;
                    end
                end

                // ------------------------------------------
                // DIGITS
                // ------------------------------------------
                else if (is_digit(key_ascii)) begin

                    logic [3:0] digit;    
                    digit = key_ascii - 8'd48;

                    if (!has_op && a_digits < 5) begin
                        a_reg    <= a_reg * 10 + digit;
                        a_digits <= a_digits + 1;
                    end
                    else if (has_op && b_digits < 5) begin
                        b_reg    <= b_reg * 10 + digit;
                        b_digits <= b_digits + 1;
                    end
                end

            end  // key_edge
        end
    end

endmodule
