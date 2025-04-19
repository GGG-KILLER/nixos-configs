{ config, pkgs, ... }:
{
  boot.zfs.package = pkgs.zfs_unstable;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
  boot.kernelParams = [
    "zfs.zfs_arc_max=${toString (8 * 1024 * 1024 * 1024)}"
    "nohibernate"
  ];
  boot.supportedFilesystems = [
    "btrfs"
    "zfs"
  ];

  # TODO: enable
  # Reset root after every boot
  # boot.initrd.postDeviceCommands = lib.mkAfter ''
  #   mkdir /mnt
  #   mount -t btrfs ${config.fileSystems."/".device}
  #   btrfs subvolume delete /mnt/root
  #   btrfs subvolume snapshot /mnt/root-blank /mnt/root
  # '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
