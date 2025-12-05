{ pkgs, ... }:
{
  # Enable KDE.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Add Discover
  environment.systemPackages = with pkgs.kdePackages; [ discover ];

  # Wayland tweaks
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # programs.xwayland.enable = true;

  # Theming
  programs.dconf.enable = true;
  # qt.enable = true;
  # qt.platformTheme = "kde";
  # qt.style = "breeze";

  # Remove some default packages
  environment.plasma6.excludePackages = [
    # Don't use the browser integration
    pkgs.kdePackages.plasma-browser-integration
    # Remove Kate since it keeps showing up when I type Kon for Konsole and I don't even use it
    pkgs.kdePackages.kate
  ];
}
