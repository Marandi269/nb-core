# nb-core 开发环境工具需求

> 本文档列出nb-core项目开发所需的全部工具和版本要求

## 目录

- [系统要求](#系统要求)
- [必需工具列表](#必需工具列表)
- [工具详细说明](#工具详细说明)
- [验证清单](#验证清单)

---

## 系统要求

### 硬件配置

- **内存**: 8GB+ (推荐16GB，FPGA工具链编译需要)
- **磁盘**: 20GB+ 可用空间
- **CPU**: 4核+ (加快编译速度)

### 操作系统支持

- ✅ **Arch Linux** (主要开发环境)
- ✅ **Ubuntu 22.04+** / **Debian 12+**
- ⚠️ **macOS** (部分工具需从源码编译)
- ❌ **Windows** (必须使用WSL2)

---

## 必需工具列表

### 1. 基础开发工具

| 工具 | 用途 | 最低版本 |
|------|------|----------|
| **GCC/Clang** | C/C++编译器 | GCC 7.0+ / Clang 10+ |
| **Make** | 构建工具 | 4.0+ |
| **CMake** | 跨平台构建系统 | 3.10+ |
| **Ninja** | 快速构建工具 | 1.8+ |
| **Git** | 版本控制 | 2.20+ |
| **Python** | 脚本语言 | 3.8+ |

**依赖库**:
- Boost (算法和数据结构库)
- Eigen3 (线性代数库)
- zlib (压缩库)
- Tcl/Tk (GUI支持)
- libffi (外部函数接口)
- Qt5 Base (图形界面库)

### 2. RISC-V交叉编译工具链

| 工具 | 包名 | 最低版本 | 用途 |
|------|------|----------|------|
| **riscv64-linux-gnu-gcc** | GCC交叉编译器 | 12.0+ | 编译C/C++代码 |
| **riscv64-linux-gnu-binutils** | 二进制工具集 | 2.38+ | 汇编、链接、分析 |
| **riscv64-linux-gnu-glibc** | C标准库 | 2.35+ | 运行时支持 |

**支持的扩展**: 必须支持 **RV64IMA** (64位整数 + 乘除法 + 原子操作)

**可选工具**:
- `riscv64-elf-gcc`: 裸机工具链（无操作系统）
- `riscv64-elf-newlib`: 嵌入式C库
- `riscv64-elf-gdb`: RISC-V调试器

### 3. 仿真工具

| 工具 | 用途 | 最低版本 | 必需性 |
|------|------|----------|--------|
| **Verilator** | Verilog仿真器 | 5.0+ | ✅ 必需 |
| **QEMU RISC-V** | 系统模拟器 | 8.0+ | ✅ 必需 |
| **GTKWave** | 波形查看器 | 3.3.100+ | ✅ 推荐 |
| **Icarus Verilog** | Verilog仿真器 | 11.0+ | ⚪ 可选 |

**说明**:
- Verilator: 用于CPU Verilog仿真（性能更高）
- QEMU: 用于测试Linux内核和应用程序
- GTKWave: 查看仿真波形文件(.vcd)
- Icarus Verilog: 备用仿真器（较慢）

### 4. FPGA工具链（ULX3S-ECP5开发板）

| 工具 | 用途 | 最低版本 | 必需性 |
|------|------|----------|--------|
| **Yosys** | 综合工具 | 0.30+ | ✅ 必需 |
| **nextpnr-ecp5** | 布局布线工具 | 0.6+ | ✅ 必需 |
| **prjtrellis** | ECP5 FPGA数据库 | 最新版 | ✅ 必需 |
| **openFPGALoader** | 烧录工具 | 0.11+ | ✅ 必需 |

**说明**:
- Yosys: 将Verilog代码转换为网表
- nextpnr-ecp5: 针对Lattice ECP5 FPGA的布局布线
- prjtrellis: 提供ECP5芯片的数据库和工具
- openFPGALoader: 通过USB将比特流烧录到FPGA

**重要**: nextpnr-ecp5和prjtrellis可能需要从源码编译，编译时间约10-20分钟

### 5. USB设备权限配置

为了访问FPGA开发板（通过USB串口），需要：

**Arch Linux**:
- 将用户添加到 `uucp` 组

**Ubuntu/Debian**:
- 将用户添加到 `dialout` 组

**udev规则** (所有系统):
```
# /etc/udev/rules.d/53-lattice-ftdi.rules
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666"
```

---

## 工具详细说明

### 包管理器工具名对照表

不同Linux发行版的包名可能不同：

| 工具 | Arch Linux | Ubuntu/Debian |
|------|------------|---------------|
| 基础开发工具 | `base-devel` | `build-essential` |
| RISC-V GCC | `riscv64-linux-gnu-gcc` | `gcc-riscv64-linux-gnu` |
| RISC-V Binutils | `riscv64-linux-gnu-binutils` | `binutils-riscv64-linux-gnu` |
| Verilator | `verilator` | `verilator` |
| QEMU RISC-V | `qemu-system-riscv` | `qemu-system-misc` |
| GTKWave | `gtkwave` | `gtkwave` |
| Yosys | `yosys` | `yosys` |
| Boost库 | `boost` | `libboost-all-dev` |
| Eigen3库 | `eigen` | `libeigen3-dev` |
| Qt5 | `qt5-base` | `qtbase5-dev` |

### 从源码编译的工具

以下工具可能需要从源码编译（取决于发行版）：

1. **nextpnr-ecp5**
   - 源码: https://github.com/YosysHQ/nextpnr
   - 编译时间: 10-20分钟
   - 依赖: Boost, Eigen3, prjtrellis

2. **prjtrellis**
   - 源码: https://github.com/YosysHQ/prjtrellis
   - 编译时间: 5-10分钟
   - 依赖: CMake, Boost

3. **openFPGALoader**
   - 源码: https://github.com/trabucayre/openFPGALoader
   - 编译时间: 2-5分钟
   - 依赖: CMake, libftdi

### macOS特殊说明

macOS用户推荐使用Homebrew安装：

```bash
brew install verilator yosys
brew install --cask gtkwave
brew tap riscv-software-src/riscv
brew install riscv-tools
```

---

## 验证清单

安装完成后，使用以下命令验证工具是否正确安装：

```bash
# 基础工具
gcc --version              # GCC 7.0+
make --version             # Make 4.0+
cmake --version            # CMake 3.10+
git --version              # Git 2.20+
python3 --version          # Python 3.8+

# RISC-V工具链
riscv64-linux-gnu-gcc --version       # GCC 12.0+
riscv64-linux-gnu-as --version        # Binutils 2.38+
riscv64-linux-gnu-gcc -march=help     # 应显示RV64IMA支持

# 仿真工具
verilator --version        # Verilator 5.0+
qemu-system-riscv64 --version         # QEMU 8.0+
gtkwave --version          # GTKWave 3.3.100+

# FPGA工具链
yosys --version            # Yosys 0.30+
nextpnr-ecp5 --version     # nextpnr 0.6+
openFPGALoader --version   # openFPGALoader 0.11+

# 用户组权限
groups                     # 应包含uucp(Arch)或dialout(Ubuntu)
```

**完整测试**:

```bash
# 克隆项目
git clone https://github.com/Marandi269/nb-core.git
cd nb-core

# 测试RISC-V编译
cd software/baremetal/hello
make
riscv64-linux-gnu-readelf -h hello.elf

# 测试Verilator仿真
cd ../../../sim/verilator
make
./obj_dir/Vcpu_single_cycle --help
```

---

## 获取帮助

如果遇到安装问题：

1. 查看各Linux发行版的官方文档
2. 查看工具的GitHub仓库Issues
3. 提交问题到 [nb-core Issues](https://github.com/Marandi269/nb-core/issues)

---

## 推荐的学习资源

- [RISC-V官方规范](https://riscv.org/specifications/)
- [Verilator文档](https://verilator.org/guide/latest/)
- [Yosys文档](http://yosyshq.net/yosys/)
- [ULX3S项目主页](https://github.com/emard/ulx3s)

---

**维护者**: nb-core项目团队
**最后更新**: 2026-01-09
**文档版本**: v2.0 (简化版)
