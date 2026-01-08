# NB-Core CPU 技术规格

## 概述

NB-Core是一个教育性质的RISC-V RV64IMA处理器实现，目标是在FPGA上运行Linux操作系统。

## 指令集架构 (ISA)

### RV64I - 基础整数指令集

**寄存器**
- 32个64位通用寄存器 (x0-x31)
  - x0: 硬连线为0
  - x1: 返回地址 (ra)
  - x2: 栈指针 (sp)
  - x3-x31: 通用寄存器
- PC (程序计数器): 64位

**指令格式**
- R型: 寄存器-寄存器运算
- I型: 立即数运算、加载指令
- S型: 存储指令
- B型: 分支指令
- U型: 高位立即数
- J型: 跳转指令

**指令类别** (共47条指令)
1. 算术逻辑: ADD, SUB, AND, OR, XOR, SLT, etc.
2. 移位: SLL, SRL, SRA
3. 加载/存储: LB, LH, LW, LD, SB, SH, SW, SD
4. 分支: BEQ, BNE, BLT, BGE, BLTU, BGEU
5. 跳转: JAL, JALR
6. 系统: ECALL, EBREAK
7. 立即数: LUI, AUIPC, ADDI, etc.

### RV64M - 乘除法扩展

- MUL, MULH, MULHSU, MULHU: 乘法 (64x64=128位)
- DIV, DIVU: 除法
- REM, REMU: 取模

### RV64A - 原子操作扩展

- LR.W/D, SC.W/D: Load-Reserved / Store-Conditional
- AMOSWAP, AMOADD, AMOAND, AMOOR, AMOXOR
- AMOMIN, AMOMAX, AMOMINU, AMOMAXU

## 微架构

### 阶段1: 单周期实现

**数据通路组件**
```
┌────────┐     ┌──────────┐     ┌─────┐     ┌────────┐
│   PC   │────▶│ InstMem  │────▶│ ID  │────▶│  ALU   │
└────────┘     └──────────┘     └─────┘     └────────┘
                                    │            │
                              ┌─────▼────┐   ┌───▼────┐
                              │ RegFile  │   │DataMem │
                              └──────────┘   └────────┘
```

**特点**
- CPI = 1 (每条指令一个周期)
- 时钟频率受限于关键路径
- 简单但效率较低

### 阶段2: 5级流水线

**流水线级**
1. IF (Instruction Fetch): 取指令
2. ID (Instruction Decode): 译码 + 读寄存器
3. EX (Execute): 执行ALU运算
4. MEM (Memory): 访问数据内存
5. WB (Write Back): 写回寄存器

**流水线寄存器**
- IF/ID, ID/EX, EX/MEM, MEM/WB

**冒险处理**
- 数据冒险: 前递(forwarding) + 暂停(stall)
- 控制冒险: 分支预测 + 冲刷(flush)

**性能**
- 理想CPI ≈ 1
- 实际CPI ≈ 1.2-1.5 (考虑冒险)

## 内存架构

### 地址空间 (64位)

```
0x0000_0000_0000_0000 - 0x0000_0000_7FFF_FFFF : RAM (2GB)
0x0000_0000_8000_0000 - 0x0000_0000_8FFF_FFFF : 外设空间
  - 0x8000_0000 : UART
  - 0x8000_1000 : Timer
  - 0x8000_2000 : CLINT (中断控制器)
  - 0x8000_C000 : PLIC (平台中断控制器)
0xFFFF_FFFF_0000_0000 - 0xFFFF_FFFF_FFFF_FFFF : 内核空间
```

### MMU (内存管理单元)

- 页表格式: Sv39 (39位虚拟地址)
- 页大小: 4KB
- TLB: 16-entry fully-associative

## 特权架构

### 特权级别
- M-mode (Machine): 最高权限
- S-mode (Supervisor): OS内核
- U-mode (User): 用户程序

### 控制状态寄存器 (CSR)

**Machine级**
- mstatus: 状态寄存器
- mtvec: 中断向量基址
- mepc: 异常PC
- mcause: 异常原因
- mie, mip: 中断使能/挂起

**Supervisor级**
- sstatus, stvec, sepc, scause
- satp: 页表基址

## 中断和异常

### 异常类型
- 指令地址不对齐
- 非法指令
- 断点
- Load/Store地址不对齐
- 页错误

### 中断源
- 软件中断
- 定时器中断
- 外部中断 (UART等)

## 外设接口

### UART (16550兼容)
- 波特率: 115200
- 数据位: 8
- 停止位: 1
- 用于串口控制台

### Timer
- 64位计数器
- 可配置比较值
- 产生定时中断

### CLINT (Core-Local Interruptor)
- 软件中断
- 定时器中断

### PLIC (Platform-Level Interrupt Controller)
- 支持多个外部中断源
- 中断优先级管理

## 性能目标

### 仿真
- 单周期: ~10 MHz (仿真速度)
- 流水线: ~25 MHz (仿真速度)

### FPGA (ECP5-85K)
- 单周期: ~30-50 MHz
- 流水线: ~50-75 MHz

### 资源使用预估
- LUTs: 10K-15K
- FFs: 5K-8K
- BRAM: 8-16块 (用于指令/数据RAM)

## 兼容性

### 软件支持
- GCC工具链: riscv64-unknown-linux-gnu
- Linux内核: 5.x+ (支持RV64IMA)
- Bootloader: OpenSBI + U-Boot
- 用户空间: BusyBox

### 测试
- riscv-tests: 官方ISA测试套件
- Dhrystone benchmark
- 简单C程序
