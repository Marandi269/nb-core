# FPGA硬件采购清单

## 推荐方案：ULX3S开发板

### 主板

**ULX3S (推荐配置)**
- 型号: ULX3S-85F
- FPGA芯片: Lattice ECP5-85F (LFE5U-85F-6BG381C)
- 资源: 84K LUTs, 156 KB BRAM
- 价格: ~130-160 USD
- 购买渠道:
  - 官方: https://www.crowdsupply.com/radiona/ulx3s
  - 淘宝: 搜索"ULX3S" (约900-1200元)
  - 国外: Mouser, GroupGets

**配置选项:**
- 内存: 32MB SDRAM (标配，足够Linux)
- 闪存: 16MB Flash (用于存储bitstream)
- 无线: ESP32 (可选，用于WiFi编程，推荐带)

### 必需配件

**1. USB线缆**
- Type-C数据线 (用于供电和编程)
- 建议: 质量好的线，支持数据传输
- 价格: ~10-20元

**2. microSD卡 (可选但推荐)**
- 容量: 8GB或以上
- 速度: Class 10
- 用途: 存储Linux镜像和文件系统
- 价格: ~20-40元

**3. HDMI线 (可选)**
- 如果需要视频输出
- ULX3S有HDMI接口
- 价格: ~15-30元

**4. GPIO扩展 (可选)**
- 杜邦线若干
- 面包板
- 价格: ~20元

### 调试工具

**串口转USB (如果电脑没有串口)**
- 型号: CP2102 或 CH340G USB转TTL模块
- 电平: 3.3V (重要！)
- 价格: ~5-15元
- 注意: ULX3S板载FTDI芯片，通常不需要额外购买

### 可选升级

**JTAG调试器 (高级调试用)**
- ULX3S支持通过ESP32或FTDI调试
- 不需要额外购买
- 使用openFPGALoader即可

---

## 备选方案1: OrangeCrab

**OrangeCrab r0.2.1**
- FPGA: ECP5-85F
- 尺寸: Feather外形，更小巧
- DDR3: 128MB (比ULX3S多)
- 价格: ~100-120 USD
- 购买: https://1bitsquared.com/products/orangecrab
- 注意: 资源丰富但扩展接口较少

**配件:**
- USB-C线
- Feather扩展板 (可选)

---

## 备选方案2: 国产ColorLight i5/i9 (最便宜)

**ColorLight i5**
- FPGA: ECP5-25F (资源较小，可能不够用)
- 价格: ~60-100元
- 优点: 超便宜
- 缺点: 需要自己焊接排针，资源可能不够RV64

**ColorLight i9 Plus**
- FPGA: ECP5-45F
- DDR3: 256MB
- 价格: ~200-300元
- 适合预算有限的情况

---

## 最终推荐配置 (性价比最高)

### 方案A: 完整开发套装
```
1. ULX3S-85F (带ESP32)          ¥1000-1200
2. USB Type-C数据线             ¥15
3. microSD卡 (16GB)            ¥25
4. CP2102 USB转TTL (备用)      ¥10
-------------------------------------------
总计:                           ¥1050-1250
```

### 方案B: 预算版
```
1. ColorLight i9 Plus          ¥250-300
2. USB转串口模块               ¥10
3. JTAG下载器 (可能需要)        ¥30
-------------------------------------------
总计:                           ¥290-340
```

## 工具链安装 (免费)

在Linux上安装开源工具链:

```bash
# Ubuntu/Debian
sudo apt install yosys nextpnr-ecp5 prjtrellis

# Arch Linux
sudo pacman -S yosys nextpnr prjtrellis-db

# 或从源码编译最新版
```

下载工具:
```bash
# openFPGALoader - 用于烧录
sudo apt install openfpgaloader

# 或
pip install openfpgaloader
```

## 总结

**强烈推荐: ULX3S-85F**

原因:
- ✅ 资源充足 (85K LUT)
- ✅ 完整的开源支持
- ✅ 丰富的外设 (HDMI, SD卡, 音频等)
- ✅ 活跃的社区
- ✅ 无需额外下载器
- ✅ 文档完善

**开始顺序:**
1. 先下单ULX3S开发板
2. 等待收货期间，在电脑上搭建仿真环境
3. 用Verilator/Icarus先做软件仿真
4. 板子到货后再综合烧录

这样可以最大化开发效率！
