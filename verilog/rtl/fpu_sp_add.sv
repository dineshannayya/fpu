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
////  IEEE Floating Point Adder (Single Precision)                ////
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


module fpu_sp_add(
        input  logic          clk,
        input  logic          rst_n,
        input  logic [31:0]   din1,
        input  logic [31:0]   din2,
        input  logic          dval,
        output logic [31:0]   result,
        output logic          rdy
      );

  reg       [31:0] s_output_z;

  reg       [3:0] state;
  parameter WAIT_REQ      = 4'd0,
            UNPACK        = 4'd1,
            SPECIAL_CASES = 4'd2,
            ALIGN         = 4'd3,
            ADD_0         = 4'd4,
            ADD_1         = 4'd5,
            NORMALISE_1   = 4'd6,
            NORMALISE_2   = 4'd7,
            ROUND         = 4'd8,
            PACK          = 4'd9,
            OUT_RDY       = 4'd10;

  reg       [31:0] a, b, z;
  reg       [26:0] a_m, b_m;
  reg       [23:0] z_m;
  reg       [9:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [27:0] pre_sum;

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
              a <= din1;
              b <= din2;
              state <= UNPACK;
            end
          end

          UNPACK:
          begin
            a_m    <= {a[22 : 0], 3'd0};
            b_m    <= {b[22 : 0], 3'd0};
            a_e    <= a[30 : 23] - 127;
            b_e    <= b[30 : 23] - 127;
            a_s    <= a[31];
            b_s    <= b[31];
            state <= SPECIAL_CASES;
          end

          SPECIAL_CASES:
          begin
            //if a is NaN or b is NaN return NaN 
            if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) begin
              z[31] <= 1;
              z[30:23] <= 255;
              z[22] <= 1;
              z[21:0] <= 0;
              state <= OUT_RDY;
            //if a is inf return inf
            end else if (a_e == 128) begin
              z[31] <= a_s;
              z[30:23] <= 255;
              z[22:0] <= 0;
              //if a is inf and signs don't match return nan
              if ((b_e == 128) && (a_s != b_s)) begin
                  z[31] <= b_s;
                  z[30:23] <= 255;
                  z[22] <= 1;
                  z[21:0] <= 0;
              end
              state <= OUT_RDY;
            //if b is inf return inf
            end else if (b_e == 128) begin
              z[31] <= b_s;
              z[30:23] <= 255;
              z[22:0] <= 0;
              state <= OUT_RDY;
            //if a is zero return b
            end else if ((($signed(a_e) == -127) && (a_m == 0)) && (($signed(b_e) == -127) && (b_m == 0))) begin
              z[31] <= a_s & b_s;
              z[30:23] <= b_e[7:0] + 127;
              z[22:0] <= b_m[26:3];
              state <= OUT_RDY;
            //if a is zero return b
            end else if (($signed(a_e) == -127) && (a_m == 0)) begin
              z[31] <= b_s;
              z[30:23] <= b_e[7:0] + 127;
              z[22:0] <= b_m[26:3];
              state <= OUT_RDY;
            //if b is zero return a
            end else if (($signed(b_e) == -127) && (b_m == 0)) begin
              z[31] <= a_s;
              z[30:23] <= a_e[7:0] + 127;
              z[22:0] <= a_m[26:3];
              state <= OUT_RDY;
            end else begin
              //Denormalised Number
              if ($signed(a_e) == -127) begin
                a_e <= -126;
              end else begin
                a_m[26] <= 1;
              end
              //Denormalised Number
              if ($signed(b_e) == -127) begin
                b_e <= -126;
              end else begin
                b_m[26] <= 1;
              end
              state <= ALIGN;
            end
          end

          ALIGN:
          begin
            if ($signed(a_e) > $signed(b_e)) begin
              b_e <= b_e + 1;
              b_m <= b_m >> 1;
              b_m[0] <= b_m[0] | b_m[1];
            end else if ($signed(a_e) < $signed(b_e)) begin
              a_e <= a_e + 1;
              a_m <= a_m >> 1;
              a_m[0] <= a_m[0] | a_m[1];
            end else begin
              state <= ADD_0;
            end
          end

          ADD_0:
          begin
            z_e <= a_e;
            if (a_s == b_s) begin
              pre_sum <= a_m + b_m;
              z_s <= a_s;
            end else begin
              if (a_m >= b_m) begin
                pre_sum <= a_m - b_m;
                z_s <= a_s;
              end else begin
                pre_sum <= b_m - a_m;
                z_s <= b_s;
              end
            end
            state <= ADD_1;
          end

          ADD_1:
          begin
            if (pre_sum[27]) begin
              z_m <= pre_sum[27:4];
              guard <= pre_sum[3];
              round_bit <= pre_sum[2];
              sticky <= pre_sum[1] | pre_sum[0];
              z_e <= z_e + 1;
            end else begin
              z_m <= pre_sum[26:3];
              guard <= pre_sum[2];
              round_bit <= pre_sum[1];
              sticky <= pre_sum[0];
            end
            state <= NORMALISE_1;
          end

          NORMALISE_1:
          begin
            if (z_m[23] == 0 && $signed(z_e) > -126) begin
              z_e <= z_e - 1;
              z_m <= z_m << 1;
              z_m[0] <= guard;
              guard <= round_bit;
              round_bit <= 0;
            end else begin
              state <= NORMALISE_2;
            end
          end

          NORMALISE_2:
          begin
            if ($signed(z_e) < -126) begin
              z_e <= z_e + 1;
              z_m <= z_m >> 1;
              guard <= z_m[0];
              round_bit <= guard;
              sticky <= sticky | round_bit;
            end else begin
              state <= ROUND;
            end
          end

          ROUND:
          begin
            if (guard && (round_bit | sticky | z_m[0])) begin
              z_m <= z_m + 1;
              if (z_m == 24'hffffff) begin
                z_e <=z_e + 1;
              end
            end
            state <= PACK;
          end

          PACK:
          begin
            z[22 : 0] <= z_m[22:0];
            z[30 : 23] <= z_e[7:0] + 127;
            z[31] <= z_s;
            if ($signed(z_e) == -126 && z_m[23] == 0) begin
              z[30 : 23] <= 0;
            end
            if ($signed(z_e) == -126 && z_m[23:0] == 24'h0) begin
              z[31] <= 1'b0; // FIX SIGN BUG: -a + a = +0.
            end
            //if overflow occurs, return inf
            if ($signed(z_e) > 127) begin
              z[22 : 0] <= 0;
              z[30 : 23] <= 255;
              z[31] <= z_s;
            end
            state <= OUT_RDY;
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

