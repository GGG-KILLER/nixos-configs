{ pkgs, config, ... }:
{
  boot.zfs.package = pkgs.zfs_unstable;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [
    "zfs.zfs_arc_max=${toString (8 * 1024 * 1024 * 1024)}"
    "nohibernate"
  ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.loader.grub = {
    enable = true;
    copyKernels = true;
    efiSupport = true;
    fsIdentifier = "label";
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = true;
}
