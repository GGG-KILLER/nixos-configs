{ lib, ... }:
{
  # ZFS boot settings.
  boot.supportedFilesystems = {
    zfs = true;
    ntfs = true;
  };

  # Make the root partition ephemeral
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/nixos/root@blank
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
