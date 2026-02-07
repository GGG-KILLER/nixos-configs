{ ... }:
{
  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.systemd-boot.windows."11" = {
    title = "Windows 11";
    efiDeviceHandle = "HD0a0a1";
  };

  # Boot Order
  boot.loader.systemd-boot.windows."11".sortKey = "x_windows";
  boot.loader.systemd-boot.sortKey = "y_nixos"; # make nixos 2nd to last
  boot.loader.systemd-boot.memtest86.sortKey = "z_memtest86"; # make memtest86+ last
}
