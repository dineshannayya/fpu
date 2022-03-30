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
////  IEEE Floating Point module top                              ////
////                                                              ////
////                                                              ////
////  Description: This module integrate following floating       ////
////       fpu_add.sv - floating point adder                      ////
////       fpu_mul.sv - floating point multipler                  ////
////       fpu_div.sv - floating point divider                    ////
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


module fpu_top(
        input  logic          clk,
        input  logic          rst_n,
	input  logic [3:0]    cmd,
        input  logic [31:0]   din1,
        input  logic [31:0]   din2,
        input  logic          dval,
        output logic [31:0]   result,
        output logic          rdy
);

parameter CMD_FPU_ADD = 4'b0001;
parameter CMD_FPU_MUL = 4'b0010;
parameter CMD_FPU_DIV = 4'b0011;

logic        add_rdy;
logic [31:0] add_result;

logic        mul_rdy;
logic [31:0] mul_result;

logic        div_rdy;
logic [31:0] div_result;

wire add_dval =  (dval) & (cmd == CMD_FPU_ADD);
wire mul_dval =  (dval) & (cmd == CMD_FPU_MUL);
wire div_dval =  (dval) & (cmd == CMD_FPU_DIV);

assign rdy    = (cmd == CMD_FPU_ADD) ? add_rdy    : (cmd == CMD_FPU_MUL) ? mul_rdy : div_rdy;
assign result = (cmd == CMD_FPU_ADD) ? add_result : (cmd == CMD_FPU_MUL) ? mul_result : div_result;

// floating point adder
fpu_add  u_add (
        .clk               (clk          ),
        .rst_n             (rst_n        ),
        .din1              (din1         ),
        .din2              (din2         ),
        .dval              (add_dval     ),
        .result            (add_result   ),
        .rdy               (add_rdy      )
      );

// floating point multipler
fpu_mul  u_mul (
        .clk               (clk          ),
        .rst_n             (rst_n        ),
        .din1              (din1         ),
        .din2              (din2         ),
        .dval              (mul_dval     ),
        .result            (mul_result   ),
        .rdy               (mul_rdy      )
      );

// floating point divider
fpu_div  u_div (
        .clk               (clk          ),
        .rst_n             (rst_n        ),
        .din1              (din1         ),
        .din2              (din2         ),
        .dval              (div_dval     ),
        .result            (div_result   ),
        .rdy               (div_rdy      )
      );

endmodule
