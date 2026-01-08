// Verilator C++ Testbench for CPU
#include <iostream>
#include <verilated.h>
#include "Vcpu_single_cycle.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    // 创建CPU实例
    Vcpu_single_cycle* cpu = new Vcpu_single_cycle;

    std::cout << "=== Verilator CPU Test ===" << std::endl;

    // 初始化
    cpu->clk = 0;
    cpu->rst_n = 0;

    // 加载测试程序到指令内存
    // ADDI x1, x0, 10
    cpu->u_imem->mem[0] = 0x00a00093;
    // ADDI x2, x0, 20
    cpu->u_imem->mem[1] = 0x01400113;
    // ADD x3, x1, x2
    cpu->u_imem->mem[2] = 0x002081b3;

    // 释放复位
    for (int i = 0; i < 5; i++) {
        cpu->clk = 0;
        cpu->eval();
        cpu->clk = 1;
        cpu->eval();
    }

    cpu->rst_n = 1;

    // 运行40个时钟周期
    for (int cycle = 0; cycle < 40; cycle++) {
        // 下降沿
        cpu->clk = 0;
        cpu->eval();

        // 上升沿
        cpu->clk = 1;
        cpu->eval();
    }

    // 检查结果
    std::cout << "\n=== Results ===" << std::endl;
    std::cout << "x1 = " << cpu->u_regfile->regs[1]
              << " (expected 10)" << std::endl;
    std::cout << "x2 = " << cpu->u_regfile->regs[2]
              << " (expected 20)" << std::endl;
    std::cout << "x3 = " << cpu->u_regfile->regs[3]
              << " (expected 30)" << std::endl;

    bool passed = (cpu->u_regfile->regs[1] == 10 &&
                   cpu->u_regfile->regs[2] == 20 &&
                   cpu->u_regfile->regs[3] == 30);

    if (passed) {
        std::cout << "\n[PASS] CPU test passed!" << std::endl;
    } else {
        std::cout << "\n[FAIL] CPU test failed!" << std::endl;
    }

    // 清理
    cpu->final();
    delete cpu;

    return passed ? 0 : 1;
}
