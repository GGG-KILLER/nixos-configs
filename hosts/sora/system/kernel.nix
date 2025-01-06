{ pkgs, ... }:
{
  # Kernel params
  boot.kernelParams = [
    # ZFS-related params
    "zfs.zfs_arc_max=${toString (16 * 1024 * 1024 * 1024)}"
    "elevator=none"
    "nohibernate"
  ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Scheduler
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  services.scx.extraArgs = [ "--performance" ];
}
