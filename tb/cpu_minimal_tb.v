// 最小化CPU测试
// 测试ADDI指令

`timescale 1ns / 1ps

module cpu_minimal_tb;

    reg clk, rst_n;

    cpu_single_cycle uut (.clk(clk), .rst_n(rst_n));

    always #5 clk = ~clk;

    initial begin
        $display("=== Minimal CPU Test ===");
        clk = 0; rst_n = 0;

        // ADDI x1, x0, 42
        uut.u_imem.mem[0] = 32'h02a00093;

        #20 rst_n = 1;
        #100;

        $display("x1 = %d (expected 42)", uut.u_regfile.regs[1]);

        if (uut.u_regfile.regs[1] == 42)
            $display("[PASS]");
        else
            $display("[FAIL]");

        $finish;
    end

endmodule
