{ pkgs, ... }:
{
  # Enable KDE.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.autoNumlock = true;

  services.desktopManager.plasma6.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Add Discover to install Flatpak programs with
  environment.systemPackages = with pkgs.kdePackages; [ discover ];

  # Wayland tweaks
  programs.xwayland.enable = true;

  # Needed for theming
  programs.dconf.enable = true;

  # Remove some default packages
  environment.plasma6.excludePackages = [
    # Don't use the browser integration
    pkgs.kdePackages.plasma-browser-integration
    # Remove Kate since it keeps showing up when I type Kon for Konsole and I don't even use it
    pkgs.kdePackages.kate
  ];
}
