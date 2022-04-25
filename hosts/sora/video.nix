{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver libvdpau-va-gl vaapiVdpau ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ nvidia-vaapi-driver libvdpau-va-gl vaapiVdpau ];
  };

  # NVIDIA VA-API is fucked.
  # It breaks VSCode and makes everything laggy.
  # environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
  # environment.sessionVariables.VDPAU_DRIVER = "nvidia";
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
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
    Option         "VariableRefresh" "true"
    SubSection     "Display"
      Depth        24
      Modes        "1920x1080" "1366x768" "1280x720"
    EndSubSection
  '';

  services.xserver.xrandrHeads = [
    {
      output = "DP-2";
      primary = true;
      monitorConfig = ''
        Modeline "1920x1080_143.85"  452.00  1920 2088 2296 2672  1080 1083 1088 1177 -hsync +vsync
        Modeline "1368x768_143.85"  226.25  1368 1480 1624 1880  768 771 781 838 -hsync +vsync
        Modeline "1280x720_143.85"  198.75  1280 1384 1520 1760  720 723 728 786 -hsync +vsync
        Option "PreferredMode" "1920x1080_143.85"
      '';
    }
    {
      output = "HDMI-1";
      monitorConfig = ''
        Modeline "1920x1080_74.97"  220.75  1920 2064 2264 2608  1080 1083 1088 1130 -hsync +vsync
        Modeline "1368x768_74.97"  109.25  1368 1448 1592 1816  768 771 781 805 -hsync +vsync
        Modeline "1280x720_74.97"   95.75  1280 1360 1488 1696  720 723 728 755 -hsync +vsync
        Option "PreferredMode" "1920x1080_74.97"
        Option "RightOf" "DP-2"
      '';
    }
  ];

  # Configure keymap in X11
  services.xserver.layout = "br";
}
