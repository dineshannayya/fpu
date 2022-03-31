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
////  IEEE Floating Point to Integer Converter (Single Precision) ////
////                                                              ////
////                                                              ////
////  Description:                                                ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 28 Mar 2021, Dinesh A                               ////
////          Initial one integrated from  Jonathan P Dawson Repo ////
////          https://github.com/dawsonjon/fpu.git                ////
////    0.2 - 30 Mar 2021, Dinesh A                               ////
////          Interface and FSM correction to match the riscv     ////
////          interface                                           ////
//////////////////////////////////////////////////////////////////////
module fpu_sp_f2i(
        input  logic          clk,
        input  logic          rst_n,
        input  logic [31:0]   din,
        input  logic          dval,
        output logic [31:0]   result,
        output logic          rdy
      );


  reg       [2:0] state;
  parameter WAIT_REQ      = 3'd0,
            SPECIAL_CASES = 3'd1,
            UNPACK        = 3'd2,
            CONVERT       = 3'd3,
            OUT_RDY       = 3'd4;

  reg [31:0] a_m, a, z;
  reg [8:0] a_e;
  reg a_s;

  always @(negedge rst_n or posedge clk)
  begin
    if (rst_n == 0) begin
      state         <= WAIT_REQ;
      rdy           <= '0;
    end else begin
        case(state)
           WAIT_REQ:
           begin
             rdy   <= '0;
             if (dval) begin
               a <= din;
               state <= UNPACK;
             end
           end

          UNPACK:
          begin
            a_m[31:8] <= {1'b1, a[22 : 0]};
            a_m[7:0] <= 0;
            a_e <= a[30 : 23] - 127;
            a_s <= a[31];
            state <= SPECIAL_CASES;
          end

          SPECIAL_CASES:
          begin
            if ($signed(a_e) == -127) begin
              z <= 0;
              state <= OUT_RDY;
            end else if ($signed(a_e) > 31) begin
              z <= 32'h80000000;
              state <= OUT_RDY;
            end else begin
              state <= CONVERT;
            end
          end

          CONVERT:
          begin
            if ($signed(a_e) < 31 && a_m) begin
              a_e <= a_e + 1;
              a_m <= a_m >> 1;
            end else begin
              if (a_m[31]) begin
                z <= 32'h80000000;
              end else begin
                z <= a_s ? -a_m : a_m;
              end
              state <= OUT_RDY;
            end
          end

          OUT_RDY:
          begin
            rdy        <= 1;
            result     <= z;
            state      <= WAIT_REQ;
          end

        endcase
    end
  end

endmodule

