{
  config,
  lib,
  modulesPath,
  ...
}:
let
  enable-hdds = !config.cost-saving.enable || !config.cost-saving.disable-hdds;
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
    ];
  };

  fileSystems."/partition-root" = {
    device = "/dev/disk/by-uuid/65c29b59-a760-426f-af56-85a6b4c5da13";
    fsType = "btrfs";
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
    enable = enable-hdds;
    device = "storage/services/live-stream-dvr";
    fsType = "zfs";
  };

  fileSystems."/storage/services/danbooru" = {
    enable = enable-hdds;
    device = "storage/services/danbooru";
    fsType = "zfs";
  };

  fileSystems."/storage/series" = {
    enable = enable-hdds;
    device = "storage/series";
    fsType = "zfs";
  };

  fileSystems."/storage/minio" = {
    enable = enable-hdds;
    device = "storage/minio";
    fsType = "zfs";
  };

  fileSystems."/storage/h" = {
    enable = enable-hdds;
    device = "storage/h";
    fsType = "zfs";
  };

  fileSystems."/storage/etc" = {
    enable = enable-hdds;
    device = "storage/etc";
    fsType = "zfs";
  };

  fileSystems."/storage/animu" = {
    enable = enable-hdds;
    device = "storage/animu";
    fsType = "zfs";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
