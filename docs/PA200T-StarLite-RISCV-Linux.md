# PA200T-StarLite RISC-V Linux 项目文档

## 项目概述
在璞致 PA200T-StarLite FPGA 开发板上运行基于 vivado-risc-v 项目的 Rocket Chip RISC-V SoC 和 Debian Linux。

## 硬件环境

### 开发板: PA200T-StarLite
- **FPGA**: Xilinx XC7A200T-2FBG484I (Artix-7)
- **DDR3 内存**: 1GB (2x MT41K256M16TW-107, 32位宽)
- **存储**: MicroSD 卡槽, 128Mb SPI Flash (W25Q128)
- **接口**:
  - USB-UART (CH340E)
  - JTAG (FT232H)
  - Gigabit Ethernet (RTL8211F RGMII)
  - HDMI 输出 (ADV7513)
  - USB 2.0 Host
- **时钟**: 200MHz 差分输入

### 服务器环境

#### dev 服务器
- **访问方式**: `ssh dev` (已配置 SSH 别名)
- **系统**: Ubuntu
- **用途**: Vivado 综合、软件编译

工具安装位置:
- Vivado 2025.2: `/opt/Xilinx/2025.2/Vivado/`
- Vivado 环境: `source /opt/Xilinx/2025.2/Vivado/settings64.sh`
- vivado-risc-v 项目: `/home/ubuntu/vivado-risc-v/`
- Bare-metal 工具链: `workspace/gcc/riscv/bin/riscv64-unknown-elf-*`
- Linux 交叉编译: `/usr/bin/riscv64-linux-gnu-*`

#### n100 服务器
- **访问方式**: `ssh n100` (已配置 SSH 别名)
- **用途**: 连接开发板进行测试和烧写

硬件连接:
- JTAG: FT232H USB (VID:PID 0403:6014)
- UART: CH340 USB (/dev/ttyUSB0, 115200 baud)
- SD 卡读卡器: 用于制作启动盘

工具:
- OpenOCD: 用于 JTAG 烧写
- OpenOCD 配置: `/tmp/ft232h.cfg`

## 软件配置

### FPGA 设计
- **SoC 配置**: rocket64b2 (双核 Rocket, RV64IMAFDC)
- **CPU 时钟**: 40 MHz
- **DDR3 时钟**: 400 MHz (800 MT/s)
- **外设**:
  - AXI SD 卡控制器 @ 0x60000000
  - AXI UART @ 0x60010000
  - AXI Ethernet @ 0x60020000
  - PLIC 中断控制器 @ 0xc000000
  - CLINT @ 0x2000000

### 板级支持文件
位置: `/home/ubuntu/vivado-risc-v/board/pa200t-starlite/`
- `Makefile.inc` - 板级配置 (FPGA 型号, 内存大小等)
- `riscv-2025.2.tcl` - Vivado 块设计脚本
- `bootrom.dts` - 设备树覆盖
- `uart.xdc` - UART 引脚约束 (P14/P15)
- `sdc.xdc` - SD 卡引脚约束
- `ethernet.xdc` - 以太网引脚约束
- `top.xdc` - 顶层约束 (时钟路由等)
- `official-mig.prj` - DDR3 MIG 配置

### 启动流程
1. FPGA Boot ROM 从 SD 卡 FAT32 分区读取 `BOOT.ELF`
2. OpenSBI 初始化 M-mode 环境
3. U-Boot 从 SD 卡读取 `extlinux.conf`
4. U-Boot 加载内核 (Image)、initrd、设备树 (支持从 extlinux.conf 的 `fdt` 指令加载外部 DTB)
5. Linux 内核启动, 挂载 ext4 根文件系统

### SD 卡分区
- 分区 1: FAT32, 127MB (启动分区)
  - `BOOT.ELF` - OpenSBI + U-Boot
  - `extlinux/extlinux.conf` - 启动配置
  - `extlinux/image-v6.15.9` - Linux 内核
  - `extlinux/initrd-v6.15.9.img` - initramfs
  - `extlinux/system.dtb` - 设备树 (外部 DTB，通过 `fdt` 指令加载)
- 分区 2: ext4, 剩余空间 (根文件系统)

### extlinux.conf 配置
```
menu title RISC-V Boot Options.
timeout 50
default Debian v6.15.9
label Debian v6.15.9
 kernel /extlinux/image-v6.15.9
 initrd /extlinux/initrd-v6.15.9.img
 fdt /extlinux/system.dtb
 append ro root=/dev/mmcblk0p2 rootwait earlycon initramfs.runsize=24M locale.LANG=en_US.UTF-8 loglevel=7
```

## 当前进展

### ✅ 已完成 - Linux 成功启动！

