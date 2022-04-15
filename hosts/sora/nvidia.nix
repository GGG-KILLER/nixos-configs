{ config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  services.xserver.screenSection = ''
    Option         "nvidiaXineramaInfoOrder" "DFP-3"
    Option         "metamodes" "DP-2: nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}, HDMI-1: nvidia-auto-select +1920+28 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';
}
