{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.always-show-titles-in-overview
    gnomeExtensions.appindicator
    gnomeExtensions.mpris-indicator-button
    gnomeExtensions.transparent-top-bar
    gnomeExtensions.just-perfection
    gnomeExtensions.status-area-horizontal-spacing
    gnomeExtensions.user-themes
    gnomeExtensions.static-background-in-overview
    gnomeExtensions.dash-to-panel
    gnomeExtensions.arcmenu
    gnome.gnome-remote-desktop
  ];
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  # Configure keymap in X11
  services.xserver.layout = "br";

  # Remote Desktop
  services.gnome.gnome-remote-desktop.enable = true;
}
