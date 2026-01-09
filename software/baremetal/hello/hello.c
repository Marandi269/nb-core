// 裸机Hello World程序 - RISC-V RV64IMA
// 通过UART输出字符
// UART映射在dmem的0x1000地址

#define UART_BASE 0x1000
#define UART_DATA (*(volatile unsigned long*)UART_BASE)

// 发送一个字符到UART
void uart_putc(char c) {
    // 直接写入UART数据寄存器
    UART_DATA = c;
}

// 发送字符串到UART
void uart_puts(const char* s) {
    while (*s) {
        uart_putc(*s++);
    }
}

// 程序入口点
void _start(void) {
    uart_puts("Hello, World from RISC-V CPU!\n");
    uart_puts("This is a bare-metal program running on nb-core.\n");
    uart_puts("\n");
    uart_puts("CPU: RV64IMA single-cycle\n");
    uart_puts("UART: 0x10000000\n");
    uart_puts("\n");
    uart_puts("Simulation successful!\n");

    // 停止（无限循环）
    while (1) {
        asm volatile("nop");
    }
}
