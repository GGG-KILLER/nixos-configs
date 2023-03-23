{
  config,
  lib,
  ...
}: let
  stableDriver = config.boot.kernelPackages.nvidiaPackages.stable;
  unstableDriver = config.boot.kernelPackages.nvidiaPackages.beta;
  nvidiaDriver =
    if (lib.versionOlder unstableDriver.version stableDriver.version)
    then stableDriver
    else unstableDriver;
in {
  services.xserver.videoDrivers = ["nvidia"];

  environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
  hardware.nvidia = {
    package = nvidiaDriver;

    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
    forceFullCompositionPipeline = true;
  };
}
