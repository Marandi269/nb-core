##############################################################################
# Vivado CLI Build Script for nb-core RISC-V CPU
# Target: Xilinx Artix-7 XC7A200T (PA200T-starlite)
##############################################################################

## 使用方法：
## vivado -mode batch -source build.tcl
## 或通过 Makefile 调用

##############################################################################
# 项目配置
##############################################################################

set project_name "nb_core"
set top_module "cpu_single_cycle"
set part "xc7a200tsbg484-2"

## ⚠️ 请根据实际板子调整 part 字符串：
## - xc7a200tsbg484-1  : 速度等级 -1
## - xc7a200tsbg484-2  : 速度等级 -2
## - 封装可能是 sbg484, fbg484 等，查看板子规格书

set rtl_dir "../../rtl/core"
set constraints_dir "../constraints"
set output_dir "./build"

##############################################################################
# 创建输出目录
##############################################################################

file mkdir $output_dir

##############################################################################
# 读取 RTL 源文件
##############################################################################

puts "INFO: Reading RTL source files..."

## 按依赖顺序读取（defines 必须最先）
read_verilog ${rtl_dir}/defines.v
read_verilog ${rtl_dir}/alu.v
read_verilog ${rtl_dir}/regfile.v
read_verilog ${rtl_dir}/pc.v
read_verilog ${rtl_dir}/decoder.v
read_verilog ${rtl_dir}/imem.v
read_verilog ${rtl_dir}/dmem.v
read_verilog ${rtl_dir}/cpu_single_cycle.v

##############################################################################
# 读取约束文件
##############################################################################

puts "INFO: Reading constraint files..."

read_xdc ${constraints_dir}/pa200t_starlite.xdc

##############################################################################
# 综合（Synthesis）
##############################################################################

puts "INFO: Starting synthesis..."

synth_design \
    -top ${top_module} \
    -part ${part} \
    -flatten_hierarchy rebuilt \
    -directive Default \
    -fsm_extraction auto \
    -keep_equivalent_registers \
    -resource_sharing auto \
    -no_lc

## 综合报告
report_timing_summary -file ${output_dir}/post_synth_timing.rpt
report_utilization -file ${output_dir}/post_synth_util.rpt
report_drc -file ${output_dir}/post_synth_drc.rpt

## 保存检查点
write_checkpoint -force ${output_dir}/post_synth.dcp

##############################################################################
# 优化（Optimization）
##############################################################################

puts "INFO: Running optimization..."

opt_design -directive Default

report_timing_summary -file ${output_dir}/post_opt_timing.rpt

##############################################################################
# 电源优化（可选）
##############################################################################

# power_opt_design

##############################################################################
# 布局（Placement）
##############################################################################

puts "INFO: Running placement..."

place_design -directive Default

## 布局后优化
phys_opt_design -directive Default

report_timing_summary -file ${output_dir}/post_place_timing.rpt
report_utilization -file ${output_dir}/post_place_util.rpt

## 保存检查点
write_checkpoint -force ${output_dir}/post_place.dcp

##############################################################################
# 布线（Routing）
##############################################################################

puts "INFO: Running routing..."

route_design -directive Default

## 布线后优化
phys_opt_design -directive Default

report_timing_summary -file ${output_dir}/post_route_timing.rpt
report_timing -sort_by group -max_paths 10 -path_type summary -file ${output_dir}/post_route_timing_detailed.rpt
report_clock_utilization -file ${output_dir}/clock_util.rpt
report_utilization -file ${output_dir}/post_route_util.rpt
report_power -file ${output_dir}/power.rpt
report_drc -file ${output_dir}/post_route_drc.rpt

## 保存检查点
write_checkpoint -force ${output_dir}/post_route.dcp

##############################################################################
# 生成比特流（Bitstream Generation）
##############################################################################

puts "INFO: Generating bitstream..."

write_bitstream -force ${output_dir}/${project_name}.bit

## 生成调试探针文件（如果需要）
# write_debug_probes -force ${output_dir}/${project_name}.ltx

##############################################################################
# 完成
##############################################################################

puts "INFO: Build completed successfully!"
puts "INFO: Bitstream: ${output_dir}/${project_name}.bit"
puts ""
puts "Timing Summary:"
puts "---------------"
report_timing_summary -return_string

##############################################################################
# 退出 Vivado
##############################################################################

quit
