{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;
in {
  # Enable the GNOME Desktop Environment.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  # Wayland tweaks
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.xwayland.enable = true;

  # Remote Desktop
  services.gnome.gnome-remote-desktop.enable = true;

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
