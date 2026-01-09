# Verilator增强仿真器

## 目标

让Verilator仿真器能够：
1. 加载ELF可执行文件
2. 模拟UART串口输出
3. 生成VCD波形文件
4. 运行裸机程序和操作系统（xv6）

---

## 增强功能清单

### 1. ELF文件加载器

**功能**:
- 解析RISC-V ELF文件
- 加载到仿真内存
- 设置PC初始值

**实现文件**: `sim/verilator/elf_loader.cpp`

### 2. UART仿真

**功能**:
- 捕获CPU的UART输出
- 打印到终端
- 支持输入（可选）

**内存映射**:
```
0x1000: UART数据寄存器（映射到dmem地址空间）
0x1004: UART状态寄存器
```

### 3. VCD波形生成

**功能**:
- 记录所有信号变化
- 用GTKWave查看
- 调试时序问题

**使用方法**:
```bash
./obj_dir/Vcpu --vcd cpu.vcd program.elf
gtkwave cpu.vcd
```

### 4. 内存初始化

**功能**:
- 从文件加载内存内容
- 支持hex、bin、elf格式
- 模拟ROM/RAM

---

## 文件结构

```
sim/verilator/
├── cpu_tb_enhanced.cpp      # 增强版testbench
├── elf_loader.h             # ELF加载器头文件
├── elf_loader.cpp           # ELF加载器实现
├── uart_sim.h               # UART仿真头文件
├── uart_sim.cpp             # UART仿真实现
└── Makefile                 # 构建脚本
```

---

## 编译命令

```bash
# 基础仿真（无波形）
verilator --cc --exe --build \
    -I../../rtl/core \
    ../../rtl/core/cpu_single_cycle.v \
    cpu_tb_enhanced.cpp elf_loader.cpp uart_sim.cpp

# 带波形仿真（调试用）
verilator --cc --exe --build --trace \
    -I../../rtl/core \
    ../../rtl/core/cpu_single_cycle.v \
    cpu_tb_enhanced.cpp elf_loader.cpp uart_sim.cpp
```

---

## 使用示例

### 示例1：运行Hello World

```bash
# 编译程序
riscv64-elf-gcc -o hello.elf hello.c

# 仿真运行
./obj_dir/Vcpu_single_cycle hello.elf

# 预期输出
Hello, World from RISC-V CPU!
```

### 示例2：运行xv6

```bash
# 编译xv6
cd software/xv6-riscv
make

# 仿真运行
cd ../../sim/verilator
./obj_dir/Vcpu_single_cycle ../../software/xv6-riscv/kernel/kernel

# 预期输出
xv6 kernel is booting
...
```

### 示例3：生成波形调试

```bash
# 运行并生成VCD
./obj_dir/Vcpu_single_cycle --vcd debug.vcd program.elf

# 查看波形
gtkwave debug.vcd
```

---

## 内存映射

### 物理地址空间

```
0x0000 - 0x1FFF: 指令存储器 (imem, 8KB)
0x0000 - 0xFFFF: 数据存储器 (dmem, 64KB)
0x1000 - 0x10FF: UART (映射在dmem内)
```

### UART寄存器

| 地址 | 寄存器 | 说明 |
|------|--------|------|
| 0x1000 | DATA | 数据寄存器 (读/写) |
| 0x1004 | STATUS | 状态寄存器 (只读) |

**STATUS寄存器位定义**:
- bit 0: TX Ready (1=可以发送)
- bit 1: RX Valid (1=有数据可读)

---

## 性能优化

### 快速模式 vs 精确模式

**快速模式** (默认):
- 不生成VCD
- 最大化仿真速度
- 适合长时间运行

**精确模式** (--trace):
- 生成完整VCD
- 速度较慢
- 适合调试

### 预期性能

```
配置: Intel i5 / Ryzen 5
快速模式: ~500K 时钟周期/秒
精确模式: ~50K 时钟周期/秒

运行xv6启动:
快速模式: ~1-2分钟
精确模式: ~10-20分钟
```

---

## 调试技巧

### 1. 查看PC轨迹

```cpp
// cpu_tb_enhanced.cpp
if (cycle % 1000 == 0) {
    printf("Cycle %ld: PC=0x%016lx\n", cycle, cpu->pc);
}
```

### 2. 断点功能

```cpp
// 在特定PC处停止
if (cpu->pc == 0x80000100) {
    printf("Breakpoint hit at 0x80000100\n");
    dump_registers();
    break;
}
```

### 3. 内存检查

```cpp
// 读取内存内容
void dump_memory(uint64_t addr, size_t len) {
    for (size_t i = 0; i < len; i++) {
        printf("%02x ", read_mem(addr + i));
    }
}
```

---

## 下一步

完成Verilator增强后：
1. 📄 [编写裸机Hello World](baremetal-hello.md)
2. 📄 [移植xv6-riscv](xv6-porting.md)
3. 📄 [Linux内核测试](linux-test.md)

---

## 参考资料

- [Verilator Manual](https://verilator.org/guide/latest/)
- [RISC-V ELF ABI](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)
- [xv6-riscv源码](https://github.com/mit-pdos/xv6-riscv)
- [GTKWave波形查看器](http://gtkwave.sourceforge.net/)
