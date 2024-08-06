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

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
    enable32Bit = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";
    NVD_BACKEND = "direct";
  };

  hardware.nvidia = {
    package = nvidiaDriver;

    # NOTE: Open kernel module does not work with the Quadro P400
    open = false;
    modesetting.enable = true;
    nvidiaSettings = false;
    powerManagement.enable = false;
    forceFullCompositionPipeline = true;
  };
}
