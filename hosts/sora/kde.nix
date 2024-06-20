{pkgs, ...}: {
  # Enable KDE.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Add Discover
  environment.systemPackages = with pkgs.kdePackages; [discover];

  # Wayland tweaks
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.xwayland.enable = true;

  # Theming
  programs.dconf.enable = true;
  qt.enable = true;
  qt.platformTheme = "kde";
  qt.style = "breeze";
}
