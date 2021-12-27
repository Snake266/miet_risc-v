module miriscv_core(
            input         clk_i,
            input         arstn_i,

            input [31:0]  instr_rdata_i,
            output [31:0] instr_addr_o,

            input [31:0]  data_rdata_i,
            output        data_req_o,
            output        data_we_o,
            output [3:0]  data_be_o,
            output [31:0] data_addr_o,
            output [31:0] data_wdata_o
            );

   assign     instr_addr_o = PC;
   wire [31:0]     instr = instr_rdata_i;

   // SE
   wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
   wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
   wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
   wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};


   // Instrruction decoder
   wire [3:0]  i;
   wire        rfwe, jal, jalr, br, ws, stall, enpc;
   wire [4:0]  aop;
   wire [1:0]  srcA;
   wire [2:0]  srcB;
   riscv_decoder decoder(.fetched_instr_i(instr),
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
                         .jalr_o(jalr),
                         .stall(stall),
                         .enpc(enpc)
                         );


   // register file
   wire [31:0] torf;
   wire [31:0] rd1, rd2;
   register_file rf(.CLK(clk),
                    .WE3(rfwe),
                    .A1(instr[19:15]),
                    .A2(instr[24:20]),
                    .A3(instr[11:7]),
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
        3'd2: ch2 <= {instr[31:12], 1'b0};
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

   // LSU modul
   wire [31:0] mem;
   miriscv_lsu lsu(
                   .clk_i(clk_i),
                   .arstn_i(arstn_i),

                   .lsu_addr_i(res),
                   .lsu_we_i(mwe),
                   .lsu_size_i(i[2:0]),
                   .lsu_data_i(rd2),
                   .lsu_req_i(i[3]),
                   .lsu_stall_req_o(stall),
                   .lsu_data_o(mem),

                   .data_rdata_i(data_rdata_i),
                   .data_req_o(data_req_o),
                   .data_we_o(data_we_o),
                   .data_be_o(data_be_o),
                   .data_addr_o(data_addr_o),
                   .data_wdata_o(data_wdata_o)
                   );

   assign torf = (ws) ? mem : res;

   reg [31:0]  PC = 0; // program counter

   always @(posedge clk_i) begin
      if(~arstn_i) PC <= 0;
      else if(enpc) PC <= topc;
   end

   wire        control = jal | (comp & br);
   wire [31:0] immxsel = (br) ? imm_b : imm_j;
   wire [31:0] topcsum = (control) ? immxsel : 32'd4;
   wire [31:0] pcsumres = PC + topcsum;
   wire [31:0] topc = (jalr) ? rd1 : pcsumres;
endmodule
