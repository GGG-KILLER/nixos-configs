{ pkgs, lib, ... }:
{
  # ZFS boot settings.
  boot.supportedFilesystems = [
    "zfs"
    "ntfs"
  ];

  # ZFS Flags
  boot.kernelParams = [
    "zfs.zfs_arc_max=${toString (16 * 1024 * 1024 * 1024)}"
    "elevator=none"
    "nohibernate"
  ];

  # Make the root partition ephemeral
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/nixos/root@blank
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # LQX kernel
  boot.kernelPackages = pkgs.linuxPackages_lqx;
  # boot.kernelPackages = pkgs.linuxPackages_zen; # TODO: Go back to LQX when issue gets fixed.
}
