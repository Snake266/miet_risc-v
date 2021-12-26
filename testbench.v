`timescale 1ns / 1ps
module testbench;
    reg  clock;

    cpu processor(.clk(clock));

    always begin
        #1 clock = ~clock;
    end

    initial begin
        clock = 0;
       $monitor("PC=%d :: Instr=%8h :: x11 = %d",
                 testbench.processor.PC,
                 testbench.processor.inst,
                testbench.processor.rf.RAM[11]);
        #100
        $finish;
    end
   initial begin
      $dumpfile("test.vcd");
      $dumpvars(0, testbench);
   end

endmodule
