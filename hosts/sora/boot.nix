{
  pkgs,
  lib,
  ...
}: {
  # ZFS boot settings.
  boot.supportedFilesystems = ["zfs" "ntfs"];

  # ZFS Flags
  boot.kernelParams = ["zfs.zfs_arc_max=12884901888" "elevator=none" "nohibernate"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # LQX kernel
  #boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_lqx.override {
    structuredExtraConfig = with lib.kernel; {
      ZSWAP_COMPRESSOR_DEFAULT_ZSTD = lib.mkForce (option no);
    };
  });
}
