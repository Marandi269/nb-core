#include "uart_sim.h"
#include <iostream>

UARTSim::UARTSim(bool enable_log) : log_enabled_(enable_log) {
    if (log_enabled_) {
        log_file_.open("uart.log", std::ios::out | std::ios::trunc);
        if (!log_file_) {
            std::cerr << "Warning: Failed to open uart.log" << std::endl;
            log_enabled_ = false;
        }
    }
}

UARTSim::~UARTSim() {
    if (log_file_.is_open()) {
        log_file_.close();
    }
}

uint64_t UARTSim::read(uint64_t addr) {
    if (addr == UART_DATA) {
        // 读取数据寄存器
        if (!rx_fifo_.empty()) {
            uint8_t data = rx_fifo_.front();
            rx_fifo_.pop();
            return data;
        }
        return 0;  // FIFO为空返回0
    } else if (addr == UART_STATUS) {
        // 读取状态寄存器
        uint32_t status = STATUS_TX_READY;  // TX总是ready
        if (!rx_fifo_.empty()) {
            status |= STATUS_RX_VALID;  // RX有数据
        }
        return status;
    }
    return 0;
}

void UARTSim::write(uint64_t addr, uint64_t data, uint8_t size) {
    if (addr == UART_DATA) {
        // 写入数据寄存器 - 发送字符
        uint8_t ch = data & 0xFF;

        // 打印到终端
        std::cout << static_cast<char>(ch) << std::flush;

        // 记录到日志
        if (log_enabled_ && log_file_.is_open()) {
            log_file_ << static_cast<char>(ch) << std::flush;
        }
    }
    // 状态寄存器是只读的，写入无效
}

void UARTSim::add_rx_char(uint8_t c) {
    rx_fifo_.push(c);
}

void UARTSim::clear_rx() {
    while (!rx_fifo_.empty()) {
        rx_fifo_.pop();
    }
}
