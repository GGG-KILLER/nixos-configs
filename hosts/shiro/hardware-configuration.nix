{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [
    "kvm-amd"
    "nct6775"
    "zenpower"
    "it87"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    zenpower
    it87
  ];
  boot.blacklistedKernelModules = [ "k10temp" ];
  boot.extraModprobeConfig = ''
    options it87 force_id=0xa40
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
    ];
  };

  fileSystems."/etc" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=etc"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/var/lib" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=var/lib"
      "compress=zstd"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=var/log"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/var/spool" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=var/spool"
      "compress=zstd"
    ];
  };

  fileSystems."/root" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=home/root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home/ggg" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=home/ggg"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A4DE-1888";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/storage/services/live-stream-dvr" = {
    device = "storage/services/live-stream-dvr";
    fsType = "zfs";
  };

  fileSystems."/storage/services/danbooru" = {
    device = "storage/services/danbooru";
    fsType = "zfs";
  };

  fileSystems."/storage/series" = {
    device = "storage/series";
    fsType = "zfs";
  };

  fileSystems."/storage/minio" = {
    device = "storage/minio";
    fsType = "zfs";
  };

  fileSystems."/storage/h" = {
    device = "storage/h";
    fsType = "zfs";
  };

  fileSystems."/storage/etc" = {
    device = "storage/etc";
    fsType = "zfs";
  };

  fileSystems."/storage/animu" = {
    device = "storage/animu";
    fsType = "zfs";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement.cpuFreqGovernor = "powersave";
}
