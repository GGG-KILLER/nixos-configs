{
  lib,
  config,
  pkgs,
  ...
}:
with lib; {
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager = {
      gdm.enable = true;
      # xpra.enable = true;
    };

    desktopManager.gnome.enable = true;
  };

  # Remote Desktop
  services.gnome.gnome-remote-desktop.enable = true;
  # programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    gnome.gnome-remote-desktop
    gnome.adwaita-icon-theme
    flat-remix-gtk
    flat-remix-gnome
    flat-remix-icon-theme
  ];
  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
}
