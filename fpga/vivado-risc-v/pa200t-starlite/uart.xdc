## PA200T-StarLite UART (CH340E USB-UART)
## From: Puzhi PA-StarLite Schematic.pdf Page 9
## Note: Swapped TX/RX - P14 is FPGA RX (from CH340 TX), P15 is FPGA TX (to CH340 RX)

set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports usb_uart_txd]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports usb_uart_rxd]
