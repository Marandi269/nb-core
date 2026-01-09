# Vivado 安装指南（纯 CLI 使用）

> 本文档说明如何在 Linux 上安装 Vivado 并进行纯命令行开发

## 目录

- [下载 Vivado](#下载-vivado)
- [安装步骤](#安装步骤)
- [环境配置](#环境配置)
- [验证安装](#验证安装)
- [许可证配置](#许可证配置)
- [常见问题](#常见问题)

---

## 下载 Vivado

### 1. 注册 AMD/Xilinx 账号

访问：https://www.xilinx.com/registration.html

**注意**：需要真实邮箱验证

### 2. 选择版本

推荐版本：
- **Vivado ML 2023.2** (最新稳定版)
- **Vivado 2022.2** (长期支持版本)

下载页面：https://www.xilinx.com/support/download.html

### 3. 选择安装包

| 版本 | 大小 | 说明 | 推荐 |
|------|------|------|------|
| **Vivado ML Standard** | ~50GB | 完整版（收费） | ❌ |
| **Vivado ML WebPACK** | ~35GB | 免费版 | ✅ ⭐ |
| **Vivado Lab Edition** | ~3GB | 仅烧录工具 | ⚪ |

**推荐下载**：`Vivado ML WebPACK` (免费，支持 Artix-7)

**下载方式**：
- **在线安装器**：较小，安装时下载（推荐）
- **完整安装包**：单文件 ~35GB

### 4. Linux 下载命令

```bash
# 使用 wget（如果下载链接可直达）
wget -O Xilinx_Unified_2023.2_1013_2256_Lin64.bin \
  "https://www.xilinx.com/member/forms/download/xef.html?filename=..."

# 或使用浏览器下载到 ~/Downloads/
```

---

## 安装步骤

### 方法1：在线安装器（推荐）

```bash
# 1. 给安装器添加执行权限
cd ~/Downloads
chmod +x Xilinx_Unified_2023.2_1013_2256_Lin64.bin

# 2. 运行安装器（需要 GUI，即使装CLI版也要）
./Xilinx_Unified_2023.2_1013_2256_Lin64.bin

# 3. 按照图形界面提示操作：
#    - 输入 Xilinx 账号登录
#    - 选择 "Vivado ML WebPACK"
#    - 安装位置选择 /opt/Xilinx（推荐）
#    - 取消勾选不需要的组件（如 Model Composer）
#    - 等待下载和安装（约 1-2 小时）
```

**安装组件选择**：
- ✅ Vivado ML WebPACK
- ✅ Artix-7 设备支持
- ❌ Model Composer（不需要）
- ❌ DocNav（不需要）
- ⚪ Vitis（如果需要软核处理器开发）

### 方法2：命令行批量安装（高级）

创建配置文件 `install_config.txt`：

```ini
#### Vivado ML WebPACK Install Configuration ####
Edition=Vivado ML WebPACK
Product=Vivado

# 安装路径
Destination=/opt/Xilinx

# 模块
Modules=Vivado:1,DocNav:0,Vitis:0

# 设备支持
InstallOptions=Artix-7:1,Kintex-7:0,Virtex-7:0,Zynq-7000:0

# 许可证
CreateProgramGroupShortcuts=0
```

批量安装命令：

```bash
sudo ./Xilinx_Unified_2023.2_1013_2256_Lin64.bin \
  --agree XilinxEULA,3rdPartyEULA \
  --batch Install \
  --config install_config.txt
```

**注意**：批量安装仍需要 GUI 环境（X11）

---

## 环境配置

### 1. 设置环境变量

每次使用 Vivado 前需要 source：

```bash
source /opt/Xilinx/Vivado/2023.2/settings64.sh
```

### 2. 添加到 shell 配置（可选）

**不推荐**自动加载（会污染环境）

推荐使用 alias：

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
alias vivado-env='source /opt/Xilinx/Vivado/2023.2/settings64.sh'

# 使用时：
vivado-env
vivado -version
```

### 3. 创建快捷脚本

```bash
cat > ~/.local/bin/vivado-nb <<'EOF'
#!/bin/bash
# nb-core 项目专用 Vivado 环境

source /opt/Xilinx/Vivado/2023.2/settings64.sh
cd ~/nb-core/fpga/xilinx
exec bash
EOF

chmod +x ~/.local/bin/vivado-nb
```

使用：

```bash
vivado-nb  # 进入配置好的环境
```

---

## 验证安装

### 1. 检查版本

```bash
source /opt/Xilinx/Vivado/2023.2/settings64.sh
vivado -version
```

**预期输出**：

```
Vivado v2023.2 (64-bit)
SW Build 4029153 on Fri Oct 13 20:13:54 MDT 2023
IP Build 4028589 on Sat Oct 14 00:45:43 MDT 2023
```

### 2. 测试 CLI 模式

```bash
vivado -mode batch -source /opt/Xilinx/Vivado/2023.2/scripts/test.tcl
```

### 3. 检查设备支持

```bash
vivado -mode tcl

# 在 Tcl 提示符下：
Vivado% get_parts xc7a200t*
# 应该列出 Artix-7 设备

Vivado% quit
```

---

## 许可证配置

### Vivado WebPACK（免费版）

**无需额外许可证**，但需要：

1. **联网激活**（首次使用）
2. **Xilinx 账号登录**

### 验证许可证

```bash
source /opt/Xilinx/Vivado/2023.2/settings64.sh
vlm -checkout Vivado
```

### 离线许可证（可选）

如果网络不稳定，可以申请离线许可证：

1. 访问：https://www.xilinx.com/getlicense
2. 生成许可证文件（.lic）
3. 设置环境变量：

```bash
export XILINXD_LICENSE_FILE=/path/to/Xilinx.lic
```

---

## 常见问题

### Q1: 安装器无法启动

**问题**：`./Xilinx_Unified_*.bin` 无反应

**解决**：

```bash
# 检查是否有 GUI 环境
echo $DISPLAY
# 如果为空，需要设置 X11

# 如果使用 SSH，需要 X11 转发
ssh -X user@host

# 或使用 VNC/xrdp
```

### Q2: 磁盘空间不足

**问题**：安装需要 100GB+ 空间

**解决**：

- 清理 `/tmp` 目录
- 使用 `df -h` 检查磁盘
- 考虑安装到其他分区

### Q3: Vivado 启动很慢

**问题**：首次启动需要 1-2 分钟

**原因**：Vivado 加载大量库

**解决**：正常现象，后续会快些

### Q4: 找不到 libstdc++

**问题**：

```
error while loading shared libraries: libstdc++.so.6
```

**解决**：

```bash
# Arch Linux
sudo pacman -S gcc-libs

# Ubuntu/Debian
sudo apt install libstdc++6
```

### Q5: 命令找不到

**问题**：`vivado: command not found`

**解决**：

```bash
# 必须先 source 环境
source /opt/Xilinx/Vivado/2023.2/settings64.sh

# 或添加到 PATH
export PATH=/opt/Xilinx/Vivado/2023.2/bin:$PATH
```

---

## 纯 CLI 工作流程

### 推荐工作方式

```bash
# 1. 启动终端，激活环境
source /opt/Xilinx/Vivado/2023.2/settings64.sh

# 2. 进入项目目录
cd ~/nb-core/fpga/xilinx

# 3. 使用 Makefile
make build      # 综合、布局、布线
make report     # 查看报告
make program    # 烧录 FPGA

# 4. 不需要打开 GUI！
```

### 查看报告

```bash
# 时序报告
less scripts/build/post_route_timing.rpt

# 资源利用率
grep -A 30 "Slice Logic" scripts/build/post_route_util.rpt

# 功耗报告
less scripts/build/power.rpt
```

---

## 磁盘空间建议

| 用途 | 空间 |
|------|------|
| Vivado 安装 | 40GB |
| 临时文件（安装时） | 20GB |
| 项目构建文件 | 5-10GB |
| **总计** | **~70GB** |

---

## 卸载 Vivado

```bash
# 删除安装目录
sudo rm -rf /opt/Xilinx/Vivado/2023.2

# 删除用户配置
rm -rf ~/.Xilinx

# 清理环境变量
# 从 ~/.bashrc 或 ~/.zshrc 中移除相关行
```

---

## 下一步

安装完成后：

1. 📄 [Xilinx 构建指南](synthesis-guide-xilinx.md) - 学习如何综合
2. 📄 [约束文件配置](constraints-xilinx.md) - 配置引脚映射
3. 📄 [时序分析](timing-analysis.md) - 理解时序报告

---

**维护者**: nb-core 项目团队
**最后更新**: 2026-01-09
**文档版本**: v1.0 (Vivado CLI)
