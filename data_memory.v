module data_memory(
                   input clk,
                   input WE,
                   input [3:0] I,
                   input [31:0] A,
                   input [31:0] WD,
                   output [31:0] RD
                   );
   reg [31:0]                    RAM[0:63];
   assign RD = (WE == 0) ? RAM[A] : 32'b0;

   always @(posedge clk) if (WE) RAM[A] <= WD;

endmodule // data_memory
