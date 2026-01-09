## PA200T-starlite Board Constraints
## Xilinx Artix-7 XC7A200T-2SBG484C

## 说明：
## 这是模板约束文件，需要根据实际开发板原理图调整引脚号
## 请参考你的开发板手册获取准确的引脚映射

##############################################################################
# 时钟输入
##############################################################################

## 系统时钟 - 通常是 50MHz 或 100MHz 晶振
## 请根据实际板子调整引脚号和频率
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports { clk }];
## 20ns = 50MHz，如果是100MHz改为 period 10.00

##############################################################################
# 复位信号
##############################################################################

## 复位按键 - 通常是低电平有效
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { rst_n }];

##############################################################################
# UART 串口
##############################################################################

## USB-UART（通常使用 FT2232H）
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports { uart_tx }];
set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports { uart_rx }];

##############################################################################
# LED 指示灯
##############################################################################

## 用户LED（示例，通常有4-8个）
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { led[3] }];

##############################################################################
# DDR3 存储器（如果使用）
##############################################################################

## DDR3 引脚需要根据实际原理图详细配置
## 这里省略，后续需要时再添加

##############################################################################
# 时序约束
##############################################################################

## 输入延迟约束
set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 2.0 [get_ports { uart_rx }];
set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 5.0 [get_ports { uart_rx }];

## 输出延迟约束
set_output_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.0 [get_ports { uart_tx }];
set_output_delay -clock [get_clocks sys_clk_pin] -max -add_delay 3.0 [get_ports { uart_tx }];

## 输出约束
set_output_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.0 [get_ports { led[*] }];
set_output_delay -clock [get_clocks sys_clk_pin] -max -add_delay 3.0 [get_ports { led[*] }];

##############################################################################
# 配置选项
##############################################################################

## 配置电压
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

## Bitstream 设置
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design];
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design];
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design];

##############################################################################
# 注意事项
##############################################################################

## ⚠️  重要：上述引脚号（PACKAGE_PIN）都是示例！
## 必须参考你的 PA200T-starlite 开发板原理图或手册
## 找到正确的引脚映射，否则会损坏硬件！

## 🔍 如何获取正确的引脚：
## 1. 查看开发板附带的原理图 PDF
## 2. 查看厂商提供的示例约束文件
## 3. 使用 Vivado 的引脚规划工具（Pin Planner）

## 📖 Xilinx 约束文件语法参考：
## https://www.xilinx.com/support/documentation/sw_manuals/xilinx2023_2/ug903-vivado-using-constraints.pdf
