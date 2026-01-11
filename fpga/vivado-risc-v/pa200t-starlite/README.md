# PA200T-StarLite Board Support for vivado-risc-v

Board support files for Puzhi PA200T-StarLite FPGA development board.

## Hardware Specifications

- **FPGA**: Xilinx XC7A200T-2FBG484I (Artix-7)
- **DDR3 Memory**: 1GB (2x MT41K256M16TW-107, 32-bit width)
- **Storage**: MicroSD card slot, 128Mb SPI Flash (W25Q128)
- **Interfaces**:
  - USB-UART (CH340E) - Serial console
  - JTAG (FT232H) - Programming/Debug
  - Gigabit Ethernet (RTL8211F RGMII)
  - HDMI output (ADV7513)
  - USB 2.0 Host
- **Clock**: 200MHz differential input

## SoC Configuration

- **Config**: rocket64b2 (Dual-core Rocket, RV64IMAFDC)
- **CPU Clock**: 40 MHz
- **DDR3 Clock**: 400 MHz (800 MT/s)
- **Peripherals**:
  - AXI SD Card Controller @ 0x60000000
  - AXI UART @ 0x60010000
  - AXI Ethernet @ 0x60020000 (not yet working)

## Files

- `Makefile.inc` - Board configuration
- `riscv-2025.2.tcl` - Vivado block design script
- `bootrom.dts` - Device tree overlay for peripherals
- `official-mig.prj` - DDR3 MIG configuration
- `uart.xdc` - UART pin constraints (P14/P15, TX/RX swapped)
- `sdc.xdc` - SD card pin constraints
- `ethernet.xdc` - Ethernet pin constraints (RTL8211F RGMII)
- `top.xdc` - Top-level constraints (clock routing, etc.)

## Required Patches

### Linux Kernel: MMC Card Detect Fix

The AXI SD Card controller's card_detect register reports card absent (0x9)
even when a card is inserted. Apply the patch in `patches/` directory:

```bash
cd linux-stable
patch -p1 < ../board/pa200t-starlite/patches/fpga-axi-sdc-bypass-card-detect.patch
```

This patch modifies `drivers/mmc/host/fpga-axi-sdc.c` to always report
card present, bypassing the unreliable hardware card detect.

## Build Instructions

```bash
# Set up environment
source /opt/Xilinx/2025.2/Vivado/settings64.sh

# Build bitstream
make bitstream BOARD=pa200t-starlite CONFIG=rocket64b2

# Build bootloader (OpenSBI + U-Boot)
make bootloader BOARD=pa200t-starlite CONFIG=rocket64b2

# Build Linux kernel (after applying patches)
cd linux-stable
patch -p1 < ../board/pa200t-starlite/patches/fpga-axi-sdc-bypass-card-detect.patch
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j$(nproc)
```

## Boot Time Reference (40MHz CPU)

- Kernel boot to driver init: ~14 seconds
- SD card detection: ~14 seconds
- Root filesystem mount: ~117 seconds
- systemd startup: ~127 seconds
- Full boot to login: ~10 minutes

## Known Issues

1. **Ethernet not working** - Driver/PHY configuration needs work
2. **Card Detect** - Hardware signal unreliable, requires kernel patch
3. **Slow boot** - Expected at 40MHz, can potentially increase to 50-80MHz

## Pin Notes

- UART TX/RX pins are swapped compared to typical convention
- SD card directly connected (active low directly from design)

## Author

Board support created for PA200T-StarLite, January 2026.
