# nb-core Xilinx Artix-7 移植版本

> 本目录包含 nb-core RISC-V CPU 在 Xilinx Artix-7 平台上的实现

## 📋 目标硬件

**开发板**: PA200T-starlite
**FPGA**: Xilinx Artix-7 XC7A200T-2SBG484C

**规格**:
- 134,600 LUTs
- 269,200 FFs
- 13,140 Kb Block RAM
- 740 DSP Slices

## 🚀 快速开始

### 1. 安装 Vivado

参考详细文档：[Vivado 安装指南](../../docs/02-fpga/vivado-setup.md)

**快速版本**：

```bash
# 下载 Vivado ML 2023.2 WebPACK (免费)
# https://www.xilinx.com/support/download.html

# 安装（需要 GUI，约 1-2 小时）
chmod +x Xilinx_Unified_2023.2_*.bin
./Xilinx_Unified_2023.2_*.bin

# 选择：
# - Vivado ML WebPACK（免费版）
# - 安装路径：/opt/Xilinx
# - 设备支持：Artix-7
```

### 2. 配置引脚约束

**⚠️ 重要**：必须根据实际开发板配置引脚！

编辑文件：`constraints/pa200t_starlite.xdc`

```xdc
## 根据开发板原理图修改引脚号（PACKAGE_PIN）
set_property -dict { PACKAGE_PIN E3 ... } [get_ports { clk }];
set_property -dict { PACKAGE_PIN D10 ... } [get_ports { uart_tx }];
# ... 更多引脚
```

**获取正确引脚映射**：
- 查看开发板附带的原理图PDF
- 查看厂商提供的示例约束文件
- 咨询开发板厂商技术支持

### 3. 构建 Bitstream

```bash
# 激活 Vivado 环境
source /opt/Xilinx/Vivado/2023.2/settings64.sh

# 进入 Xilinx 项目目录
cd fpga/xilinx

# 纯 CLI 构建（约 10-20 分钟）
make build

# 查看报告
make report

# 烧录到 FPGA（需要连接开发板）
make program
```

### 4. 验证

构建成功后会生成：

```
fpga/xilinx/scripts/build/
├── nb_core.bit              # Bitstream 文件
├── post_route_timing.rpt    # 时序报告
├── post_route_util.rpt      # 资源利用率
└── power.rpt                # 功耗报告
```

## 📁 目录结构

```
fpga/xilinx/
├── README.md                  # 本文件
├── Makefile                   # 构建系统
├── constraints/               # 约束文件
│   └── pa200t_starlite.xdc   # 引脚约束（需修改！）
└── scripts/                   # 构建脚本
    ├── build.tcl             # Vivado 综合脚本
    ├── program.tcl           # 烧录脚本
    └── build/                # 输出目录（自动生成）
        ├── nb_core.bit
        └── *.rpt
```

## 🛠️ Makefile 使用

| 命令 | 说明 |
|------|------|
| `make build` | 综合、布局、布线、生成 bitstream |
| `make gui` | 启动 Vivado GUI（调试用） |
| `make program` | 烧录 FPGA |
| `make report` | 显示综合报告 |
| `make clean` | 清理构建文件 |
| `make help` | 显示帮助 |

## ⚙️ 自定义配置

### 修改 FPGA 型号

编辑 `scripts/build.tcl`：

```tcl
set part "xc7a200tsbg484-2"
#         ^^^^^^ ^^^^^^ ^
#         型号   封装  速度等级

# 常见变体：
# xc7a200tsbg484-1  : 速度等级 -1
# xc7a200tsbg484-2  : 速度等级 -2（更快）
# xc7a200tfbg484-2  : 不同封装
```

### 修改时钟频率

编辑 `constraints/pa200t_starlite.xdc`：

```xdc
## 50MHz 时钟
create_clock -period 20.00 [get_ports { clk }];

## 100MHz 时钟（改为）
create_clock -period 10.00 [get_ports { clk }];
```

### 修改 Vivado 版本

编辑 `Makefile`：

```makefile
VIVADO_VERSION = 2024.1  # 改为你的版本
```

## 🔍 故障排除

### 问题1：Vivado 找不到

```bash
# 检查安装路径
ls /opt/Xilinx/Vivado/

# 修改 Makefile 中的 VIVADO_ROOT
```

### 问题2：约束错误

```
ERROR: [Place 30-58] IO placer failed...
```

**原因**：引脚号（PACKAGE_PIN）不正确

**解决**：根据开发板原理图修改 `.xdc` 文件

### 问题3：时序不满足

```
Timing NOT met!
```

**解决**：
- 降低时钟频率
- 添加流水线
- 使用更高速度等级的 FPGA

### 问题4：资源不足

```
ERROR: [Place 30-640] Placer could not place all instances
```

**解决**：
- 优化 RTL 代码
- 使用更大的 FPGA（XC7A200T 应该足够）

## 📊 预期资源使用

基于单周期 RV64IMA CPU：

| 资源 | 使用 | 可用 | 利用率 |
|------|------|------|--------|
| LUTs | ~40K | 134K | ~30% |
| FFs | ~30K | 269K | ~11% |
| BRAM | ~50 Kb | 13,140 Kb | <1% |
| DSP | ~10 | 740 | ~1% |

## 🔗 相关文档

- [Vivado 安装指南](../../docs/02-fpga/vivado-setup.md)
- [项目主文档](../../docs/README.md)
- [Xilinx Vivado 用户手册](https://docs.xilinx.com/r/en-US/ug892-vivado-design-flows-overview)
- [Artix-7 数据手册](https://www.xilinx.com/support/documentation/data_sheets/ds180_7Series_Overview.pdf)

## ⚠️ 重要提示

1. **约束文件必须修改**
   默认的引脚号是示例，使用前必须根据实际开发板原理图修改！

2. **首次构建较慢**
   Vivado 首次运行会初始化缓存，需要 10-20 分钟

3. **烧录前检查连接**
   确保开发板通过 JTAG 连接到电脑

4. **备份原始 bitstream**
   某些开发板出厂带有示例程序，烧录前建议备份

## 📝 TODO

- [ ] 添加 DDR3 控制器支持
- [ ] 添加 AXI 总线接口
- [ ] 优化时序（目标 100MHz）
- [ ] 添加 ChipScope 调试支持
- [ ] 创建 Block Design（IP Integrator）版本

---

**维护者**: nb-core 项目团队
**最后更新**: 2026-01-09
**平台**: Xilinx Artix-7 XC7A200T
