`timescale 1ns / 1ps
module testbench;
    reg  clock;

    cpu processor(.clk(clock));

    always begin
        #1 clock = ~clock;
    end

    initial begin
        clock = 0;
        $monitor("PC=%d :: Instr=%8h ::", testbench.processor.PC, testbench.processor.inst);
        #1000
        $finish;
    end
   initial begin
      $dumpfile("test.vcd");
      $dumpvars(0, testbench);
   end


endmodule
