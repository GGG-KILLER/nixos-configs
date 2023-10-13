{
  lib,
  pkgs,
  config,
  ...
}: {
  boot.zfs.enableUnstable = true;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = ["nohibernate"];
  boot.supportedFilesystems = ["zfs"];

  boot.loader.grub = {
    enable = true;
    copyKernels = true;
    efiSupport = true;
    fsIdentifier = "label";
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = true;
}
