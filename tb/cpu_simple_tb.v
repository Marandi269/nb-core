// 简化的CPU测试平台
// 只测试几条基本指令

`include "rtl/core/defines.v"

`timescale 1ns / 1ps

module cpu_simple_tb;

    reg clk;
    reg rst_n;

    // 实例化CPU
    cpu_single_cycle uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // 时钟生成
    always #5 clk = ~clk;

    initial begin
        $display("========== Simple CPU Test ==========");

        // 初始化
        clk = 0;
        rst_n = 0;

        // 加载简单程序
        // ADDI x1, x0, 10
        uut.u_imem.mem[0] = 32'h00a00093;
        // ADDI x2, x0, 20
        uut.u_imem.mem[1] = 32'h01400113;
        // ADD x3, x1, x2
        uut.u_imem.mem[2] = 32'h002081b3;

        // 释放复位
        #20 rst_n = 1;

        // 运行40个周期
        #400;

        // 检查结果
        $display("\n===== Results =====");
        $display("x1 = %d (expected 10)", uut.u_regfile.regs[1]);
        $display("x2 = %d (expected 20)", uut.u_regfile.regs[2]);
        $display("x3 = %d (expected 30)", uut.u_regfile.regs[3]);

        if (uut.u_regfile.regs[1] == 10 &&
            uut.u_regfile.regs[2] == 20 &&
            uut.u_regfile.regs[3] == 30) begin
            $display("\n[PASS] CPU basic test passed!");
        end else begin
            $display("\n[FAIL] CPU basic test failed!");
        end

        $finish;
    end

endmodule
