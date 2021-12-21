module cpu (
    input  clk
            );

   wire [31:0] inst;

   wire [31:0] imm_i = {{20{inst[31]}}, inst[31:20]};
   wire [31:0] imm_s = {{20{inst[31]}}, inst[31:25], inst[11:7]};
   wire [31:0] imm_j = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21]};
   wire [31:0] imm_b = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8]};

   instruction_memory  im(.A(PC),
                           .RD(Instr)
                           );
   wire [31:0] i;
   wire        rfwe, jal, jarl, br, ws, mwe;
   wire [4:0]  aop;
   wire [1:0]  srcA;
   wire [2:0]  srcB;
   riscv_decoder decoder(.fetched_instr_i(inst),
                         .ex_op_a_sel_o(srcA),
                         .ex_op_b_sel_o(srcB),
                         .alu_op_o(aop),
                         .mem_req_o(i[3]),
                         .mem_we_o(mwe),
                         .mem_size_o(i[2:0]),
                         .gpr_we_a_o(rfwe),
                         .wb_src_sel_o(ws),
                         .branch_o(br),
                         .jal_o(jal),
                         .jarl_o(jarl)
                         );


   wire [31:0] torf;
   wire [31:0] rd1, rd2;
   register_file rf(.CLK(clk),
                    .WE3(rfwe),
                    .A1(Instr[19:15]),
                    .A2(Instr[24:20]),
                    .A3(Instr[11:7]),
                    .RD1(rd1),
                    .RD2(rd2),
                    .WD3(torf)
                    );

   wire        comp;
   reg [31:0]  ch1, ch2;
   always @ (*) begin
      case (srcA)
        2'd0: ch1 <= rd1;
        2'd1: ch1 <= PC;
        2'd2:ch1 <= 0;
      endcase // case (srcA)
      case(srcB)
        3'd0: ch2 <= rd2;
        3'd1: ch2 <= imm_i;
        3'd2: ch2 <= {inst[31:12], 1'b0};
        3'd3: ch2 <= imm_s;
        3'd4: ch2 <= 32'd4;
      endcase // case (srcB)
   end // always @ (*)
   wire [31:0] res;
   ALU ariphmetic_logic(
                        .ALUOp(aop),
                        .A(ch1),
                        .B(ch2),
                        .Result(res),
                        .Flag(comp)
                        );
   //TODO: Data memory

   reg [31:0]  PC = 0;
   always @(posedge clk) PC <= topc;
   wire        control = jal | (comp & br);
   wire [31:0] immxsel = (br) ? imm_b : imm_j;
   wire [31:0] topcsum = (control) ? immxsel : 32'd4;
   wire [31:0] pcsumres = PC + topcsum;
   wire [31:0] topc = (jalr) ? rd1 : pcsumres;
endmodule
