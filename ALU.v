`timescale 1ns / 1ps
`include "miriscv_defines.v"

module ALU(
           input [31:0]      A,
           input [31:0]      B,
           input [4:0]       ALUOp,
           output reg [31:0] Result,
           output reg Flag
           );
   always @(*) begin
      case(ALUOp)
        `ALU_ADD: begin
           Result <= A + B;
           Flag <= 0;
        end
        `ALU_SUB: begin
           Result <= A + ~B + 1;
           Flag <= 0;
        end
        `ALU_SLL: begin
           Result <= A << B;
           Flag <= 0;
        end
        `ALU_SLTS: begin
           Result <= $signed(A) < $signed(B);
           Flag <= 0;
        end
        `ALU_SLTU: begin
           Result <= (A < B);
           Flag <= 0;
        end
        `ALU_XOR: begin
           Result <= A ^ B;
           Flag <= 0;
        end
        `ALU_SRL: begin
           Result <= A >> B;
           Flag <= 0;
        end
        `ALU_SRA: begin
           Result <= $signed(A) >>> $signed (B);
           Flag <= 0;
        end
        `ALU_OR: begin
           Result <= A | B;
           Flag <= 0;
        end
        `ALU_AND: begin
           Result <= A & B;
           Flag <= 0;
        end
        `ALU_EQ: begin
           Result <= A == B;
           Flag <= A == B;
        end
        `ALU_NE: begin
           Result <= A != B;
           Flag <= A != B;
        end
        `ALU_LTS: begin
           Result <= ($signed(A) < $signed(B));
           Flag <= ($signed(A) < $signed(B));
        end
        `ALU_GES: begin
           Result <= ($signed(A) >= $signed(B));
           Flag <= ($signed(A) >= $signed(B));
        end
        `ALU_LTU: begin
           Result <= (A < B);
           Flag <= (A < B);
        end
        `ALU_GEU: begin
           Result <= (A >= B);
           Flag <= (A >= B);
        end
      endcase // case (sel)
   end
endmodule // ALU
