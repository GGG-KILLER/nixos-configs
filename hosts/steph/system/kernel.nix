{ pkgs, ... }:
{
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
  services.scx.extraArgs = [ "--autopower" ];
}
