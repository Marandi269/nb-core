## PA200T-StarLite SD Card
## From: Puzhi PA-StarLite Schematic.pdf Page 10

set_property -dict { PACKAGE_PIN AA20 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports sdio_clk]
set_property -dict { PACKAGE_PIN AB21 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports sdio_cmd]
set_property -dict { PACKAGE_PIN AB18 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports {sdio_dat[0]}]
set_property -dict { PACKAGE_PIN AA18 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports {sdio_dat[1]}]
set_property -dict { PACKAGE_PIN AB22 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports {sdio_dat[2]}]
set_property -dict { PACKAGE_PIN AA21 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports {sdio_dat[3]}]

# SD Card Detect - PA200T-StarLite has no CD pin, assign to unused GPIO
# W21 is an unused pin in Bank 14 (LVCMOS33)
set_property -dict { PACKAGE_PIN W21 IOSTANDARD LVCMOS33 } [get_ports sdio_cd]

# SD Card Reset - PA200T-StarLite has no dedicated reset, assign to unused GPIO
# Y21 is an unused pin in Bank 14 (LVCMOS33)
set_property -dict { PACKAGE_PIN Y21 IOSTANDARD LVCMOS33 } [get_ports sdio_reset]
