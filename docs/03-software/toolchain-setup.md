# RISC-V软件工具链安装指南

## 概述

为了编译运行在RISC-V CPU上的软件，需要交叉编译工具链：
- **裸机程序**: riscv64-elf-gcc（直接运行在硬件上）
- **Linux系统**: riscv64-linux-gnu-gcc（运行在Linux内核上）

---

## 安装步骤（Arch Linux）

### 1. Linux工具链（推荐）

```bash
sudo pacman -S riscv64-linux-gnu-gcc riscv64-linux-gnu-binutils
```

**包含组件**:
- riscv64-linux-gnu-gcc: GCC编译器 (15.1.0)
- riscv64-linux-gnu-binutils: 汇编器、链接器等
- riscv64-linux-gnu-glibc: C运行时库
- riscv64-linux-gnu-linux-api-headers: Linux内核头文件

### 2. 裸机工具链（可选）

```bash
sudo pacman -S riscv64-elf-gcc riscv64-elf-newlib
```

**用途**:
- 编译Bootloader (OpenSBI)
- 编译裸机测试程序
- 不依赖操作系统的代码

---

## 验证安装

```bash
# GCC版本
riscv64-linux-gnu-gcc --version
# 输出: riscv64-linux-gnu-gcc (GCC) 15.1.0

# 支持的架构
riscv64-linux-gnu-gcc -march=help
# 查看支持的RISC-V扩展

# 测试编译
echo 'int main() { return 42; }' | \
    riscv64-linux-gnu-gcc -x c - -o test.elf

file test.elf
# 输出: ELF 64-bit LSB executable, UCB RISC-V
```

---

## 目标架构配置

我们的CPU是 **RV64IMA**:
- RV64: 64位基础整数指令集
- I: 基础整数指令
- M: 整数乘除法扩展
- A: 原子操作扩展

### 编译选项

```bash
CROSS_COMPILE=riscv64-linux-gnu-
ARCH=riscv
CFLAGS="-march=rv64ima -mabi=lp64"
```

**说明**:
- `-march=rv64ima`: 指定架构特性
- `-mabi=lp64`: 64位整数ABI（不使用浮点）

---

## 常用工具

### 1. 编译器

```bash
# 编译C代码
riscv64-linux-gnu-gcc -o program program.c

# 查看汇编
riscv64-linux-gnu-gcc -S program.c

# 指定优化级别
riscv64-linux-gnu-gcc -O2 -o program program.c
```

### 2. 链接器

```bash
# 使用自定义链接脚本
riscv64-linux-gnu-ld -T linker.ld -o program.elf *.o
```

### 3. 二进制工具

```bash
# 查看ELF信息
riscv64-linux-gnu-readelf -h program.elf

# 反汇编
riscv64-linux-gnu-objdump -d program.elf

# 生成二进制文件
riscv64-linux-gnu-objcopy -O binary program.elf program.bin

# 生成十六进制文件（用于仿真）
riscv64-linux-gnu-objcopy -O ihex program.elf program.hex
```

### 4. 调试工具

```bash
# GDB调试器
sudo pacman -S riscv64-linux-gnu-gdb

# 使用方法
riscv64-linux-gnu-gdb program.elf
```

---

## 项目结构

```
nb-core/
├── software/
│   ├── baremetal/          # 裸机程序
│   │   ├── hello/
│   │   │   ├── hello.c
│   │   │   ├── link.ld
│   │   │   └── Makefile
│   │   └── tests/
│   ├── linux/              # Linux内核
│   │   ├── kernel/         # 内核源码
│   │   └── configs/        # 内核配置
│   ├── bootloader/         # OpenSBI
│   └── rootfs/             # 根文件系统
│       └── busybox/
└── docs/03-software/       # 软件相关文档
```

---

## Makefile模板

### 裸机程序

```makefile
CROSS_COMPILE = riscv64-elf-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy

CFLAGS = -march=rv64ima -mabi=lp64 -O2 -nostdlib
LDFLAGS = -T link.ld

all: program.bin

program.elf: *.c
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

program.bin: program.elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f *.elf *.bin *.hex
```

### Linux应用程序

```makefile
CROSS_COMPILE = riscv64-linux-gnu-
CC = $(CROSS_COMPILE)gcc

CFLAGS = -march=rv64ima -mabi=lp64 -O2 -static

all: program

program: program.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f program
```

---

## 下一步

工具链安装完成后，继续：
1. 📄 [编译Linux内核](linux-build.md)
2. 📄 [创建Busybox根文件系统](busybox-rootfs.md)
3. 📄 [编译OpenSBI Bootloader](opensbi-build.md)
4. 📄 [编写Hello World裸机程序](../04-testing/baremetal-hello.md)

---

## 参考资料

- [RISC-V GCC工具链](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [RISC-V ISA手册](https://riscv.org/specifications/)
- [RISC-V ABI规范](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)
- [Arch Linux RISC-V](https://wiki.archlinux.org/title/RISC-V)
