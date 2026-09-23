set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports sys_clk]
create_clock -add -name sys_clk_pin -period 8.000 -waveform {0 4} [get_ports sys_clk]