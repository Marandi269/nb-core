# Verilator增强仿真器Makefile

# 工具链
VERILATOR = verilator
CXX = g++

# 路径配置
RTL_DIR = ../../rtl/core
BUILD_DIR = obj_dir

# Verilog源文件
VERILOG_SOURCES = \
	$(RTL_DIR)/cpu_single_cycle.v \
	$(RTL_DIR)/alu.v \
	$(RTL_DIR)/regfile.v \
	$(RTL_DIR)/decoder.v \
	$(RTL_DIR)/pc.v \
	$(RTL_DIR)/imem.v \
	$(RTL_DIR)/dmem.v

# C++源文件
CPP_SOURCES = \
	cpu_tb_enhanced.cpp \
	elf_loader.cpp \
	uart_sim.cpp

# 顶层模块
TOP_MODULE = cpu_single_cycle

# Verilator标志
VERILATOR_FLAGS = \
	--cc \
	--exe \
	--build \
	-Wall \
	-Wno-fatal \
	--public \
	--top-module $(TOP_MODULE) \
	-I$(RTL_DIR)

# VCD波形生成标志
TRACE_FLAGS = --trace --trace-depth 99

# 编译标志
CFLAGS = -std=c++14 -O2

# 默认目标：编译仿真器（无波形）
.PHONY: all
all: $(BUILD_DIR)/V$(TOP_MODULE)

# 编译仿真器（无波形）- 快速模式
$(BUILD_DIR)/V$(TOP_MODULE): $(VERILOG_SOURCES) $(CPP_SOURCES)
	@echo "Building fast simulator (no VCD)..."
	$(VERILATOR) $(VERILATOR_FLAGS) \
		-CFLAGS "$(CFLAGS)" \
		$(VERILOG_SOURCES) \
		$(CPP_SOURCES)

# 编译仿真器（带波形）- 调试模式
.PHONY: trace
trace: $(BUILD_DIR)/V$(TOP_MODULE)_trace

$(BUILD_DIR)/V$(TOP_MODULE)_trace: $(VERILOG_SOURCES) $(CPP_SOURCES)
	@echo "Building trace simulator (with VCD)..."
	$(VERILATOR) $(VERILATOR_FLAGS) $(TRACE_FLAGS) \
		-CFLAGS "$(CFLAGS)" \
		$(VERILOG_SOURCES) \
		$(CPP_SOURCES)
	@mv $(BUILD_DIR)/V$(TOP_MODULE) $(BUILD_DIR)/V$(TOP_MODULE)_trace

# 清理
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -f *.vcd *.log

# 运行示例（需要提供ELF文件）
.PHONY: run
run: all
	@echo "Usage: $(BUILD_DIR)/V$(TOP_MODULE) [options] <elf_file>"
	@echo "Example: $(BUILD_DIR)/V$(TOP_MODULE) --cycles 100000 program.elf"

# 帮助信息
.PHONY: help
help:
	@echo "Verilator Enhanced Simulator Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all          Build fast simulator (no waveform)"
	@echo "  trace        Build debug simulator (with VCD)"
	@echo "  clean        Remove build artifacts"
	@echo "  help         Show this help"
	@echo ""
	@echo "Usage:"
	@echo "  make                    # Build fast simulator"
	@echo "  make trace              # Build with VCD support"
	@echo "  make clean              # Clean build"
	@echo ""
	@echo "Run simulator:"
	@echo "  ./obj_dir/V$(TOP_MODULE) program.elf"
	@echo "  ./obj_dir/V$(TOP_MODULE)_trace --vcd trace.vcd program.elf"
