{
  lib,
  pkgs,
  config,
  ...
}: {
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = ["nohibernate"];
  # boot.initrd.supportedFilesystems = [ "zfs" ]; # boot from zfs
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
