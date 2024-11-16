{ pkgs, ... }:
{
  boot.zfs.package = pkgs.zfs_unstable;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_11;
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
