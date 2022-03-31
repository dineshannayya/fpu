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
////  IEEE Floating Point Adder (Double Precision)                ////
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
module fpu_dp_add(
        input  logic          clk,
        input  logic          rst_n,
        input  logic [63:0]   din1,
        input  logic [63:0]   din2,
        input  logic          dval,
        output logic [63:0]   result,
        output logic          rdy
);



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

  reg       [63:0] a, b, z;
  reg       [55:0] a_m, b_m;
  reg       [52:0] z_m;
  reg       [12:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [56:0] sum;

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
           a_m <= {a[51 : 0], 3'd0};
           b_m <= {b[51 : 0], 3'd0};
           a_e <= a[62 : 52] - 1023;
           b_e <= b[62 : 52] - 1023;
           a_s <= a[63];
           b_s <= b[63];
           state <= SPECIAL_CASES;
         end

         SPECIAL_CASES:
         begin
           //if a is NaN or b is NaN return NaN 
           if ((a_e == 1024 && a_m != 0) || (b_e == 1024 && b_m != 0)) begin
             z[63] <= 1;
             z[62:52] <= 2047;
             z[51] <= 1;
             z[50:0] <= 0;
             state <= OUT_RDY;
           //if a is inf return inf
           end else if (a_e == 1024) begin
             z[63] <= a_s;
             z[62:52] <= 2047;
             z[51:0] <= 0;
             //if a is inf and signs don't match return nan
             if ((b_e == 1024) && (a_s != b_s)) begin
                 z[63] <= 1;
                 z[62:52] <= 2047;
                 z[51] <= 1;
                 z[50:0] <= 0;
             end
             state <= OUT_RDY;
           //if b is inf return inf
           end else if (b_e == 1024) begin
             z[63] <= b_s;
             z[62:52] <= 2047;
             z[51:0] <= 0;
             state <= OUT_RDY;
           //if a is zero return b
           end else if ((($signed(a_e) == -1023) && (a_m == 0)) && (($signed(b_e) == -1023) && (b_m == 0))) begin
             z[63] <= a_s & b_s;
             z[62:52] <= b_e[10:0] + 1023;
             z[51:0] <= b_m[55:3];
             state <= OUT_RDY;
           //if a is zero return b
           end else if (($signed(a_e) == -1023) && (a_m == 0)) begin
             z[63] <= b_s;
             z[62:52] <= b_e[10:0] + 1023;
             z[51:0] <= b_m[55:3];
             state <= OUT_RDY;
           //if b is zero return a
           end else if (($signed(b_e) == -1023) && (b_m == 0)) begin
             z[63] <= a_s;
             z[62:52] <= a_e[10:0] + 1023;
             z[51:0] <= a_m[55:3];
             state <= OUT_RDY;
           end else begin
             //Denormalised Number
             if ($signed(a_e) == -1023) begin
               a_e <= -1022;
             end else begin
               a_m[55] <= 1;
             end
             //Denormalised Number
             if ($signed(b_e) == -1023) begin
               b_e <= -1022;
             end else begin
               b_m[55] <= 1;
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
             sum <= {1'd0, a_m} + b_m;
             z_s <= a_s;
           end else begin
             if (a_m > b_m) begin
               sum <= {1'd0, a_m} - b_m;
               z_s <= a_s;
             end else begin
               sum <= {1'd0, b_m} - a_m;
               z_s <= b_s;
             end
           end
           state <= ADD_1;
         end

         ADD_1:
         begin
           if (sum[56]) begin
             z_m <= sum[56:4];
             guard <= sum[3];
             round_bit <= sum[2];
             sticky <= sum[1] | sum[0];
             z_e <= z_e + 1;
           end else begin
             z_m <= sum[55:3];
             guard <= sum[2];
             round_bit <= sum[1];
             sticky <= sum[0];
           end
           state <= NORMALISE_1;
         end

         NORMALISE_1:
         begin
           if (z_m[52] == 0 && $signed(z_e) > -1022) begin
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
           if ($signed(z_e) < -1022) begin
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
             if (z_m == 53'h1fffffffffffff) begin
               z_e <=z_e + 1;
             end
           end
           state <= PACK;
         end

         PACK:
         begin
           z[51 : 0] <= z_m[51:0];
           z[62 : 52] <= z_e[10:0] + 1023;
           z[63] <= z_s;
           if ($signed(z_e) == -1022 && z_m[52] == 0) begin
             z[62 : 52] <= 0;
           end
           if ($signed(z_e) == -1022 && z_m[52:0] == 0) begin
              z[63] <= 0;
           end

           //if overflow occurs, return inf
           if ($signed(z_e) > 1023) begin
             z[51 : 0] <= 0;
             z[62 : 52] <= 2047;
             z[63] <= z_s;
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

