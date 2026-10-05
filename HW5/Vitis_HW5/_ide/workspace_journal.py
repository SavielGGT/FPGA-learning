# 2026-10-05T17:22:53.280002400
import vitis

client = vitis.create_client()
client.set_workspace(path="Vitis_HW5")

platform = client.create_platform_component(name = "hw5_platform",hw_design = "$COMPONENT_LOCATION/../../HW5_DMA/dma_mb_3/design_1_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

comp = client.create_app_component(name="frame_dma_app",platform = "$COMPONENT_LOCATION/../hw5_platform/export/hw5_platform/hw5_platform.xpfm",domain = "standalone_microblaze_0")

platform = client.get_component(name="hw5_platform")
status = platform.build()

status = platform.build()

comp = client.get_component(name="frame_dma_app")
comp.build()

vitis.dispose()

vitis.dispose()

