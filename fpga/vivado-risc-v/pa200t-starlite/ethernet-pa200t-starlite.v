// Stub module - ethernet disabled for initial DDR3 testing
module ethernet_pa200t_starlite (
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock125 CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF TX_AXIS:RX_AXIS, ASSOCIATED_RESET reset, FREQ_HZ 125000000" *)
    input wire clock125,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock125_90 CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
    input wire clock125_90,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock200 CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
    input wire clock200,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TDATA" *)
    input wire [7:0] tx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TKEEP" *)
    input wire [0:0] tx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TVALID" *)
    input wire tx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TREADY" *)
    output wire tx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TLAST" *)
    input wire tx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TUSER" *)
    input wire tx_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TDATA" *)
    output wire [7:0] rx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TKEEP" *)
    output wire [0:0] rx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TVALID" *)
    output wire rx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TREADY" *)
    input wire rx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TLAST" *)
    output wire rx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TUSER" *)
    output wire rx_axis_tuser,

    output wire [15:0] status_vector,

    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TD" *)
    output [3:0] rgmii_txd,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TX_CTL" *)
    output rgmii_tx_ctl,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TXC" *)
    output rgmii_tx_clk,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RD" *)
    input [3:0] rgmii_rxd,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RX_CTL" *)
    input rgmii_rx_ctl,
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RXC" *)
    input rgmii_rx_clk
);

// Tie off all outputs - ethernet disabled
assign tx_axis_tready = 1'b0;
assign rx_axis_tdata = 8'b0;
assign rx_axis_tkeep = 1'b0;
assign rx_axis_tvalid = 1'b0;
assign rx_axis_tlast = 1'b0;
assign rx_axis_tuser = 1'b0;
assign status_vector = 16'b0;

// Tie off RGMII outputs
assign rgmii_txd = 4'b0;
assign rgmii_tx_ctl = 1'b0;
assign rgmii_tx_clk = 1'b0;

endmodule
