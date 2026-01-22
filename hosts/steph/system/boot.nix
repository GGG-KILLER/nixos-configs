{ lib, ... }:
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Boot Order
  boot.loader.systemd-boot.sortKey = "y_nixos"; # make nixos 2nd to last
  boot.loader.systemd-boot.memtest86.sortKey = "z_memtest86"; # make memtest86+ last
}
