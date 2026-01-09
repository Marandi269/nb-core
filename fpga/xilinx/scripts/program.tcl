##############################################################################
# Vivado Programming Script
# 用于将 bitstream 烧录到 FPGA
##############################################################################

set project_name "nb_core"
set bitstream "./build/${project_name}.bit"

##############################################################################
# 检查 bitstream 文件
##############################################################################

if {![file exists $bitstream]} {
    puts "ERROR: Bitstream file not found: $bitstream"
    puts "Please run synthesis first!"
    quit
}

##############################################################################
# 打开硬件管理器
##############################################################################

puts "INFO: Opening hardware manager..."
open_hw_manager

##############################################################################
# 连接到硬件服务器
##############################################################################

puts "INFO: Connecting to hardware server..."

## 本地连接
connect_hw_server -allow_non_jtag

## 如果需要远程连接，使用：
# connect_hw_server -url <hostname>:3121

##############################################################################
# 打开目标设备
##############################################################################

puts "INFO: Opening target device..."

## 自动检测 JTAG 链
open_hw_target

## 获取第一个 FPGA 设备
set device [lindex [get_hw_devices] 0]
puts "INFO: Target device: $device"

current_hw_device $device
refresh_hw_device $device

##############################################################################
# 配置 bitstream
##############################################################################

puts "INFO: Programming device with bitstream: $bitstream"

set_property PROGRAM.FILE $bitstream $device

## 烧录到 FPGA SRAM（上电丢失）
program_hw_devices $device

## 如果要烧录到 Flash（永久保存），使用：
# create_hw_cfgmem -hw_device $device -mem_dev [lindex [get_cfgmem_parts {<flash_part>}] 0]
# set_property PROGRAM.FILE $bitstream [get_hw_cfgmems]
# program_hw_cfgmem [get_hw_cfgmems]

##############################################################################
# 完成
##############################################################################

puts "INFO: Programming completed successfully!"

## 关闭连接
close_hw_target
disconnect_hw_server
close_hw_manager

quit
