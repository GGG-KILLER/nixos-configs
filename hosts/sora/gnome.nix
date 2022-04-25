{ lib, config, pkgs, ... }:

with lib;
{
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
  programs.xwayland.enable = true;

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
    gnome3.adwaita-icon-theme
  ];
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
}
