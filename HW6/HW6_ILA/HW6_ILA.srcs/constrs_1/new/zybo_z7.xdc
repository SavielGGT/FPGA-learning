## 125 MHz system clock
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk_pin -period 8.000 -waveform {0 4.000} [get_ports { clk }]

## Reset - BTN0
set_property -dict { PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports { rst }]

## digit_in[3:0] - SW0..SW3
set_property -dict { PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports { digit_in[0] }]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { digit_in[1] }]
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports { digit_in[2] }]
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports { digit_in[3] }]

## unlocked_led - LED0
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { unlocked_led }]

## Enter - BTN1
set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { enter_btn }]