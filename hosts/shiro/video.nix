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
  hardware.opengl.driSupport32Bit = true;

  environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
  hardware.nvidia = {
    package = nvidiaDriver;

    open = true;
    modesetting.enable = false;
    nvidiaSettings = false;
  };
}
