# 2026-09-22T22:20:36.698982600
import vitis

client = vitis.create_client()
client.set_workspace(path="Vitis_Zynq_PS")

platform = client.create_platform_component(name = "zybo_platform",hw_design = "$COMPONENT_LOCATION/../../HW4_Zynq_PS/zynq_system_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

comp = client.create_app_component(name="running_leds_ps",platform = "$COMPONENT_LOCATION/../zybo_platform/export/zybo_platform/zybo_platform.xpfm",domain = "standalone_ps7_cortexa9_0")

platform = client.get_component(name="zybo_platform")
status = platform.build()

status = platform.build()

comp = client.get_component(name="running_leds_ps")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

vitis.dispose()

