//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  IEEE Floating Point Double precision module top             ////
////                                                              ////
////                                                              ////
////  Description: This module integrate following floating       ////
////       fpu_dp_add.sv - floating point 64bit adder             ////
////       fpu_dp_mul.sv - floating point 64bit multipler         ////
////       fpu_dp_div.sv - floating point 64bit divider           ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 30 Mar 2021, Dinesh A                               ////
////          Initial integration of adder, multipler,divider     ////
//////////////////////////////////////////////////////////////////////


module fpu_dp_top(
        input  logic          clk,
        input  logic          rst_n,
	input  logic [3:0]    cmd,
        input  logic [63:0]   din1,
        input  logic [63:0]   din2,
        input  logic          dval,
        output logic [63:0]   result,
        output logic          rdy
);

parameter CMD_FPU_SP_ADD  = 4'b0001; // Single Precision (32 bit) Adder 
parameter CMD_FPU_SP_MUL  = 4'b0010; // Single Precision (32 bit) Multipler
parameter CMD_FPU_SP_DIV  = 4'b0011; // Single Precision (32 bit) Divider
parameter CMD_FPU_DP_ADD  = 4'b0101; // Double Precision (64 bit) Adder
parameter CMD_FPU_DP_MUL  = 4'b0110; // Double Precision (64 bit) Multipler
parameter CMD_FPU_DP_DIV  = 4'b0111; // Double Precision (64 bit) Divider

//--------------------------------------------------
// Double Precision Adder Local decleration
//--------------------------------------------------
logic        dp_add_rdy;
logic [63:0] dp_add_result;

//--------------------------------------------------
// Double Precision Multiplication Local decleration
// -------------------------------------------------
logic        dp_mul_rdy;
logic [63:0] dp_mul_result;

//--------------------------------------------------
// Double Precision Division Local decleration
// -------------------------------------------------
logic        dp_div_rdy;
logic [63:0] dp_div_result;

//-------------------------------------------------
//
wire dp_add_dval = (dval) & (cmd == CMD_FPU_DP_ADD);
wire dp_mul_dval = (dval) & (cmd == CMD_FPU_DP_MUL);
wire dp_div_dval = (dval) & (cmd == CMD_FPU_DP_DIV);

assign rdy    = (cmd == CMD_FPU_DP_ADD) ? dp_add_rdy    : 
	        (cmd == CMD_FPU_DP_MUL) ? dp_mul_rdy    : 
		(cmd == CMD_FPU_DP_DIV) ? dp_div_rdy    : 
		'0;
assign result = (cmd == CMD_FPU_DP_ADD) ? dp_add_result : 
	        (cmd == CMD_FPU_DP_MUL) ? dp_mul_result : 
		(cmd == CMD_FPU_DP_DIV) ? dp_div_result : 
		'0;


// floating point double adder
fpu_dp_add  u_dp_add (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din1              (din1[63:0]      ),
        .din2              (din2[63:0]      ),
        .dval              (dp_add_dval     ),
        .result            (dp_add_result   ),
        .rdy               (dp_add_rdy      )
      );

// floating point multipler
fpu_dp_mul  u_dp_mul (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din1              (din1[63:0]      ),
        .din2              (din2[63:0]      ),
        .dval              (dp_mul_dval     ),
        .result            (dp_mul_result   ),
        .rdy               (dp_mul_rdy      )
      );

// floating point divider
fpu_dp_div  u_dp_div (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din1              (din1[63:0]      ),
        .din2              (din2[63:0]      ),
        .dval              (dp_div_dval     ),
        .result            (dp_div_result   ),
        .rdy               (dp_div_rdy      )
      );
endmodule
