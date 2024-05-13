{
  config,
  lib,
  pkgs,
  ...
}: let
  stableDriver = config.boot.kernelPackages.nvidiaPackages.stable;
  unstableDriver = config.boot.kernelPackages.nvidiaPackages.beta;
  nvidiaDriver =
    if (lib.versionOlder unstableDriver.version stableDriver.version)
    then stableDriver
    else unstableDriver;
in {
  boot.kernelModules = ["nvidia-uvm"]; # Needed for VA-API
  services.xserver.videoDrivers = ["nvidia"];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
    driSupport = true;
    driSupport32Bit = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";
    NVD_BACKEND = "direct";
  };

  hardware.nvidia = {
    package = nvidiaDriver;

    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
    forceFullCompositionPipeline = true;
  };
}
