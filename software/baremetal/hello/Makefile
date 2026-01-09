# 裸机Hello World程序Makefile

# 工具链前缀
CROSS_COMPILE = riscv64-linux-gnu-

CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
READELF = $(CROSS_COMPILE)readelf

# 编译选项
CFLAGS = -march=rv64ima -mabi=lp64 \
         -O2 \
         -nostdlib -nostartfiles \
         -fno-builtin \
         -Wall

# 链接选项
LDFLAGS = -T link.ld -nostdlib

# 目标文件
TARGET = hello
OBJS = hello.o

# 默认目标
all: $(TARGET).elf $(TARGET).bin $(TARGET).dump

# 编译C源文件
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 链接生成ELF
$(TARGET).elf: $(OBJS) link.ld
	$(LD) $(LDFLAGS) $(OBJS) -o $@
	@echo ""
	@echo "=== ELF file info ==="
	$(READELF) -h $@

# 生成二进制文件
$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

# 生成反汇编文件
$(TARGET).dump: $(TARGET).elf
	$(OBJDUMP) -d $< > $@

# 清理
clean:
	rm -f *.o *.elf *.bin *.dump

# 运行仿真（需要先编译Verilator仿真器）
run: $(TARGET).elf
	@echo ""
	@echo "=== Running on Verilator ==="
	../../../sim/verilator/obj_dir/Vcpu_single_cycle $<

# 带波形仿真
trace: $(TARGET).elf
	@echo ""
	@echo "=== Running with VCD trace ==="
	../../../sim/verilator/obj_dir/Vcpu_single_cycle_trace \
		--vcd $(TARGET).vcd \
		--cycles 100000 \
		$<
	@echo ""
	@echo "View waveform with: gtkwave $(TARGET).vcd"

.PHONY: all clean run trace
