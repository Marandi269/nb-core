#include <verilated.h>
#if VM_TRACE
#include <verilated_vcd_c.h>
#endif
#include "Vcpu_single_cycle.h"
#include "Vcpu_single_cycle__Syms.h"  // 访问内部信号
#include "elf_loader.h"
#include "uart_sim.h"
#include <iostream>
#include <memory>
#include <cstring>

// UART仿真器
static std::unique_ptr<UARTSim> uart;

// 辅助结构：匹配Vcpu_single_cycle的内存布局以访问vlSymsp
struct Vcpu_single_cycle_accessor {
    VerilatedContext* contextp;
    const char* name_p;
    uint8_t clk;
    uint8_t rst_n;
    // ... 其他成员...
    // vlSymsp通常在固定偏移处，直接通过内存布局访问
    // 这是一个hack但有效
    Vcpu_single_cycle__Syms* vlSymsp;
};

// 辅助函数：访问CPU内部符号表
inline Vcpu_single_cycle__Syms* get_syms(Vcpu_single_cycle* cpu) {
    // 通过内存布局hack访问private成员vlSymsp
    // 注意：这依赖于Verilator生成的类布局
    return reinterpret_cast<Vcpu_single_cycle_accessor*>(cpu)->vlSymsp;
}

// 从ELF加载到指令内存
void load_elf_to_imem(Vcpu_single_cycle* cpu, const ELFLoader& elf) {
    auto* syms = get_syms(cpu);
    // 访问内部imem模块的mem数组
    // cpu->rootp->cpu_single_cycle__DOT__u_imem__DOT__mem

    for (const auto& seg : elf.get_segments()) {
        uint64_t addr = seg.vaddr;
        std::cout << "Loading segment at 0x" << std::hex << addr
                  << " (" << std::dec << seg.memsz << " bytes)" << std::endl;

        // 写入指令段数据到imem
        // imem is word-addressed, 8KB = 2048 words
        // imem地址从0开始，但程序可能加载在0x80000000
        // 因此需要去掉高位地址
        for (size_t i = 0; i < seg.data.size(); i += 4) {
            uint64_t phys_addr = (addr + i) & 0x1FFF;  // 映射到8KB范围内
            uint32_t word = 0;
            for (int j = 0; j < 4 && (i + j) < seg.data.size(); j++) {
                word |= ((uint32_t)seg.data[i + j]) << (j * 8);
            }
            uint32_t word_addr = phys_addr / 4;
            if (word_addr < 2048) {  // 2048 words = 8KB
                syms->TOP__cpu_single_cycle__u_imem.mem[word_addr] = word;
            }
        }
    }
}

// 打印使用说明
void print_usage(const char* prog) {
    std::cout << "Usage: " << prog << " [options] <elf_file>\n";
    std::cout << "Options:\n";
    std::cout << "  --vcd <file>    Generate VCD waveform file\n";
    std::cout << "  --cycles <n>    Maximum simulation cycles (default: 1000000)\n";
    std::cout << "  --uart-log      Enable UART logging to uart.log\n";
    std::cout << "  --help          Show this help\n";
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    // 解析命令行参数
    const char* elf_filename = nullptr;
    const char* vcd_filename = nullptr;
    uint64_t max_cycles = 1000000;
    bool uart_log = false;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--vcd") == 0 && i + 1 < argc) {
            vcd_filename = argv[++i];
        } else if (strcmp(argv[i], "--cycles") == 0 && i + 1 < argc) {
            max_cycles = std::stoull(argv[++i]);
        } else if (strcmp(argv[i], "--uart-log") == 0) {
            uart_log = true;
        } else if (strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else if (argv[i][0] != '-') {
            elf_filename = argv[i];
        }
    }

    if (!elf_filename) {
        std::cerr << "Error: No ELF file specified\n";
        print_usage(argv[0]);
        return 1;
    }

    // 初始化UART
    uart = std::make_unique<UARTSim>(uart_log);

    // 创建CPU实例
    Vcpu_single_cycle* cpu = new Vcpu_single_cycle;

    // 加载ELF文件
    ELFLoader elf;
    if (!elf.load(elf_filename)) {
        std::cerr << "Failed to load ELF file: " << elf_filename << std::endl;
        delete cpu;
        return 1;
    }

    elf.print_info();
    load_elf_to_imem(cpu, elf);

    // VCD波形记录
#if VM_TRACE
    VerilatedVcdC* tfp = nullptr;
    if (vcd_filename) {
        Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        cpu->trace(tfp, 99);
        tfp->open(vcd_filename);
        std::cout << "VCD tracing enabled: " << vcd_filename << std::endl;
    }
#else
    if (vcd_filename) {
        std::cerr << "Warning: VCD tracing not compiled in. Rebuild with 'make trace' for VCD support." << std::endl;
    }
#endif

    // 复位CPU
    cpu->rst_n = 0;
    cpu->clk = 0;
    cpu->eval();
    cpu->clk = 1;
    cpu->eval();
    cpu->rst_n = 1;

    // 设置PC到入口点
    cpu->clk = 0;
    cpu->eval();

    std::cout << "\n=== Starting simulation ===\n";
    std::cout << "Entry point: 0x" << std::hex << elf.get_entry_point() << std::dec << std::endl;
    std::cout << "Max cycles: " << max_cycles << "\n\n";

    // 仿真循环
    uint64_t cycle = 0;
    bool running = true;
    uint64_t last_mem_addr = 0;
    uint64_t last_mem_data = 0;
    bool last_mem_write = false;

    while (running && cycle < max_cycles) {
        // 时钟下降沿
        cpu->clk = 0;
        cpu->eval();

        // 时钟上升沿
        cpu->clk = 1;
        cpu->eval();

        // 监控内存写入（UART输出）
        // 访问CPU内部信号
        auto* syms = get_syms(cpu);
        bool mem_write = syms->TOP__cpu_single_cycle.mem_write;
        uint64_t mem_addr = syms->TOP__cpu_single_cycle.alu_result;
        // 获取写入数据：从dmem数组中读取
        uint64_t mem_data = 0;
        if (mem_write && mem_addr < 65536) {
            mem_data = syms->TOP__cpu_single_cycle.u_dmem__DOT__mem[mem_addr];
        }

        if (mem_write && mem_addr == UARTSim::UART_DATA) {
            // 检测到UART写入，输出字符
            uart->write(mem_addr, mem_data, 1);
        }

        // 记录波形
#if VM_TRACE
        if (tfp) {
            tfp->dump(cycle * 2);
        }
#endif

        // 每10000周期打印一次进度
        if (cycle % 10000 == 0 && cycle > 0) {
            std::cout << "\r[Progress] Cycle " << cycle << ": PC=0x"
                      << std::hex << get_syms(cpu)->TOP__cpu_single_cycle.pc
                      << std::dec << std::flush;
        }

        cycle++;
    }

    std::cout << "\n\n=== Simulation ended ===\n";
    std::cout << "Total cycles: " << cycle << std::endl;

    // 清理
#if VM_TRACE
    if (tfp) {
        tfp->close();
        delete tfp;
    }
#endif
    delete cpu;

    return 0;
}
