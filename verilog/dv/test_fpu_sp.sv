//---------------------------------------------------
// Common test case for (single precision) 32 bit 
// floating point adder multipler and divider
// --------------------------------------------------

task test_fpu_sp(logic [3:0] cmd, string test_name);
begin

   check_fpu_sp(cmd,32'h3f000000,32'h3fc00000); // 0.5 + 1.5
   check_fpu_sp(cmd,32'h3f000000,32'h3fa00000); // 0.5 + 1.25
   check_fpu_sp(cmd,32'h3f000000,32'h3e800000); // 0.5 + 0.25

   check_fpu_sp(cmd,32'h22cb525a,32'hadd79efa); 
   check_fpu_sp(cmd,32'h40000000,32'hC0000000); 
   check_fpu_sp(cmd,32'h83e73d5c,32'h1c800000); 
   check_fpu_sp(cmd,32'hbf9b1e94,32'hc038ed3a); 
   check_fpu_sp(cmd,32'h34082401,32'hb328cd45); 
   check_fpu_sp(cmd,32'h5e8ef81 ,32'h114f3db); 
   check_fpu_sp(cmd,32'h5c75da81,32'h2f642a39); 
   check_fpu_sp(cmd,32'h2b017   ,32'hff3807ab); 

   // Group-1
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'h80000000;
       din2 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'h00000000;
       din2 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'h80000000;
       din1 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'h00000000;
       din1 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end

   // Group-2
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'h7F800000;
       din2 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'hFF800000;
       din2 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'h7F800000;
       din1 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'hFF800000;
       din1 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
  
   // Group-3 
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'h7FC00000;
       din2 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'hFFC00000;
       din2 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'h7FC00000;
       din1 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'hFFC00000;
       din1 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end

   for(i = 0; i < 100; i = i+1) begin
       din2 = $random();
       din1 = $random();
       check_fpu_sp(cmd,din1 ,din2); 
   end
   $display("##########################");
   if(test_fail) begin
       $display("%s TEST FAILED",test_name);
   end else begin
       $display("%s TEST PASSED",test_name);
   end
   $display("##########################");
end
endtask


