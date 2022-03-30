/***********************************
32-bit Single-Precision arithmetic

Bit No	Size	Field Name
31	1 bit 	Sign (S)
23-30	8 bits	Exponent (E)
0-22	23 bits	Mantissa (M)

Single Precision: mantissa ===> 1 bit + 23 bits

               Sign	Exponent	Mantissa
1.0 × 2e-1	0	11111111	0000000 00000000 00000000
1.0 × 2e1	0	00000001	0000000 00000000 00000000


-1 is represented as -1 + 127 = 126 = 01111110
 0 is represented as  0 + 127 = 127 = 01111111
+1 is represented as +1 + 127 = 128 = 10000000
+5 is represented as +5 + 127 = 132 = 10000100


64-bit Double-Precision arithmetic
Bit No	Size	Field Name
63	1 bit 	Sign (S)
52-62	11 bits	Exponent (E)
0-51	52 bits	Mantissa (M)

Double Precision: mantissa ===> 1 bit + 52 bits

**********************************/

/************************************************
* Reference: https://www.doc.ic.ac.uk/~eedwards/compsys/float/
*
 Floating point addition in binary

Perform 0.5 + (-0.4375)

0.5 = 0.1 × 20 = 1.000 × 2e-1 (normalised)

-0.4375 = -0.0111 × 20 = -1.110 × 2e-2 (normalised)

    Rewrite the smaller number such that its exponent matches with the exponent of the larger number.

    -1.110 × 2e-2 = -0.1110 × 2e-1

    Add the mantissas:

    1.000 × 2e-1 + -0.1110 × 2e-1 = 0.001 × 2e-1

    Normalise the sum, checking for overflow/underflow:

    0.001 × 2e-1 = 1.000 × 2e-4

    -126 <= -4 <= 127 ===> No overflow or underflow

    Round the sum:

    The sum fits in 4 bits so rounding is not required

Check: 1.000 × 2e-4 = 0.0625 which is equal to 0.5 - 0.4375

***********************************************************/
/**********************************************************
Floating point multiplication in binary:
* Reference: https://www.doc.ic.ac.uk/~eedwards/compsys/float/
*

1.000 × 2e-1 × -1.110 × 2e-2

    Add the biased exponents

    (-1 + 127) + (-2 + 127) - 127 = 124 ===> (-3 + 127)

    Multiply the mantissas

                  1.000
               ×  1.110
               -----------
                      0000
                     1000
                    1000
               +   1000
               -----------
                   1110000  ===> 1.110000

    The product is 1.110000 × 2e-3
    Need to keep it to 4 bits 1.110 × 2e-3

    Normalise (already normalised)

    At this step check for overflow/underflow by making sure that

    -126 <= Exponent <= 127

    1 <= Biased Exponent <= 254

    Round the result (no change)

    Adjust the sign.

    Since the original signs are different, the result will be negative

    -1.110 × 2e-3
***********************************************************************/
// floating point calculator: https://www.h-schmidt.net/FloatConverter/IEEE754.html
`timescale 1 ns/10 ps
module tb_top;
parameter CLK_PERIOD = 10;

parameter CMD_FPU_ADD = 4'b0001;
parameter CMD_FPU_MUL = 4'b0010;
parameter CMD_FPU_DIV = 4'b0011;

reg          clk;
reg          rst_n;
reg [3:0]    cmd;
reg [31:0]   din1;
reg [31:0]   din2;
reg          dval;
wire [31:0] result;
reg [31:0]  c_result;
wire        rdy;
reg         test_fail;
integer     i;

always #(CLK_PERIOD/2) clk  <= (clk === 1'b0);
initial 
begin
   rst_n = 0;
   test_fail=0;
   cmd      = 0;
   #100 rst_n = 1;
   repeat (10) @(posedge clk);
   test_fpu(CMD_FPU_ADD,"FPU ADD");;
   test_fpu(CMD_FPU_MUL,"FPU MUL");;
   test_fpu(CMD_FPU_DIV,"FPU DIV");;
   #100;
   $finish();
end

//initial begin
//   $dumpfile("simx.vcd");
//   $dumpvars(0, tb_top);
//end



fpu_top u_fpu_top (
        .clk         (clk     ),
        .rst_n       (rst_n   ),
        .cmd         (cmd     ),
        .din1        (din1    ),
        .din2        (din2    ),
        .dval        (dval    ),
        .result      (result  ),
        .rdy         (rdy     )
      );




// Get mantissa
function logic [22:0] get_mantissa;
input [31:0] x;
begin
    get_mantissa = 32'h7fffff & x;
end
endfunction

// Get Exponent
function logic [7:0] get_exponent;
input [31:0] x;
begin
    get_exponent = ((x & 32'h7f800000) >> 23) - 127;
end
endfunction

// Get Sign
function logic get_sign;
input [31:0] x;
begin
    get_sign = ((x & 32'h80000000) >> 31);
end
endfunction

// Not Valid Number
function logic is_nan;
input [31:0] x;
begin
    is_nan = get_exponent(x) == 128 & get_mantissa(x) != 0;
end
endfunction

// Infinity
function logic is_inf;
input [31:0] x;
begin
    is_inf = (get_exponent(x) == 128) & (get_mantissa(x) == 0);
end
endfunction

// Infinity
function logic is_pos_inf;
input [31:0] x;
begin
    is_pos_inf = (is_inf(x)) &  (!get_sign(x));
end
endfunction

// Infinity
function logic is_neg_inf;
input [31:0] x;
begin
    is_neg_inf = is_inf(x) & get_sign(x);
end
endfunction

function logic match;
input [31:0] x;
input [31:0] y;
begin
    match =     ((is_pos_inf(x) & is_pos_inf(y)) |
                 (is_neg_inf(x) & is_neg_inf(y)) |
                 (is_nan(x) & is_nan(y)) |
                 (x == y));

end
endfunction

`include "test_fpu.sv"

endmodule