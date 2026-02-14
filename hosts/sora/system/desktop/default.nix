{ pkgs, ... }:
{
  imports = [
    ./audio
    ./programs.nix
  ];

  # KDE
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.autoNumlock = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    ark
    elisa
    gwenview
    okular
    kate
    ktexteditor
    spectacle
    ffmpegthumbs
    krdp
  ];

  # Auto Login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ggg";

  # Enable NetworkManager
  networking.networkmanager.enable = true;
}
