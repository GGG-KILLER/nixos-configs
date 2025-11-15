{ pkgs, ... }:
{
  # Kernel params
  boot.kernelParams = [
    # ZFS-related params
    "zfs.zfs_arc_max=${toString (16 * 1024 * 1024 * 1024)}"
    "elevator=none"
    "nohibernate"

    # Enable IOMMU
    "amd_iommu=on"
  ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos-gcc;

  # Add ext4 support
  system.fsPackages = [ pkgs.e2fsprogs ];
  boot.supportedFilesystems = {
    ext3 = true;
    ext4 = true;
    btrfs = true;
  };
  boot.kernelModules = [
    "ext2"
    "ext4"
  ];

  # Scheduler
  services.scx.enable = true;
  services.scx.package = pkgs.scx.rustscheds;
  services.scx.scheduler = "scx_lavd";
  services.scx.extraArgs = [ "--performance" ];
}
