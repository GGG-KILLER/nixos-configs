{...}: {
  # Enable KDE.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Wayland tweaks
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.xwayland.enable = true;
}
