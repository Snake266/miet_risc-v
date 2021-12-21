`include "miriscv_defines.v"

module riscv_decoder(
                     input [31:0]                   fetched_instr_i, // inst to decode that comes out of mem
                     output reg [1:0]               ex_op_a_sel_o, // Control signal of MUX to choose first op of ALU
                     output reg [2:0]               ex_op_b_sel_o, // Control signal of MUX to choose second op of ALU
                     output reg [`ALU_OP_WIDTH-1:0] alu_op_o, // ALU operation
                     output reg                     mem_req_o, // Request of mem access
                     output reg                     mem_we_o, // Write enable
                     output reg [2:0]               mem_size_o, // Control signal that set size of WORD at write-read in mem
                     output reg                     gpr_we_a_o, // Signal that allow writing in rf
                     output reg                     wb_src_sel_o, // Control signal of MUX to control data selection, that will be writed in rf
                     output reg                     illegal_instr_o, // Signal of incorrect instruction
                     output reg                     branch_o, // Signal of conditional jump
                     output reg                     jal_o, // Signal of unconditional jump "jal"
                     output reg                     jalr_o          // Signal of unconditional jump "jalr"
                     );

   wire [6:0]                                       op_code = fetched_instr_i[6:0];
   wire [2:0]                                       funct3 = fetched_instr_i[14:12];
   wire [6:0]                                       funct7 = fetched_instr_i[31:25];


   always @ (*) begin
      if(op_code[1:0] == 2'b11) begin
         case (op_code[6:2])
           `OP_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 0;
              ex_op_b_sel_o <= 0;
              case (funct7)
                7'h0: begin
                   case (funct3)
                     3'h0: begin
                        alu_op_o <= `ALU_ADD;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end

                     3'h1: begin
                        alu_op_o <= `ALU_SLL;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end

                     3'h2: begin
                        alu_op_o <= `ALU_SLTS;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end

                     3'h3: begin
                        alu_op_o <= `ALU_SLTU;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end

                     3'h4: begin
                        alu_op_o <= `ALU_XOR;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end

                     3'h5: begin
                        alu_op_o <= `ALU_SRL;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end

                     3'h6: begin
                        alu_op_o <= `ALU_OR;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end

                     3'h7: begin
                        alu_op_o <= `ALU_AND;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end
                   endcase // case (funct3)

                end
                7'h20: begin
                   case (funct3)
                     3'h0: begin
                        alu_op_o <= `ALU_SUB;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end
                     3'h5: begin
                        alu_op_o <= `ALU_SRA;
                        gpr_we_a_o <= 1;
                        illegal_instr_o <= 0;
                     end
                     default: begin
                        alu_op_o <= 0;
                        gpr_we_a_o <= 0;
                        illegal_instr_o <= 1;
                     end
                   endcase // case (funct3)
                end // case: 7'h20

                default: begin
                   alu_op_o <= 0;
                   gpr_we_a_o <= 0;
                   illegal_instr_o <= 1;
                end
              endcase // case (funct7)
           end // case: `OP_OPCODE

           `OP_IMM_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 0;
              case (funct3)
                3'h0: begin
                   alu_op_o <= `ALU_ADD;
                   gpr_we_a_o <= 1;
                   ex_op_b_sel_o <= 1;
                   illegal_instr_o <= 0;
                end

                3'h1: begin
                   case (funct7)
                     7'h0: begin
                        alu_op_o <= `ALU_SLL;
                        gpr_we_a_o <= 1;
                        ex_op_b_sel_o <= 1;
                        illegal_instr_o <= 0;
                     end
                     default: begin
                        alu_op_o <= 0;
                        gpr_we_a_o <= 0;
                        ex_op_b_sel_o <= 0;
                        illegal_instr_o <= 1;
                     end
                   endcase // case (funct7)
                end // case: 3'h1

                3'h2: begin
                   alu_op_o <= `ALU_SLTS;
                   gpr_we_a_o <= 1;
                   ex_op_b_sel_o <= 1;
                   illegal_instr_o <= 0;
                end

                3'h3: begin
                   alu_op_o <= `ALU_SLTU;
                   gpr_we_a_o <= 1;
                   ex_op_b_sel_o <= 1;
                   illegal_instr_o <= 0;
                end

                3'h4: begin
                   alu_op_o <= `ALU_XOR;
                   gpr_we_a_o <= 1;
                   ex_op_b_sel_o <= 1;
                   illegal_instr_o <= 0;
                end

                3'h5: begin
                   case (funct7)
                     7'h0: begin
                        alu_op_o <= `ALU_SRL;
                        gpr_we_a_o <= 1;
                        ex_op_b_sel_o <= 1;
                        illegal_instr_o <= 0;
                     end
                     7'h20: begin
                        alu_op_o <= `ALU_SRA;
                        gpr_we_a_o <= 1;
                        ex_op_b_sel_o <= 1;
                        illegal_instr_o <= 0;
                     end
                     default: begin
                        alu_op_o <= 0;
                        gpr_we_a_o <= 0;
                        ex_op_b_sel_o <= 0;
                        illegal_instr_o <= 1;
                     end
                   endcase // case (funct7)

                end

                3'h6: begin
                   alu_op_o <= `ALU_OR;
                   gpr_we_a_o <= 1;
                   ex_op_b_sel_o <= 1;
                   illegal_instr_o <= 0;
                end

                3'h7: begin
                   alu_op_o <= `ALU_AND;
                   gpr_we_a_o <= 1;
                   ex_op_b_sel_o <= 1;
                   illegal_instr_o <= 0;
                end
              endcase // case (funct3)
           end // case: `OP_IMM_OPCODE

           `LOAD_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              mem_we_o <= 0;
              ex_op_a_sel_o <= 0;

              case (funct3)
                4'h0: begin
                   mem_size_o <= 3'd0;
                   wb_src_sel_o <= 1;
                   gpr_we_a_o <= 1;
                   mem_req_o <= 1;
                   ex_op_b_sel_o <= 1;
                   alu_op_o <= `ALU_ADD;
                   illegal_instr_o <= 0;
                end

                4'h1: begin
                   mem_size_o <= 3'd1;
                   wb_src_sel_o <= 1;
                   gpr_we_a_o <= 1;
                   mem_req_o <= 1;
                   ex_op_b_sel_o <= 1;
                   alu_op_o <= `ALU_ADD;
                   illegal_instr_o <= 0;
                end

                4'h2: begin
                   mem_size_o <= 3'd2;
                   wb_src_sel_o <= 1;
                   gpr_we_a_o <= 1;
                   mem_req_o <= 1;
                   ex_op_b_sel_o <= 1;
                   alu_op_o <= `ALU_ADD;
                   illegal_instr_o <= 0;
                end

                4'h4: begin
                   mem_size_o <= 3'd4;
                   wb_src_sel_o <= 1;
                   gpr_we_a_o <= 1;
                   mem_req_o <= 1;
                   ex_op_b_sel_o <= 1;
                   alu_op_o <= `ALU_ADD;
                   illegal_instr_o <= 0;
                end

                4'h5: begin
                   mem_size_o <= 3'd5;
                   wb_src_sel_o <= 1;
                   gpr_we_a_o <= 1;
                   mem_req_o <= 1;
                   ex_op_b_sel_o <= 1;
                   alu_op_o <= `ALU_ADD;
                   illegal_instr_o <= 0;
                end
                default: begin
                   mem_size_o <= 0;
                   wb_src_sel_o <= 0;
                   gpr_we_a_o <= 0;
                   mem_req_o <= 0;
                   ex_op_b_sel_o <= 0;
                   alu_op_o <= 0;
                   illegal_instr_o <= 1;
                end
              endcase // case (funct3)
           end // case: `LOAD_OPCODE

           `STORE_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              gpr_we_a_o <= 0;
              ex_op_a_sel_o <= 0;
              case (funct3)
                4'h0: begin
                   alu_op_o <= `ALU_ADD;
                   mem_size_o <= 3'd0;
                   mem_we_o <= 1;
                   mem_req_o <= 1;
                   ex_op_b_sel_o <= 3;
                   illegal_instr_o <= 0;
                end

                4'h1: begin
                   alu_op_o <= `ALU_ADD;
                   mem_size_o <= 3'd1;
                   mem_we_o <= 1;
                   mem_req_o <= 1;
                   ex_op_b_sel_o <= 3;
                   illegal_instr_o <= 0;
                end

                4'h2: begin
                   alu_op_o <= `ALU_ADD;
                   mem_size_o <= 3'd2;
                   mem_we_o <= 1;
                   mem_req_o <= 1;
                   ex_op_b_sel_o <= 3;
                   illegal_instr_o <= 0;
                end

                default: begin
                   alu_op_o <= 0;
                   mem_size_o <= 0;
                   mem_we_o <= 0;
                   mem_req_o <= 0;
                   ex_op_b_sel_o <= 0;
                   illegal_instr_o <= 1;
                end
              endcase // case (funct3)
           end // case: `STORE_OPCODE

           `BRANCH_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              wb_src_sel_o <= 0;
              gpr_we_a_o <= 0;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 0;
              ex_op_b_sel_o <= 0;
              case (funct3)
                4'h0: begin
                   alu_op_o <= `ALU_EQ;
                   branch_o <= 1;
                   illegal_instr_o <= 0;
                end

                4'h1: begin
                   alu_op_o <= `ALU_NE;
                   branch_o <= 1;
                   illegal_instr_o <= 0;
                end

                4'h4: begin
                   alu_op_o <= `ALU_LTS;
                   branch_o <= 1;
                   illegal_instr_o <= 0;
                end

                4'h5: begin
                   alu_op_o <= `ALU_GES;
                   branch_o <= 1;
                   illegal_instr_o <= 0;
                end
                4'h6: begin
                   alu_op_o <= `ALU_LTU;
                   branch_o <= 1;
                   illegal_instr_o <= 0;
                end

                4'h7: begin
                   alu_op_o <= `ALU_GEU;
                   branch_o <= 1;
                   illegal_instr_o <= 0;
                end

                default: begin
                   alu_op_o <= 0;
                   branch_o <= 0;
                   illegal_instr_o <= 1;
                end
              endcase // case (funct3)
           end // case: `BRANCH_OPCODE

           `JAL_OPCODE: begin
              jal_o <= 1;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              gpr_we_a_o <= 1;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 1;
              ex_op_b_sel_o <= 4;
              alu_op_o <= 0;
              illegal_instr_o <= 0;
           end // case: `JAL_OPCODE

           `JALR_OPCODE: begin
              jal_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              alu_op_o <= 0;
              case (funct3)
                3'h0: begin
                   jalr_o <= 1;
                   ex_op_a_sel_o <= 1;
                   ex_op_b_sel_o <= 4;
                   gpr_we_a_o <= 1;
                   illegal_instr_o <= 0;
                end

                default: begin
                   jalr_o <= 0;
                   ex_op_a_sel_o <= 0;
                   ex_op_b_sel_o <= 0;
                   gpr_we_a_o <= 0;
                   illegal_instr_o <= 1;
                end
              endcase // case (funct3)
           end // case: `JALR_OPCODE

           `LUI_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              gpr_we_a_o <= 1;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 2;
              ex_op_b_sel_o <= 2;
              alu_op_o <= `ALU_ADD;
              illegal_instr_o <= 0;
           end // case: `LUI_OPCODE

           `AUIPC_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              gpr_we_a_o <= 1;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 1;
              ex_op_b_sel_o <= 2;
              alu_op_o <= `ALU_ADD;
              illegal_instr_o <= 0;
           end // case: `AUIPC_OPCODE

           `SYSTEM_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              gpr_we_a_o <= 0;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 0;
              ex_op_b_sel_o <= 0;
              alu_op_o <= 0;
              illegal_instr_o <= 0;
           end // case: `SYSTEM_OPCODE

           `MISC_MEM_OPCODE: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              gpr_we_a_o <= 0;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 0;
              ex_op_b_sel_o <= 0;
              alu_op_o <= 0;
              illegal_instr_o <= 0;
           end // case: `MISC_MEM_OPCODE

           default: begin
              jal_o <= 0;
              jalr_o <= 0;
              branch_o <= 0;
              wb_src_sel_o <= 0;
              gpr_we_a_o <= 0;
              mem_we_o <= 0;
              mem_req_o <= 0;
              mem_size_o <= 0;
              ex_op_a_sel_o <= 0;
              ex_op_b_sel_o <= 0;
              alu_op_o <= 0;
              illegal_instr_o <= 1;
           end // case: default

         endcase // case (op_code)
      end // if (op_code[1:0] = 2'b11)
      else begin
         jal_o <= 0;
         jalr_o <= 0;
         branch_o <= 0;
         wb_src_sel_o <= 0;
         gpr_we_a_o <= 0;
         mem_we_o <= 0;
         mem_req_o <= 0;
         mem_size_o <= 0;
         ex_op_a_sel_o <= 0;
         ex_op_b_sel_o <= 0;
         alu_op_o <= 0;
         illegal_instr_o <= 1;
      end // else: !if(op_code[1:0] = 2'b11)
   end
endmodule // riscv_decoder
