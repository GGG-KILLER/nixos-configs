{
  self,
  inputs,
  system,
  pkgs,
  ...
}:
let
  audiorelay = pkgs.callPackage "${inputs.stackpkgs}/packages/audiorelay.nix" { };
  inherit (self.packages.${system}) ytmd vivaldi-wayland;
in
{
  imports = [
    ./audio
    ./kde.nix
  ];

  environment.systemPackages = with pkgs; [
    # Audio
    audiorelay
    helvum

    # Android
    android-tools

    # Coding
    jetbrains.rider
    mockoon

    # Encryption
    xca
    yubioath-flutter

    # Hardware

    # Media
    kdePackages.elisa
    pinta
    #ytmd

    # Web
    discord-canary
    #mullvad-vpn
    vivaldi-wayland

    # Misc
    localsend
    metadata-cleaner
    bleachbit
    textpieces
    waydroid-helper
  ];

  # Enable networking (WiFi)
  networking.networkmanager.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  # Needed for chrome-based browsers' sandboxing
  security.chromiumSuidSandbox.enable = true;

  # Needed for flatpak
  services.flatpak.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Partition Manager to be able to format USB drives
  programs.partition-manager.enable = true;

  # Waydroid
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };

  # Winbox for router management
  programs.winbox.enable = true;
  programs.winbox.package = self.packages.${system}.winbox4;
  programs.winbox.openFirewall = true;
}
