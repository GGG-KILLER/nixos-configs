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
  hardware.graphics.enable = true;

  environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
  hardware.nvidia = {
    package = nvidiaDriver;

    # NOTE: Open kernel module does not work with the Quadro P400
    modesetting.enable = false;
    nvidiaSettings = false;
  };
}
