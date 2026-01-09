# FPGA工具链安装指南

## 目标开发板

**ULX3S-85F**
- FPGA: Lattice ECP5 LFE5U-85F
- 资源: 84K LUT, 208KB BRAM
- RAM: 32MB SDRAM
- 工具链: 开源（Yosys + nextpnr + prjtrellis）

---

## 安装步骤（Arch Linux）

### 1. Yosys（综合工具）

```bash
sudo pacman -S yosys
```

**版本**: 0.54+
**用途**: 将Verilog代码综合成门级网表

### 2. nextpnr-ecp5（布局布线）

```bash
yay -S nextpnr-ecp5-nightly
```

**说明**:
- nextpnr不在官方仓库，需要从AUR安装
- nightly版本包含最新特性和bug修复
- 会自动安装prjtrellis依赖

**依赖项**:
- prjtrellis-nightly: ECP5 FPGA数据库
- qt5-base: GUI支持（可选）
- eigen: 数学库
- boost: C++库

### 3. openFPGALoader（烧录工具）

```bash
sudo pacman -S openfpgaloader
```

**版本**: 1.0.0+
**用途**: 通过USB将bitstream烧录到FPGA

---

## 验证安装

```bash
# 检查工具版本
yosys --version
nextpnr-ecp5 --version
openFPGALoader --version

# 测试ULX3S连接（板子到货后）
openFPGALoader --detect
```

**预期输出**:
```
Jtag frequency : 6000000Hz
found 1 device
index 0:
        idcode 0x41111043
        manufacturer lattice
        family ECP5
        model  LFE5U-85
        irlength 8
```

---

## 用户权限配置

### 添加到uucp组（串口访问）

```bash
sudo usermod -aG uucp $USER
# 需要重新登录生效
```

### USB权限配置

创建udev规则文件：
```bash
sudo tee /etc/udev/rules.d/53-lattice-ftdi.rules > /dev/null <<EOF
# ULX3S FPGA board
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666"
EOF

# 重新加载udev规则
sudo udevadm control --reload-rules
sudo udevadm trigger
```

---

## 目录结构

```
nb-core/
├── fpga/
│   ├── constraints/
│   │   └── ulx3s_v20.lpf    # ULX3S引脚约束
│   ├── build/               # 综合输出目录
│   └── Makefile             # FPGA构建脚本
├── rtl/                     # Verilog源码
└── docs/02-fpga/           # FPGA相关文档
```

---

## 常用命令

### 综合流程

```bash
# 1. Yosys综合
yosys -p "read_verilog cpu.v; synth_ecp5 -top cpu_single_cycle -json cpu.json"

# 2. nextpnr布局布线
nextpnr-ecp5 --85k --package CABGA381 --json cpu.json \
    --lpf constraints/ulx3s.lpf --textcfg cpu.config

# 3. 生成bitstream
ecppack cpu.config cpu.bit

# 4. 烧录到FPGA
openFPGALoader -b ulx3s cpu.bit
```

### Makefile自动化（推荐）

```bash
make synth    # 综合
make pnr      # 布局布线
make bitgen   # 生成bitstream
make prog     # 烧录到SRAM（临时）
make flash    # 烧录到Flash（永久）
```

---

## 故障排除

### 问题1: nextpnr编译时间过长

**原因**: 从源码编译需要5-10分钟
**解决**: 正常现象，耐心等待

### 问题2: 无法检测到ULX3S

```bash
# 检查USB设备
lsusb | grep -i "FTDI\|0403:6015"

# 检查内核日志
dmesg | tail -20

# 手动测试FTDI
ls -l /dev/ttyUSB* /dev/ttyACM*
```

### 问题3: Permission denied

```bash
# 确认用户在uucp组
groups | grep uucp

# 检查udev规则
ls -l /etc/udev/rules.d/53-lattice-ftdi.rules
```

---

## 下一步

工具链安装完成后，继续：
1. 📄 [综合流程指南](synthesis-guide.md)
2. 📄 [ULX3S约束文件配置](ulx3s-constraints.md)
3. 📄 [FPGA测试流程](../04-testing/fpga-test-guide.md)

---

## 参考资料

- [Yosys官方文档](http://yosyshq.net/yosys/)
- [nextpnr文档](https://github.com/YosysHQ/nextpnr)
- [Project Trellis](https://github.com/YosysHQ/prjtrellis)
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader)
- [ULX3S项目](https://github.com/emard/ulx3s)
