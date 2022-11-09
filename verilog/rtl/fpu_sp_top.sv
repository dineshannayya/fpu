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
////  IEEE Floating Point single precision module top             ////
////                                                              ////
////                                                              ////
////  Description: This module integrate following floating       ////
////       fpu_sp_add.sv - floating point 32bit adder             ////
////       fpu_sp_mul.sv - floating point 32bit multipler         ////
////       fpu_sp_div.sv - floating point 32bit divider           ////
////       fpu_sp_f2i.sv - Float to int                           ////
////       fpu_sp_i2f.sv - int to floating point                  ////
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
/*********************************************************************
    RISCV Floating Point Mode
      Rounding Mode   Mnemonics       Meaninng
          000           RNE           Round to Nearest, ties to Even
          001           RTZ           Round to Zero
          010           RDN           Round Down (Towards - Infinity)
          011           RUP           Round Up (towards + Infinity)
          100           RMM           Round to Nearest, ties to Max Magnitute
          101                         Reserved for future use
          110                         Reserved for future use
          111           DYN           In instruction's rm field select dyamic rounding mode.
                                      In Rounding Mode register. resevred

      Status Bit Decoding
         [0] - NX - In Exact
         [1] - UF - Under Flow
         [2] - OF - Overflow
         [3] - DZ - Divide by Zero
         [4] - NV - Invalid Operation
***************************************************************************************************/


module fpu_sp_top(
        input  logic          clk,
        input  logic          rst_n,
	    input  logic [3:0]    cmd,
        input  logic [31:0]   din1,
        input  logic [31:0]   din2,
        input  logic          dval,
        output logic [31:0]   result,
        output logic          rdy
);
`include "fpu_parms.v"

//--------------------------------------------------
// Single Precision Adder Local decleration
// -------------------------------------------------
logic        sp_add_rdy;
logic [31:0] sp_add_result;

//--------------------------------------------------
// Single Precision Multiplication Local decleration
// -------------------------------------------------
logic        sp_mul_rdy;
logic [31:0] sp_mul_result;

//--------------------------------------------------
// Single Precision Division Local decleration
// -------------------------------------------------
logic        sp_div_rdy;
logic [31:0] sp_div_result;

//--------------------------------------------------
// Single Precision Float to integer Local decleration
// -------------------------------------------------
logic        sp_f2i_rdy;
logic [31:0] sp_f2i_result;

//--------------------------------------------------
// Single Precision integer to float Local decleration
// -------------------------------------------------
logic        sp_i2f_rdy;
logic [31:0] sp_i2f_result;

//-------------------------------------------------
//
wire sp_add_dval =  (dval) & (cmd == CMD_FPU_SP_ADD);
wire sp_mul_dval =  (dval) & (cmd == CMD_FPU_SP_MUL);
wire sp_div_dval =  (dval) & (cmd == CMD_FPU_SP_DIV);
wire sp_f2i_dval =  (dval) & (cmd == CMD_FPU_SP_F2I);
wire sp_i2f_dval =  (dval) & (cmd == CMD_FPU_SP_I2F);


assign rdy    = (cmd == CMD_FPU_SP_ADD) ? sp_add_rdy    : 
	            (cmd == CMD_FPU_SP_MUL) ? sp_mul_rdy    : 
		        (cmd == CMD_FPU_SP_DIV) ? sp_div_rdy    : 
		        (cmd == CMD_FPU_SP_F2I) ? sp_f2i_rdy    : 
		        (cmd == CMD_FPU_SP_I2F) ? sp_i2f_rdy    : 
		        '0;
assign result = (cmd == CMD_FPU_SP_ADD) ? sp_add_result : 
	            (cmd == CMD_FPU_SP_MUL) ? sp_mul_result : 
		        (cmd == CMD_FPU_SP_DIV) ? sp_div_result : 
		        (cmd == CMD_FPU_SP_F2I) ? sp_f2i_result : 
		        (cmd == CMD_FPU_SP_I2F) ? sp_i2f_result : 
		        '0;

// floating point adder
fpu_sp_add  u_sp_add (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din1              (din1[31:0]      ),
        .din2              (din2[31:0]      ),
        .dval              (sp_add_dval     ),
        .result            (sp_add_result   ),
        .rdy               (sp_add_rdy      )
      );

// floating point multipler
fpu_sp_mul  u_sp_mul (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din1              (din1[31:0]      ),
        .din2              (din2[31:0]      ),
        .dval              (sp_mul_dval     ),
        .result            (sp_mul_result   ),
        .rdy               (sp_mul_rdy      )
      );

// floating point divider
fpu_sp_div  u_sp_div (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din1              (din1[31:0]      ),
        .din2              (din2[31:0]      ),
        .dval              (sp_div_dval     ),
        .result            (sp_div_result   ),
        .rdy               (sp_div_rdy      )
      );

// floating point Float to int
fpu_sp_f2i  u_sp_f2i (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din               (din1[31:0]      ),
        .dval              (sp_f2i_dval     ),
        .result            (sp_f2i_result   ),
        .rdy               (sp_f2i_rdy      )
      );
// floating point Float to int
fpu_sp_i2f  u_sp_i2f (
        .clk               (clk             ),
        .rst_n             (rst_n           ),
        .din               (din1[31:0]      ),
        .dval              (sp_i2f_dval     ),
        .result            (sp_i2f_result   ),
        .rdy               (sp_i2f_rdy      )
      );

endmodule
