{ config, lib, pkgs, modulesPath, ... }:

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
  };

  fileSystems."/nix" = {
    device = "zfs-main-pool/system/nix";
    fsType = "zfs";
  };

  fileSystems."/var" = {
    device = "zfs-main-pool/system/var";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3859-C504";
    fsType = "vfat";
  };

  swapDevices = [ ];
}
