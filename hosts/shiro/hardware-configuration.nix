{ config, lib, pkgs, modulesPath, ... }:

let
  zmount = name: {
    device = name;
    fsType = "zfs";
    options = [ "zfsutil" "nofail" ];
  };
in
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "zfs-main-pool/system/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/nix" = {
    device = "zfs-main-pool/system/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/var" = {
    device = "zfs-main-pool/system/var";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3859-C504";
    fsType = "vfat";
  };

  fileSystems."/var/lib/grafana" = zmount "zfs-main-pool/data/monitoring/grafana";

  fileSystems."/var/lib/prometheus2" = zmount "zfs-main-pool/data/monitoring/prometheus";

  fileSystems."/var/lib/docker" = zmount "zfs-main-pool/system/var/lib/docker";

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-id/ata-TOSHIBA_HDWD120_49GV1LAAS-part1";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/mnt/zfs-backup" = {
    device = "/dev/disk/by-id/ata-TOSHIBA_HDWD120_49GV1LAAS-part2";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  swapDevices = [ ];
}