// Test case for Int to Float conversion
task test_fpu_sp_i2f (logic [3:0] cmd, string test_name);
begin
   check_fpu_sp_i2f(cmd,32'h3fc00000); //  1069547520
   check_fpu_sp_i2f(cmd,32'h3fa00000); //  1067450368
   check_fpu_sp_i2f(cmd,32'h3e800000); //  1048576000
   check_fpu_sp_i2f(cmd,32'h40200000); //  1075838976
   check_fpu_sp_i2f(cmd,32'h409ccccd); //  1084017869
   check_fpu_sp_i2f(cmd,32'h435ecccd); //  1130286285

   check_fpu_sp_i2f(cmd,32'hc0200000); //  -1071644672
   check_fpu_sp_i2f(cmd,32'hc09ccccd); //  -1063465779
   check_fpu_sp_i2f(cmd,32'hc35ecccd); //  788550441

   check_fpu_sp_i2f(cmd,32'h2f005329); // 872948737
   check_fpu_sp_i2f(cmd,32'h34082401); // -1168674534
   check_fpu_sp_i2f(cmd,32'hba57711a); // -1168674534
   check_fpu_sp_i2f(cmd,32'hbf9b1e94); // -1080353132
   check_fpu_sp_i2f(cmd,32'h5e8ef81);  // 99151745
   check_fpu_sp_i2f(cmd,32'h5c75da81); // 1551227521
   check_fpu_sp_i2f(cmd,32'h2b017);    // 176151

   check_fpu_sp_i2f(cmd,32'h80000000); // -2147483648
   check_fpu_sp_i2f(cmd,32'h00000000); // 0 
   check_fpu_sp_i2f(cmd,32'h7f800000); // 2139095040
   check_fpu_sp_i2f(cmd,32'hff800000); // -8388608
   check_fpu_sp_i2f(cmd,32'h7fc00000); // 2143289344
   check_fpu_sp_i2f(cmd,32'hffc00000); // -4194304

   for(i = 0; i < 1000; i = i+1) begin
       din1 = $random();
       check_fpu_sp_i2f(cmd,din1); 
   end
   $display("##########################");
   if(test_fail) begin
       $display("%s TEST FAILED",test_name);
   end else begin
       $display("%s TEST PASSED",test_name);
   end
   $display("##########################");
end
endtask

// Test case for Int to Float conversion
task test_fpu_sp_f2i (logic [3:0] cmd, string test_name);
begin

   check_fpu_sp_f2i(cmd,32'h3fc00000); //  1.5
   check_fpu_sp_f2i(cmd,32'h3fa00000); //  1.25
   check_fpu_sp_f2i(cmd,32'h3e800000); //  0.25
   check_fpu_sp_f2i(cmd,32'h40200000); //  2.5
   check_fpu_sp_f2i(cmd,32'h409ccccd); //  4.9
   check_fpu_sp_f2i(cmd,32'h435ecccd); //  222.8

   check_fpu_sp_f2i(cmd,32'hc0200000); //  -2.5
   check_fpu_sp_f2i(cmd,32'hc09ccccd); //  -4.9
   check_fpu_sp_f2i(cmd,32'hc35ecccd); //  -222.8

   check_fpu_sp_f2i(cmd,32'h2f005329); // 1.16710766052e-10
   check_fpu_sp_f2i(cmd,32'h34082401); // 1.26790851596e-07
   check_fpu_sp_f2i(cmd,32'hba57711a); // -0.000821845256723
   check_fpu_sp_f2i(cmd,32'hbf9b1e94); // -1.21187067032
   check_fpu_sp_f2i(cmd,32'h5e8ef81);  // 2.19051549915e-35
   check_fpu_sp_f2i(cmd,32'h5c75da81); // 2.76806467519e+17
   check_fpu_sp_f2i(cmd,32'h2b017);    // 2.46840125789e-40

   check_fpu_sp_f2i(cmd,32'h80000000); // -0.0
   check_fpu_sp_f2i(cmd,32'h00000000); // 0.0
   check_fpu_sp_f2i(cmd,32'h7f800000); // inf
   check_fpu_sp_f2i(cmd,32'hff800000); // -inf
   check_fpu_sp_f2i(cmd,32'h7fc00000); // nan
   check_fpu_sp_f2i(cmd,32'hffc00000); // nan


   for(i = 0; i < 1000; i = i+1) begin
       din1 = $random();
       check_fpu_sp_f2i(cmd,din1); 
   end
   $display("##########################");
   if(test_fail) begin
       $display("%s TEST FAILED",test_name);
   end else begin
       $display("%s TEST PASSED",test_name);
   end
   $display("##########################");
end
endtask



//-------------------------------------------------------
// Common Task for Adder/Multipler/Divider to drive to dut
// ------------------------------------------------------

task check_fpu_sp;
input [3:0]  cin;
input [31:0] in1;
input [31:0] in2;
begin
     repeat (1) @(posedge clk);
     cmd  = #1 cin;
     din1 = #1 in1;
     din2 = #1 in2;
     dval = #1 1;
     repeat (1) @(posedge clk);
     dval = #1 0;
     wait(rdy == 1);
     #1;
     c_result = $c_fpu_sp(cmd,din1,din2);
     // If the result is Nan (not valid number), 
     // Exponent = 255 and Significand = Non Zero is considered as Nan
     if(is_sp_nan(c_result) && is_sp_nan(result)) begin 
        $display("STATUS: FPU SP CMD: %x CHECK PASSED In1: %x In2: %x Result: Nan",cmd,din1,din2);
     end else begin
        if(c_result == result) begin
            $display("STATUS: FPU SP CMD: %x CHECK PASSED In1: %x In2: %x Result: %x",cmd,din1,din2,result);
        end else begin
            $display("STATUS: FPU SP CMD: %x CHECK FAILED In1: %x In2: %x Rxd Result: %x Exp Result: %x ",cmd,din1,din2,result,c_result);
            test_fail = 1;
	    #100;
	    $finish;
        end
     end
end
endtask


//-------------------------------------------------------
// Task drive DUT for  Int to float conversion 
// ------------------------------------------------------
task check_fpu_sp_i2f;
input [3:0]  cin;
input [31:0] in;
begin
     repeat (1) @(posedge clk);
     cmd  = #1 cin;
     din1 = #1 in;
     dval = #1 1;
     repeat (1) @(posedge clk);
     dval = #1 0;
     wait(rdy == 1);
     #1;
     c_result = $c_fpu_sp_tc(cmd,din1);
     if(c_result == result) begin
         $display("STATUS: FPU SP I2F CMD: %x CHECK PASSED In: %x: Result: %x",cmd,din1,result);
     end else begin
         $display("STATUS: FPU SP I2F CMD: %x CHECK FAILED In: %x Rxd Result: %x Exp Result: %x ",cmd,din1,result,c_result);
         test_fail = 1;
         #100;
         $finish;
     end
end
endtask

//-------------------------------------------------------
// Task drive DUT for  float to int conversion 
// ------------------------------------------------------
task check_fpu_sp_f2i;
input [3:0]  cin;
input [31:0] in;
begin
     repeat (1) @(posedge clk);
     cmd  = #1 cin;
     din1 = #1 in;
     dval = #1 1;
     repeat (1) @(posedge clk);
     dval = #1 0;
     wait(rdy == 1);
     #1;
     c_result = $c_fpu_sp_tc(cmd,din1);
     if(c_result == result) begin
         $display("STATUS: FPU SP I2F CMD: %x CHECK PASSED In: %x Rxd Result: %x Exp Result: %x",cmd,din1,result,c_result);
     end else begin
         $display("STATUS: FPU SP I2F CMD: %x CHECK FAILED In: %x Rxd Result: %x Exp Result: %x ",cmd,din1,result,c_result);
         test_fail = 1;
         #100;
         $finish;
     end
end
endtask

// Get mantissa
function logic [22:0] get_sp_mantissa;
input [31:0] x;
begin
    get_sp_mantissa = 32'h7fffff & x;
end
endfunction

// Get Exponent
function logic [7:0] get_sp_exponent;
input [31:0] x;
begin
    get_sp_exponent = ((x & 32'h7f800000) >> 23) - 127;
end
endfunction

// Get Sign
function logic get_sp_sign;
input [31:0] x;
begin
    get_sp_sign = ((x & 32'h80000000) >> 31);
end
endfunction

// Not Valid Number
function logic is_sp_nan;
input [31:0] x;
begin
    is_sp_nan = get_sp_exponent(x) == 128 & get_sp_mantissa(x) != 0;
end
endfunction

// Infinity
function logic is_sp_inf;
input [31:0] x;
begin
    is_sp_inf = (get_sp_exponent(x) == 128) & (get_sp_mantissa(x) == 0);
end
endfunction

// Infinity
function logic is_sp_pos_inf;
input [31:0] x;
begin
    is_sp_pos_inf = (is_sp_inf(x)) &  (!get_sp_sign(x));
end
endfunction

// Infinity
function logic is_sp_neg_inf;
input [31:0] x;
begin
    is_sp_neg_inf = is_sp_inf(x) & get_sp_sign(x);
end
endfunction

function logic sp_match;
input [31:0] x;
input [31:0] y;
begin
    sp_match =   ((is_sp_pos_inf(x) & is_sp_pos_inf(y)) |
                  (is_sp_neg_inf(x) & is_sp_neg_inf(y)) |
                  (is_sp_nan(x)     & is_sp_nan(y)) |
                  (x == y));

end
endfunction
