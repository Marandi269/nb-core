// Simplified Verilator Testbench
// Just runs the CPU and reports completion

#include <iostream>
#include <verilated.h>
#include "Vcpu_single_cycle.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vcpu_single_cycle* cpu = new Vcpu_single_cycle;

    std::cout << "=== Verilator CPU Compilation Test ===" << std::endl;
    std::cout << "CPU module instantiated successfully!" << std::endl;

    // 初始化
    cpu->clk = 0;
    cpu->rst_n = 0;

    // 复位几个周期
    for (int i = 0; i < 5; i++) {
        cpu->clk = 0;
        cpu->eval();
        cpu->clk = 1;
        cpu->eval();
    }

    cpu->rst_n = 1;

    // 运行100个时钟周期
    std::cout << "Running 100 clock cycles..." << std::endl;
    for (int cycle = 0; cycle < 100; cycle++) {
        cpu->clk = 0;
        cpu->eval();
        cpu->clk = 1;
        cpu->eval();

        if (cycle % 10 == 0) {
            std::cout << "  Cycle " << cycle << std::endl;
        }
    }

    std::cout << "\n[SUCCESS] CPU simulation completed!" << std::endl;
    std::cout << "Verilator compilation and execution successful." << std::endl;

    cpu->final();
    delete cpu;

    return 0;
}
