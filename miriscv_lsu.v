`include "miriscv_defines.v"

module miriscv_lsu (
                    input         clk_i,
                    input         arstn_i, // reset of internal registers

                    // core protocol
                    input [31:0]  lsu_addr_i, //
                    input         lsu_we_i, //flag, 1 -- need to write
                    input [2:0]   lsu_size_i, // size of data to proccess
                    input [31:0]  lsu_data_i, // data
                    input         lsu_req_i, // flag, 1 -- need to read
                    output        lsu_stall_req_o, // used as !enable PC
                    output [31:0] lsu_data_o, // data out of memory =

                    // memory protocol
                    input [31:0]  data_rdata_i, // requested data
                    output        data_req_o, // flag, 1 -- apply to memoty
                    output        data_we_o, // flag, request to write or read: 0 to read, 1 to write
                    output [3:0]  data_be_o, // to what bytes to apply
                    output [31:0] data_addr_o, // adress to apply
                    output [31:0] data_wdata_o // data that will be writed
                    );
   // contains a last state of request to stop PC at positve edge of clk
   reg                            last_pos_stall;

   assign lsu_stall_req_o = lsu_req_i && ~last_pos_stall;
   always @(posedge clk_i) last_pos_stall <= lsu_stall_req_o;

   // offset to write in a 4-byte cell
   wire [1:0]                     byteoffset = lsu_addr_i[1:0];

   always @(*) begin
      // reset
      if(~arstn_i) begin
         lsu_data_o <= 0;
         last_pos_stall <= 0;
      end

      if(lsu_stall_req_o) begin
         case(lsu_size_i) // choose a size of transmitted data
           `LDST_B: begin // signed 8-bit
              case(byteoffset)
                2'b00: data_be_o <= 4'b0001; // write to first byte
                2'b01: data_be_o <= 4'b0010; // write to second byte
                2'b10: data_be_o <= 4'b0100; // write to third byte
                2'b11: data_be_o <= 4'b1000; // write to fourth byte
              endcase // case (byteoffset)

              // write data
              data_wdata_o <= { 4{lsu_data_i[7:0]} }; // 4 x 8 = 32
           end // case: `LDST_B
           `LDST_H: begin // signed 16-bit (half of a word)
              case(byteoffset)
                2'b00: data_be_o <= 4'b0011; // write to first two bytes
                2'b10: data_be_o <= 4'b1100; // write to last two bytes
              endcase // case (byteoffset)
              // write data
              data_wdata_o <= { 2{lsu_data_i[15:0]} }; // 2x16 = 32 - half word
           end
           `LDST_H: begin // 32-bit (word)
              data_be_o <= 4'b1111;
              data_wdata_o <= lsu_data_i[31:0];
           end
         endcase // case (lsu_size_i)

         // just sending flags without any changes
         data_we_o <= lsu_we_i;
         data_req_o <= lsu_req_i;
         // and adress
         data_addr_o <= lsu_addr_i;
      end // if (lsu_stall_req_o)
      else begin
         case(lsu_size_i)
           `LDST_B: begin // signed 8-bit (byte)
              case(byteoffset)
                2'b00: lsu_data_o <= { {24{data_rdata_i[7]}}, data_rdata_i[7:0] };
                2'b01: lsu_data_o <= { {24{data_rdata_i[15]}}, data_rdata_i[15:8] };
                2'b10: lsu_data_o <= { {24{data_rdata_i[23]}}, data_rdata_i[23:16] };
                2'b11: lsu_data_o <= { {24{data_rdata_i[31]}}, data_rdata_i[31:24] };
              endcase // case (byteoffset)
           end
           `LDST_H: begin // signed 16-bit (half word)
              case(byteoffset)
                2'b00: lsu_data_o <= { {16{data_rdata_i[15]}}, data_rdata_i[15:0] };
                2'b10: lsu_data_o <= { {16{data_rdata_i[31]}}, data_rdata_i[31:16] };
              endcase // case (byteoffset)
           end
           `LSDT_W: begin // 32-bit (word)
              lsu_data_o <= data_rdata_i[31:0];
           end
           `LDST_BU: begin // unsigned 8-bit with ZE to 32-bit
              case(byteoffset)
                2'b00: lsu_data_o <= {24'b0, data_rdata_i[7:0]};
                2'b01: lsu_data_o <= {24'b0, data_rdata_i[15:8]};
                2'b10: lsu_data_o <= {24'b0, data_rdata_i[23:16]};
                2'b11: lsu_data_o <= {24'b0, data_rdata_i[31:24]};
              endcase // case (byteoffset)
           end
           LDST_HU: begin // unsigned 16-bit with ZE to 32-bit
              case(byteoffset)
                2'b00: lsu_data_o <= {16'b0, data_rdata_i[15:0]};
                2'b10: lsu_data_o <= {16'b0, data_rdata_i[31:16]};
              endcase // case (byteoffset)
           end
         endcase // case (lsu_size_i)
         data_we_o <= 0;
         data_req_o <= 0;

      end // else: !if(lsu_stall_req_o)
   end // always


endmodule // miriscv_lsu
