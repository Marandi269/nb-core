# NB-Core Makefile

# 工具配置
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
VERILATOR = verilator

# 目录
RTL_DIR = rtl
TB_DIR = tb
SIM_DIR = sim
BUILD_DIR = build

# RTL源文件
RTL_CORE = $(wildcard $(RTL_DIR)/core/*.v)
RTL_PERIPH = $(wildcard $(RTL_DIR)/peripherals/*.v)
RTL_SOC = $(wildcard $(RTL_DIR)/soc/*.v)
RTL_ALL = $(RTL_CORE) $(RTL_PERIPH) $(RTL_SOC)

# 默认目标
.PHONY: all clean sim wave help

all: help

help:
	@echo "NB-Core 构建系统"
	@echo "================"
	@echo "make sim-alu      - 仿真ALU模块"
	@echo "make sim-regfile  - 仿真寄存器文件"
	@echo "make sim-cpu      - 仿真CPU核心"
	@echo "make test         - 运行所有测试"
	@echo "make wave         - 查看波形"
	@echo "make clean        - 清理构建文件"
	@echo "make lint         - 代码检查"
	@echo "make setup        - 安装仿真工具"

# 创建构建目录
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# 仿真ALU
sim-alu: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/alu_tb.vvp \
		-I$(RTL_DIR)/core $(RTL_DIR)/core/alu.v $(TB_DIR)/alu_tb.v
	$(VVP) $(BUILD_DIR)/alu_tb.vvp

# 仿真寄存器文件
sim-regfile: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/regfile_tb.vvp \
		-I$(RTL_DIR)/core $(RTL_DIR)/core/regfile.v $(TB_DIR)/regfile_tb.v
	$(VVP) $(BUILD_DIR)/regfile_tb.vvp

# 仿真CPU
sim-cpu: $(BUILD_DIR)
	$(IVERILOG) -o $(BUILD_DIR)/cpu_tb.vvp \
		-I$(RTL_DIR)/core $(RTL_CORE) $(TB_DIR)/cpu_tb.v
	$(VVP) $(BUILD_DIR)/cpu_tb.vvp

# 运行所有测试
test: sim-alu sim-regfile sim-cpu
	@echo "所有测试完成"

# 查看波形
wave:
	$(GTKWAVE) $(SIM_DIR)/cpu_wave.vcd &

wave-cpu:
	$(GTKWAVE) $(SIM_DIR)/cpu_wave.vcd &

# Verilator lint检查
lint:
	$(VERILATOR) --lint-only -Wall $(RTL_ALL)

# 清理
clean:
	rm -rf $(BUILD_DIR) $(SIM_DIR)/*.vcd *.vcd

# 安装仿真工具 (Ubuntu/Debian)
setup:
	@echo "安装仿真工具..."
	@command -v iverilog >/dev/null 2>&1 || { \
		echo "安装 iverilog..."; \
		sudo apt-get update && sudo apt-get install -y iverilog gtkwave; \
	}
	@echo "工具安装完成"
	@iverilog -V
	@gtkwave --version

.PHONY: all clean help test sim-alu sim-regfile sim-cpu wave wave-cpu lint setup
