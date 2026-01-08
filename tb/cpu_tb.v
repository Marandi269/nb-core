// CPU顶层测试平台
// 测试基本指令执行

`include "rtl/core/defines.v"

`timescale 1ns / 1ps

module cpu_tb;

    reg clk;
    reg rst_n;
    integer i;

    // 实例化CPU
    cpu_single_cycle uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // 时钟生成: 10ns周期 = 100MHz
    always #5 clk = ~clk;

    initial begin
        $display("========== CPU Testbench ==========");

        // 生成波形文件
        $dumpfile("sim/cpu_wave.vcd");
        $dumpvars(0, cpu_tb);

        // 初始化
        clk = 0;
        rst_n = 0;

        // 加载测试程序到指令存储器
        #10;
        load_test_program();

        // 释放复位
        #10 rst_n = 1;
        $display("[INFO] CPU Reset Released");

        // 运行100个时钟周期
        #1000;

        // 检查结果
        check_results();

        $display("========== CPU Test Complete ==========");
        $finish;
    end

    // 加载测试程序
    task load_test_program;
        begin
            $display("[INFO] Loading test program...");

            // 简单的测试程序 (手工编码)
            // PC=0x80000000开始

            // 地址0: ADDI x1, x0, 10   (x1 = 10)
            uut.u_imem.mem[0] = 32'h00a00093;

            // 地址4: ADDI x2, x0, 20   (x2 = 20)
            uut.u_imem.mem[1] = 32'h01400113;

            // 地址8: ADD x3, x1, x2    (x3 = x1 + x2 = 30)
            uut.u_imem.mem[2] = 32'h002081b3;

            // 地址12: SUB x4, x2, x1   (x4 = x2 - x1 = 10)
            uut.u_imem.mem[3] = 32'h40110233;

            // 地址16: AND x5, x1, x2   (x5 = 10 & 20 = 0)
            uut.u_imem.mem[4] = 32'h0020f2b3;

            // 地址20: OR x6, x1, x2    (x6 = 10 | 20 = 30)
            uut.u_imem.mem[5] = 32'h0020e333;

            // 地址24: XOR x7, x1, x2   (x7 = 10 ^ 20 = 30)
            uut.u_imem.mem[6] = 32'h0020c3b3;

            // 地址28: SLT x8, x1, x2   (x8 = (10 < 20) = 1)
            uut.u_imem.mem[7] = 32'h0020a433;

            // 其余填充NOP
            for (i = 8; i < 2048; i = i + 1) begin
                uut.u_imem.mem[i] = 32'h00000013;  // ADDI x0, x0, 0 (NOP)
            end

            $display("[INFO] Test program loaded");
        end
    endtask

    // 检查结果
    task check_results;
        begin
            $display("[INFO] Checking results...");

            // 检查寄存器值
            if (uut.u_regfile.regs[1] == 64'd10)
                $display("[PASS] x1 = 10");
            else
                $display("[FAIL] x1 = %0d (expected 10)", uut.u_regfile.regs[1]);

            if (uut.u_regfile.regs[2] == 64'd20)
                $display("[PASS] x2 = 20");
            else
                $display("[FAIL] x2 = %0d (expected 20)", uut.u_regfile.regs[2]);

            if (uut.u_regfile.regs[3] == 64'd30)
                $display("[PASS] x3 = 30 (ADD)");
            else
                $display("[FAIL] x3 = %0d (expected 30)", uut.u_regfile.regs[3]);

            if (uut.u_regfile.regs[4] == 64'd10)
                $display("[PASS] x4 = 10 (SUB)");
            else
                $display("[FAIL] x4 = %0d (expected 10)", uut.u_regfile.regs[4]);

            if (uut.u_regfile.regs[5] == 64'd0)
                $display("[PASS] x5 = 0 (AND)");
            else
                $display("[FAIL] x5 = %0d (expected 0)", uut.u_regfile.regs[5]);

            if (uut.u_regfile.regs[6] == 64'd30)
                $display("[PASS] x6 = 30 (OR)");
            else
                $display("[FAIL] x6 = %0d (expected 30)", uut.u_regfile.regs[6]);

            if (uut.u_regfile.regs[7] == 64'd30)
                $display("[PASS] x7 = 30 (XOR)");
            else
                $display("[FAIL] x7 = %0d (expected 30)", uut.u_regfile.regs[7]);

            if (uut.u_regfile.regs[8] == 64'd1)
                $display("[PASS] x8 = 1 (SLT)");
            else
                $display("[FAIL] x8 = %0d (expected 1)", uut.u_regfile.regs[8]);
        end
    endtask

    // 超时保护
    initial begin
        #10000;
        $display("[ERROR] Simulation timeout");
        $finish;
    end

endmodule
