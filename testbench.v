`timescale 1ns / 1ps
module testbench;
    reg  [31:0] SW;
    wire [31:0] out_res;
    reg  reset, clock;

    cpu processor(.clk(clock), .rst(reset), .OUT(out_res), .IN(SW));

    always begin
        #1 clock = ~clock;
    end

    initial begin
        clock = 0;
        SW = 32'd4;
        $monitor("PC=%d :: Instr=%32b :: OUT = %d", testbench.processor.PC, testbench.processor.Instr, out_res);
        #100
        $finish;
    end
   initial begin
      $dumpfile("test.vcd");
      $dumpvars(0, testbench);
   end


endmodule