1. DDR3 MIG 配置 - 1GB 内存正常工作
2. UART 通信 - 串口输出正常 (交换了 TX/RX 引脚)
3. Bitstream 生成 - 成功
4. OpenSBI + U-Boot 启动 - 成功
5. Linux 内核启动 - 成功
6. initramfs 加载 - 成功
7. 设备树修复 - io-bus 使用 64 位地址 (#address-cells=2, #size-cells=2)
8. 外部 DTB 加载 - U-Boot 从 SD 卡 extlinux/system.dtb 加载设备树
9. **SD 卡 Linux 驱动修复** - 修改 fpga-axi-sdc 驱动绕过 card_detect
10. **根文件系统挂载成功** - ext4 分区正常挂载
11. **Debian Linux 启动** - systemd 正常运行

### 启动时间参考 (40MHz CPU)
- 内核启动到驱动加载: ~14秒
- SD 卡检测: ~14秒
- 根文件系统挂载: ~117秒
- systemd 启动: ~127秒
- 完整启动到登录: 预计 5-10 分钟

### 已解决的问题: SD 卡 Card Detect

**问题**: Linux 内核 MMC 驱动的 `sdc_get_cd` 函数检查 card_detect 寄存器，
寄存器值为 `0x9` 表示卡不存在，导致 SD 卡无法被检测。

**根因分析**:
```
card_detect = 0x9:
- Bit 0 (SDC_CARD_INSERT_INT_EN): 设置 - 插入中断使能
- Bit 1 (SDC_CARD_INSERT_INT_REQ): 未设置 - 没有插入请求
- Bit 3 (SDC_CARD_REMOVE_INT_REQ): 设置 - 有移除请求
```

FPGA 中的 SD 卡控制器 IP 没有正确连接 card_detect 引脚，或者
开发板上的 SD 卡槽没有 card detect 开关。

**解决方案**: 修改 `fpga-axi-sdc.c` 驱动，让 `sdc_get_cd` 始终返回 1

```c
static int sdc_get_cd(struct mmc_host * mmc) {
    /* Always report card present - CD hardware not reliable */
    return 1;
#if 0  /* Original code disabled */
    struct sdc_host * host = mmc_priv(mmc);
    uint32_t card_detect = host->regs->card_detect;
    if (card_detect == 0) return 1;
    return (card_detect & SDC_CARD_INSERT_INT_REQ) != 0;
#endif
}
```

**注意**: 设备树的 `broken-cd` 属性对此驱动无效，因为驱动没有实现对该属性的支持。

### 修改的文件

#### dev 服务器

1. `/home/ubuntu/vivado-risc-v/board/pa200t-starlite/bootrom.dts`
   - 添加了 `broken-cd` 属性 (但对驱动无效)
   - io-bus 使用 64 位地址 (#address-cells=2, #size-cells=2)

2. `/home/ubuntu/vivado-risc-v/linux-stable/drivers/mmc/host/fpga-axi-sdc.c`
   - **关键修改**: `sdc_get_cd` 函数始终返回 1 (卡存在)
   - 原始备份: `fpga-axi-sdc.c.bak`

#### SD 卡 (通过 n100 更新)

- `/mnt/boot/extlinux/system.dtb` - 包含 broken-cd 属性的 DTB
- `/mnt/boot/extlinux/image-v6.15.9` - 修复后的内核 (kernel #4)

#### n100 服务器 DTB 文件

- `/tmp/system.dtb` - 原始正确的 DTB (从 BOOT.ELF 中提取，timebase=400KHz)
- `/tmp/system_fixed.dtb` - 添加 broken-cd 后的 DTB (当前使用)
- `/tmp/system_new.dtb` - 错误的 DTB (从 dev 的 system.dts 编译，timebase=1MHz，内存14GB - **不要使用**)

**重要**: dev 服务器上的 `/home/ubuntu/vivado-risc-v/workspace/rocket64b2/system.dts`
包含错误的参数 (timebase-frequency=1MHz, memory=14GB)，不能直接用来编译 DTB。
正确的 DTB 应该从 n100 的 `/tmp/system.dtb` 修改而来。

## 待解决问题

### 中优先级
1. **以太网** - 尚未测试
   - RTL8211F PHY 使用 RGMII 接口
   - 需要验证引脚约束和 PHY 复位

2. **HDMI 输出** - 未配置
   - 需要添加视频 IP 核
   - 需要 ADV7513 I2C 配置

### 低优先级
3. **USB Host** - 尚未测试
4. **SPI Flash 启动** - 尚未配置
5. **修复 dev 上的 system.dts** - 让参数与实际硬件配置一致

## 关键文件路径

### dev 服务器
```
/home/ubuntu/vivado-risc-v/
├── board/pa200t-starlite/     # 板级支持文件
│   └── bootrom.dts            # 设备树覆盖 (已修改)
├── workspace/rocket64b2/       # 构建工作目录
│   ├── system.dts             # 基础设备树
│   └── vivado-pa200t-starlite-riscv/
│       └── pa200t-starlite-riscv.runs/impl_1/
│           └── riscv_wrapper.bit  # Bitstream
├── bootrom/
│   ├── system.dts             # 合并后的设备树源
│   ├── system.dtb             # 编译后的设备树
│   └── bootrom.elf            # Boot ROM ELF
├── linux-stable/              # Linux 内核源码
│   ├── drivers/mmc/host/fpga-axi-sdc.c      # SD 卡驱动 (已添加调试)
│   ├── drivers/mmc/host/fpga-axi-sdc.c.bak  # 原始备份
│   └── arch/riscv/boot/Image  # 编译后的内核
├── opensbi/                   # OpenSBI 源码
└── u-boot/                    # U-Boot 源码
```

### n100 服务器
```
/tmp/
├── riscv_wrapper.bit          # Bitstream 副本
├── BOOT.ELF                   # Boot loader
├── system.dtb                 # 设备树
└── debian-riscv64/            # Debian 根文件系统
```

## 常用命令

### JTAG 烧写 Bitstream
```bash
sudo openocd -f /tmp/ft232h.cfg \
  -c 'transport select jtag' \
  -c 'jtag newtap xc7 tap -irlen 6 -expected-id 0x13636093' \
  -c 'pld device virtex2 xc7.tap' \
  -c 'init' \
  -c 'pld load 0 /tmp/riscv_wrapper.bit' \
  -c 'exit'
```

### 监控串口
```bash
sudo stty -F /dev/ttyUSB0 115200 raw -echo
sudo cat /dev/ttyUSB0
```

### 更新 SD 卡上的内核
```bash
ssh n100 "sudo mount /dev/sdb1 /mnt/boot"
scp dev:/home/ubuntu/vivado-risc-v/linux-stable/arch/riscv/boot/Image n100:/tmp/
ssh n100 "sudo cp /tmp/Image /mnt/boot/extlinux/image-v6.15.9"
ssh n100 "sudo umount /mnt/boot && sync"
```

### 更新 SD 卡上的 DTB
```bash
# 在 dev 上合并并编译 DTB
ssh dev "cat /home/ubuntu/vivado-risc-v/workspace/rocket64b2/system.dts \
         /home/ubuntu/vivado-risc-v/board/pa200t-starlite/bootrom.dts > /tmp/merged.dts"
ssh dev "dtc -I dts -O dtb -o /tmp/system.dtb /tmp/merged.dts"
# 复制到 n100 并更新 SD 卡
scp dev:/tmp/system.dtb n100:/tmp/
ssh n100 "sudo mount /dev/sdb1 /mnt/boot"
ssh n100 "sudo cp /tmp/system.dtb /mnt/boot/extlinux/system.dtb"
ssh n100 "sudo umount /mnt/boot && sync"
```

### 重新构建内核
```bash
ssh dev "cd /home/ubuntu/vivado-risc-v/linux-stable && \
         make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j\$(nproc)"
```

### 重新构建 Bootloader
```bash
ssh dev "cd /home/ubuntu/vivado-risc-v && \
         rm -rf opensbi/build workspace/boot.elf && \
         make bootloader BOARD=pa200t-starlite CONFIG=rocket64b2"
```

### 重新构建 Bitstream (需要 source Vivado)
```bash
ssh dev "source /opt/Xilinx/2025.2/Vivado/settings64.sh && \
         cd /home/ubuntu/vivado-risc-v && \
         make bitstream BOARD=pa200t-starlite CONFIG=rocket64b2"
```

## 调试技巧

### 检查设备树内容
```bash
# 反编译 DTB 查看内容
dtc -I dtb -O dts /mnt/boot/extlinux/system.dtb | grep -A 20 "mmc0"
```

### 在 initramfs 中调试
```bash
# 通过串口执行命令
echo 'ls /sys/class/mmc_host' | sudo tee /dev/ttyUSB0
sudo timeout 5 cat /dev/ttyUSB0
```

### 查看内核日志
```bash
# 在 initramfs 中 grep 不可用，使用 dmesg
echo 'dmesg' | sudo tee /dev/ttyUSB0
sudo timeout 30 cat /dev/ttyUSB0
```

## 参考资料
- [vivado-risc-v 项目](https://github.com/eugene-tarassov/vivado-risc-v)
- [Issue #84: UUID does not exist](https://github.com/eugene-tarassov/vivado-risc-v/issues/84) - SD 卡参数配置问题
- [Issue #192: Kernel cannot read partition table](https://github.com/eugene-tarassov/vivado-risc-v/issues/192) - I/O 错误问题
- 璞致 PA-StarLite 原理图

## Git 仓库

板级支持文件已提交到 dev 服务器的 vivado-risc-v 仓库:

```
commit 8492e88 - Add PA200T-StarLite board support
```

提交内容:
- `board/pa200t-starlite/` - 板级支持文件
- `board/pa200t-starlite/patches/fpga-axi-sdc-bypass-card-detect.patch` - 内核补丁

**注意**: 子模块 (linux-stable, u-boot 等) 的修改没有提交到主仓库，
需要在构建时手动应用补丁。

## 更新记录
- 2026-01-11: 初始文档创建, 记录当前进展和待解决问题
- 2026-01-11: 发现 card_detect 问题，添加 broken-cd 属性尝试修复
- 2026-01-11: **Linux 成功启动！** 修改 fpga-axi-sdc 驱动绕过 card_detect，
  SD 卡检测成功，根文件系统挂载成功，Debian Linux (trixie) 正常运行
- 2026-01-11: 提交板级支持到 git 仓库 (commit 8492e88)
