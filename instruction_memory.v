module instruction_memory(
                          input [31:0]   A,
                          output [31:0] RD
                          );
   reg [31:0]                           RAM[0:255];
   assign RD = RAM[A[9:2]];

   initial $readmemh("binfile.mem", RAM);
endmodule
