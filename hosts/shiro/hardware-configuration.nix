{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  zmount = name: {
    device = name;
    fsType = "zfs";
    options = ["zfsutil" "nofail"];
  };
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "zfs-main-pool/system/root";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/nix" = {
    device = "zfs-main-pool/system/nix";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/var" = {
    device = "zfs-main-pool/system/var";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/var/lib/grafana" = {
    device = "zfs-main-pool/data/monitoring/grafana";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/var/lib/prometheus2" = {
    device = "zfs-main-pool/data/monitoring/prometheus";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/var/lib/docker" = {
    device = "zfs-main-pool/system/var/lib/docker";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3859-C504";
    fsType = "vfat";
  };

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-id/ata-TOSHIBA_HDWD120_49GV1LAAS-part1";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/zfs-backup" = {
    device = "/dev/disk/by-id/ata-TOSHIBA_HDWD120_49GV1LAAS-part2";
    fsType = "ext4";
    options = ["nofail"];
  };

  swapDevices = [];
}
