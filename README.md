# NB-Core: RISC-V RV64IMA CPU 项目

从零开始设计并实现一个RISC-V 64位CPU，能够在FPGA上运行Linux。

## 项目目标

- 实现符合RISC-V RV64IMA指令集的CPU核心
- 先实现单周期CPU，再升级到5级流水线
- 支持在FPGA上运行Linux内核 + BusyBox
- 使用开源工具链（Yosys + nextpnr）

## 目录结构

```
.
├── rtl/                    # RTL硬件描述代码
│   ├── core/              # CPU核心模块
│   ├── peripherals/       # 外设（UART、中断控制器等）
│   └── soc/               # SoC顶层集成
├── tb/                    # 测试平台(testbench)
├── sim/                   # 仿真脚本和结果
├── software/              # 软件工具链和测试程序
│   ├── bootloader/        # 引导加载程序
│   └── toolchain/         # 工具链配置
├── fpga/                  # FPGA综合脚本
└── docs/                  # 文档

```

## 技术规格

- **指令集**: RV64IMA (64位基础整数 + 乘除法 + 原子操作)
- **寄存器**: 32个64位通用寄存器 (x0-x31)
- **架构**: 单周期 → 5级流水线 (IF/ID/EX/MEM/WB)
- **内存**: 支持MMU (Linux需要)
- **外设**: UART、定时器、中断控制器

## 开发阶段

### 阶段1: 单周期RV64I核心
- [ ] 实现基础ALU
- [ ] 实现寄存器文件
- [ ] 实现指令译码器
- [ ] 实现程序计数器(PC)
- [ ] 实现内存接口

### 阶段2: 添加M/A扩展
- [ ] 乘法器
- [ ] 除法器
- [ ] 原子操作支持

### 阶段3: 5级流水线
- [ ] 流水线寄存器
- [ ] 数据冒险检测与转发
- [ ] 控制冒险处理(分支预测)

### 阶段4: 系统支持
- [ ] CSR (控制状态寄存器)
- [ ] 特权级别 (M/S/U模式)
- [ ] 异常和中断处理
- [ ] MMU (页表转换)

### 阶段5: 外设与SoC
- [ ] UART串口
- [ ] 定时器
- [ ] 中断控制器(PLIC/CLINT)

### 阶段6: 软件生态
- [ ] 工具链配置
- [ ] Bootloader
- [ ] Linux内核移植
- [ ] BusyBox根文件系统

### 阶段7: FPGA实现
- [ ] 综合优化
- [ ] 时序收敛
- [ ] 硬件验证

## 工具链

- **HDL语言**: Verilog
- **仿真器**: Verilator / Icarus Verilog
- **波形查看**: GTKWave
- **FPGA综合**: Yosys + nextpnr (开源)
- **目标FPGA**: Lattice ECP5 (推荐ULX3S开发板)

## 快速开始

TODO: 添加构建和仿真指令

## 参考资料

- [RISC-V 规范](https://riscv.org/technical/specifications/)
- [RISC-V Reader中文版](http://riscvbook.com/)
