task test_fpu(logic [3:0] cmd, string test_name);
begin
   $display("$c_fpu(0.5,1.5): %x ", $c_fpu(cmd,32'h3f000000,32'h3fc00000)); // 0.5 + 1.5
   $display("$c_fpu(0.5,1.25): %x ", $c_fpu(cmd,32'h3f000000,32'h3fa00000)); // 0.5 + 1.25
   $display("$c_fpu(0.5,0.25): %x ", $c_fpu(cmd,32'h3f000000,32'h3e800000)); // 0.5 + 0.25

   check_fpu_result(cmd,32'h3f000000,32'h3fc00000); // 0.5 + 1.5
   check_fpu_result(cmd,32'h3f000000,32'h3fa00000); // 0.5 + 1.25
   check_fpu_result(cmd,32'h3f000000,32'h3e800000); // 0.5 + 0.25

   check_fpu_result(cmd,32'h22cb525a,32'hadd79efa); 
   check_fpu_result(cmd,32'h40000000,32'hC0000000); 
   check_fpu_result(cmd,32'h83e73d5c,32'h1c800000); 
   check_fpu_result(cmd,32'hbf9b1e94,32'hc038ed3a); 
   check_fpu_result(cmd,32'h34082401,32'hb328cd45); 
   check_fpu_result(cmd,32'h5e8ef81 ,32'h114f3db); 
   check_fpu_result(cmd,32'h5c75da81,32'h2f642a39); 
   check_fpu_result(cmd,32'h2b017   ,32'hff3807ab); 

   // Group-1
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'h80000000;
       din2 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'h00000000;
       din2 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'h80000000;
       din1 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'h00000000;
       din1 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end

   // Group-2
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'h7F800000;
       din2 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'hFF800000;
       din2 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'h7F800000;
       din1 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'hFF800000;
       din1 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
  
   // Group-3 
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'h7FC00000;
       din2 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din1 = 32'hFFC00000;
       din2 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'h7FC00000;
       din1 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end
   for(i = 0; i < 100; i = i+1) begin
       din2 = 32'hFFC00000;
       din1 = $random();
       check_fpu_result(cmd,din1 ,din2); 
   end

   for(i = 0; i < 100; i = i+1) begin
       din2 = $random();
       din1 = $random();
       check_fpu_result(cmd,din1 ,din2); 
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


task check_fpu_result;
input [3:0]  cin;
input [31:0] in1;
input [31:0] in2;
begin
     repeat (1) @(posedge clk);
     cmd  = cin;
     din1 = in1;
     din2 = in2;
     dval = 1;
     repeat (1) @(posedge clk);
     dval = 0;
     wait(rdy == 1);
     c_result = $c_fpu(cmd,din1,din2);
     // If the result is Nan (not valid number), 
     // Exponent = 255 and Significand = Non Zero is considered as Nan
     if(is_nan(c_result) && is_nan(result)) begin 
        $display("STATUS: FPU CMD: %x CHECK PASSED In1: %x In2: %x Result: Nan",cmd,din1,din2);
     end else begin
        if(c_result == result) begin
            $display("STATUS: FPU CMD: %x CHECK PASSED In1: %x In2: %x Result: %x",cmd,din1,din2,result);
        end else begin
            $display("STATUS: FPU CMD: %x CHECK FAILED In1: %x In2: %x Rxd Result: %x Exp Result: %x ",cmd,din1,din2,result,c_result);
            test_fail = 1;
	    #100;
	    $finish;
        end
     end
end
endtask
