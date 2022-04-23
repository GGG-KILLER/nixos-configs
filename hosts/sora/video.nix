{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    # extraPackages = with pkgs; [ nvidia-vaapi-driver libvdpau-va-gl vaapiVdpau ];
    # extraPackages32 = with pkgs.pkgsi686Linux; [ nvidia-vaapi-driver libvdpau-va-gl vaapiVdpau ];
  };

  # NVIDIA VA-API is fucked.
  # It breaks VSCode and makes everything laggy.
  # environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
  # environment.sessionVariables.VDPAU_DRIVER = "nvidia";
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # modesetting.enable = true;
    powerManagement.enable = true;
  };

  services.xserver.screenSection = ''
    Option         "Stereo" "0"
    Option         "nvidiaXineramaInfoOrder" "DFP-3"
    Option         "metamodes" "DP-2: 1920x1080_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}, HDMI-1: 1920x1080_75 +1920+28 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
    SubSection     "Display"
      Depth        24
      Modes        "1920x1080" "1366x768" "1280x720"
    EndSubSection
  '';
}
