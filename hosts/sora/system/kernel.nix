{ pkgs, ... }:
{
  # Kernel params
  boot.kernelParams = [
    # ZFS-related params
    "zfs.zfs_arc_max=${toString (16 * 1024 * 1024 * 1024)}"
    "elevator=none"
    "nohibernate"

    # Use amd_pstate_epp
    "amd_pstate=active"

    # Enable IOMMU
    "amd_iommu=on"
  ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_6_12; # TODO: Increase when ZFS supports 6.13

  # Scheduler
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  services.scx.extraArgs = [ "--performance" ];
}
