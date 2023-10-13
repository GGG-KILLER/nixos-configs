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

  # CVE-2023-43641 mitigations
  services.gnome.gnome-online-miners.enable = mkForce false;
  services.gnome.tracker-miners.enable = mkForce false;
}
