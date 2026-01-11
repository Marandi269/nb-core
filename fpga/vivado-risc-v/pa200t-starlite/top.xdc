## PA200T-StarLite Constraints File
## XC7A200T-2FBG484I with 1GB DDR3
## From: Puzhi PA-StarLite Schematic.pdf

##############################################################################
# System Clock - 200MHz Differential (DDR Bank 34)
##############################################################################
set_property -dict { PACKAGE_PIN R4 IOSTANDARD DIFF_SSTL15 } [get_ports sys_diff_clock_clk_p]
set_property -dict { PACKAGE_PIN T4 IOSTANDARD DIFF_SSTL15 } [get_ports sys_diff_clock_clk_n]

##############################################################################
# Reset - Active LOW (Active when pressed)
##############################################################################
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports reset]

##############################################################################
# Configuration
##############################################################################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

##############################################################################
# Clock Routing - Allow non-optimal clock routing for IBUFDS to MMCM
##############################################################################
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets riscv_i/util_ds_buf_0/U0/IBUF_OUT[0]]

##############################################################################
# Fan Control - PA200T-StarLite has no fan connector, assign to unused GPIO
##############################################################################
set_property -dict { PACKAGE_PIN Y22 IOSTANDARD LVCMOS33 } [get_ports fan_en]
