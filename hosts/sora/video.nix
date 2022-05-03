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
    #powerManagement.enable = true;
  };

  services.xserver = {
    exportConfiguration = true;

    deviceSection = ''
      VendorName     "NVIDIA Corporation"
      BoardName      "NVIDIA GeForce RTX 3080"
    '';

    screenSection = ''
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "nvidiaXineramaInfoOrder" "DFP-3"
      Option         "metamodes" "DP-2: 1920x1080_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}, HDMI-1: 1920x1080_75 +1920+28 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On}"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
      Option         "VariableRefresh" "true"
    '';

    extraDisplaySettings = ''
      Modes        "1920x1080_144" "1920x1080_75"
    '';

    xrandrHeads = [
      {
        output = "DP-2";
        primary = true;
        monitorConfig = ''
          # HorizSync source: edid, VertRefresh source: edid
          VendorName     "Acer"
          ModelName      "Acer KG241Q P"
          HorizSync       180.0 - 180.0
          VertRefresh     48.0 - 144.0
          DisplaySize     521.395 293.285
          Modeline       "1920x1080_144"  452.50  1920 2088 2296 2672  1080 1083 1088 1177 -hsync +vsync
          Modeline       "1368x768_144"  226.50  1368 1480 1624 1880  768 771 781 838 -hsync +vsync
          Option         "PreferredMode" "1920x1080_144"
          Option         "DPMS"
        '';
      }
      {
        output = "HDMI-1";
        monitorConfig = ''
          # HorizSync source: edid, VertRefresh source: edid
          VendorName     "LG Electronics"
          ModelName      "LG Electronics LG FULL HD 24MK430H-B"
          HorizSync       30.0 - 85.0
          VertRefresh     48.0 - 75.0
          DisplaySize     527.04 296.46
          Modeline       "1920x1080_75"  220.75  1920 2064 2264 2608  1080 1083 1088 1130 -hsync +vsync
          Modeline       "1368x768_75"  109.50  1368 1448 1592 1816  768 771 781 805 -hsync +vsync
          Option         "PreferredMode" "1920x1080_75"
          Option         "Position" "+1920+28"
          Option         "DPMS"
        '';
      }
    ];

    # Configure keymap in X11
    layout = "br";
  };
}
