# 2026-09-23T18:59:47.621873700
import vitis

client = vitis.create_client()
client.set_workspace(path="Vitis_MicroBlaze")

platform = client.create_platform_component(name = "microblaze_platform",hw_design = "$COMPONENT_LOCATION/../../HW4_MicroBlaze/microblaze_system_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="microblaze_platform")
status = platform.build()

comp = client.create_app_component(name="running_leds_mb",platform = "$COMPONENT_LOCATION/../microblaze_platform/export/microblaze_platform/microblaze_platform.xpfm",domain = "standalone_microblaze_0")

status = platform.build()

comp = client.get_component(name="running_leds_mb")
comp.build()

status = platform.build()

comp.build()

vitis.dispose()

