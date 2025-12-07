{ config, pkgs, ... }:
{
  boot.kernelModules = [ "nvidia-uvm" ]; # Needed for VA-API
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    enable32Bit = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";
    NVD_BACKEND = "direct";
  };

  hardware.nvidia = {
    # TODO: When 590 comes out, remove this fallback. 580 is the last version to support the Quadro P400.
    package =
      config.boot.kernelPackages.nvidiaPackages.legacy_580
        or config.boot.kernelPackages.nvidiaPackages.stable;

    # NOTE: Open kernel module does not work with the Quadro P400
    open = false;
    modesetting.enable = true;
    nvidiaSettings = false;
    powerManagement.enable = false;
    forceFullCompositionPipeline = true;
  };
}
