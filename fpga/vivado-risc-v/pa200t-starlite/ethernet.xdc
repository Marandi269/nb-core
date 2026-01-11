## PA200T-StarLite Gigabit Ethernet (RTL8211F RGMII)
## From: Puzhi PA-StarLite Schematic.pdf Page 12

# RGMII TX (from FPGA to PHY) - using vivado-risc-v naming convention
set_property -dict { PACKAGE_PIN P19 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports {rgmii_td[0]}]
set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports {rgmii_td[1]}]
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports {rgmii_td[2]}]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports {rgmii_td[3]}]
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports rgmii_tx_ctl]
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports rgmii_txc]

# RGMII RX (from PHY to FPGA)
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {rgmii_rd[0]}]
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports {rgmii_rd[1]}]
set_property -dict { PACKAGE_PIN R19 IOSTANDARD LVCMOS33 } [get_ports {rgmii_rd[2]}]
set_property -dict { PACKAGE_PIN W20 IOSTANDARD LVCMOS33 } [get_ports {rgmii_rd[3]}]
set_property -dict { PACKAGE_PIN P20 IOSTANDARD LVCMOS33 } [get_ports rgmii_rx_ctl]
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports rgmii_rxc]

# MDIO - using vivado-risc-v naming convention
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports eth_mdio_clock]
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports eth_mdio_data]

# PHY Reset - using vivado-risc-v naming convention  
# PA200T-StarLite PHY_RST is on T19 (Bank 14, LVCMOS33 compatible)
set_property -dict { PACKAGE_PIN T19 IOSTANDARD LVCMOS33 } [get_ports eth_mdio_reset]

# PHY Interrupt - tie to unused pin (PA200T-StarLite doesn't have dedicated int pin)
# T20 is in Bank 14, LVCMOS33 compatible
set_property -dict { PACKAGE_PIN T20 IOSTANDARD LVCMOS33 } [get_ports eth_mdio_int]

# RGMII Timing
create_clock -period 8.000 -name rgmii_rx_clk [get_ports rgmii_rxc]
