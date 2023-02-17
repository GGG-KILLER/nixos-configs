{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd" "nct6775" "zenpower" "it87"];
  boot.extraModulePackages = with config.boot.kernelPackages; [zenpower it87];
  boot.blacklistedKernelModules = ["k10temp"];
  boot.extraModprobeConfig = ''
    options it87 force_id=0xa40
  '';

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
