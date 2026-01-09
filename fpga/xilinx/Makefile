# Makefile for Xilinx Artix-7 FPGA Build
# Target: PA200T-starlite (XC7A200T)

##############################################################################
# 配置
##############################################################################

PROJECT = nb_core
TOP_MODULE = cpu_single_cycle

# Vivado 安装路径（根据实际安装位置调整）
VIVADO_VERSION = 2023.2
VIVADO_ROOT = /opt/Xilinx/Vivado/$(VIVADO_VERSION)
VIVADO = $(VIVADO_ROOT)/bin/vivado

# 脚本和目录
BUILD_SCRIPT = scripts/build.tcl
PROGRAM_SCRIPT = scripts/program.tcl
BUILD_DIR = scripts/build

# 输出文件
BITSTREAM = $(BUILD_DIR)/$(PROJECT).bit

##############################################################################
# 环境检查
##############################################################################

.PHONY: check-vivado
check-vivado:
	@if [ ! -f "$(VIVADO)" ]; then \
		echo "❌ 错误: 找不到 Vivado ($(VIVADO))"; \
		echo "请安装 Vivado 或修改 VIVADO_ROOT 变量"; \
		exit 1; \
	fi
	@echo "✅ Vivado 找到: $(VIVADO)"
	@$(VIVADO) -version | head -n 1

##############################################################################
# 构建目标
##############################################################################

.PHONY: all
all: build

.PHONY: build
build: check-vivado
	@echo "================================================"
	@echo "  开始 FPGA 构建"
	@echo "  项目: $(PROJECT)"
	@echo "  顶层模块: $(TOP_MODULE)"
	@echo "================================================"
	$(VIVADO) -mode batch -source $(BUILD_SCRIPT) -notrace -log $(BUILD_DIR)/build.log -journal $(BUILD_DIR)/build.jou
	@echo ""
	@echo "✅ 构建完成！"
	@echo "📦 Bitstream: $(BITSTREAM)"

.PHONY: gui
gui: check-vivado
	@echo "启动 Vivado GUI..."
	$(VIVADO) -source $(BUILD_SCRIPT) &

##############################################################################
# 烧录目标
##############################################################################

.PHONY: program
program: check-vivado
	@if [ ! -f "$(BITSTREAM)" ]; then \
		echo "❌ 错误: 找不到 bitstream 文件"; \
		echo "请先运行 'make build'"; \
		exit 1; \
	fi
	@echo "烧录 FPGA..."
	$(VIVADO) -mode batch -source $(PROGRAM_SCRIPT) -notrace

##############################################################################
# 清理目标
##############################################################################

.PHONY: clean
clean:
	@echo "清理构建文件..."
	rm -rf $(BUILD_DIR)
	rm -rf .Xil
	rm -rf vivado*.jou vivado*.log
	rm -rf *.dcp *.rpt
	@echo "✅ 清理完成"

.PHONY: distclean
distclean: clean
	@echo "深度清理（包括 Vivado 缓存）..."
	rm -rf ~/.Xilinx/Vivado/$(VIVADO_VERSION)/.Xil
	@echo "✅ 深度清理完成"

##############################################################################
# 报告目标
##############################################################################

.PHONY: report
report:
	@if [ -f "$(BUILD_DIR)/post_route_timing.rpt" ]; then \
		echo "=== 时序报告 ==="; \
		head -n 50 $(BUILD_DIR)/post_route_timing.rpt; \
		echo ""; \
		echo "=== 资源利用率 ==="; \
		grep -A 20 "Slice Logic" $(BUILD_DIR)/post_route_util.rpt; \
	else \
		echo "❌ 找不到报告文件，请先运行 'make build'"; \
	fi

##############################################################################
# 帮助信息
##############################################################################

.PHONY: help
help:
	@echo "nb-core Xilinx Artix-7 FPGA 构建系统"
	@echo ""
	@echo "可用目标:"
	@echo "  make build       - 构建 bitstream（纯 CLI）"
	@echo "  make gui         - 启动 Vivado GUI"
	@echo "  make program     - 烧录 FPGA"
	@echo "  make report      - 显示综合报告"
	@echo "  make clean       - 清理构建文件"
	@echo "  make distclean   - 深度清理"
	@echo "  make check-vivado - 检查 Vivado 安装"
	@echo "  make help        - 显示此帮助"
	@echo ""
	@echo "环境变量:"
	@echo "  VIVADO_VERSION   - Vivado 版本 (当前: $(VIVADO_VERSION))"
	@echo "  VIVADO_ROOT      - Vivado 安装路径 (当前: $(VIVADO_ROOT))"
	@echo ""
	@echo "示例:"
	@echo "  make build              # 纯 CLI 构建"
	@echo "  make VIVADO_VERSION=2024.1 build  # 使用不同版本"

.DEFAULT_GOAL := help
