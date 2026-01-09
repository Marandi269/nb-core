#ifndef UART_SIM_H
#define UART_SIM_H

#include <stdint.h>
#include <queue>
#include <fstream>

// UART仿真器类 - 模拟串口输入输出
class UARTSim {
public:
    // UART寄存器地址（映射到dmem地址空间）
    static const uint64_t UART_BASE = 0x1000;
    static const uint64_t UART_DATA = 0x1000;    // 数据寄存器
    static const uint64_t UART_STATUS = 0x1004;  // 状态寄存器

    // 状态寄存器位定义
    static const uint32_t STATUS_TX_READY = 0x01;   // bit 0: TX ready
    static const uint32_t STATUS_RX_VALID = 0x02;   // bit 1: RX valid

private:
    std::queue<uint8_t> rx_fifo_;  // 接收FIFO
    std::ofstream log_file_;       // 日志文件
    bool log_enabled_;

public:
    UARTSim(bool enable_log = false);
    ~UARTSim();

    // 内存映射读写
    uint64_t read(uint64_t addr);
    void write(uint64_t addr, uint64_t data, uint8_t size);

    // 检查地址是否为UART区域
    static bool is_uart_addr(uint64_t addr) {
        return (addr >= UART_BASE && addr < UART_BASE + 0x100);
    }

    // 添加接收数据（用于模拟输入）
    void add_rx_char(uint8_t c);

    // 清空接收FIFO
    void clear_rx();
};

#endif // UART_SIM_H
