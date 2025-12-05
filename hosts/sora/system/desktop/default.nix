{
  self,
  inputs,
  system,
  pkgs,
  ...
}:
let
  audiorelay = pkgs.callPackage "${inputs.stackpkgs}/packages/audiorelay.nix" { };
  inherit (self.packages.${system}) ytmd;
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

    # Games
    (prismlauncher.override {
      jdks = [
        jdk8
        jdk11
        jdk17
        jdk21
      ];
    })
    r2modman
    lutris

    # Hardware
    openrgb
    nvtopPackages.nvidia

    # Media
    kdePackages.elisa
    pinta
    ytmd

    # VMs
    virt-manager
    virt-viewer

    # Web
    chromium
    discord-canary
    # mullvad-vpn

    # Misc
    waydroid-helper
    localsend
    metadata-cleaner
    bleachbit
    textpieces
  ];

  # Android
  programs.adb.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  # Needed for chrome-based browsers' sandboxing
  security.chromiumSuidSandbox.enable = true;

  # Needed for flatpak
  services.flatpak.enable = true;

  programs.partition-manager.enable = true;

  # OBS
  # programs.obs-studio.enable = true;
  # programs.obs-studio.enableVirtualCamera = true;
  # programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
  #   input-overlay
  #   obs-pipewire-audio-capture
  # ];

  programs.gamemode.enable = true;

  # Steam
  programs.steam.enable = true;
  programs.steam.extraPackages = with pkgs; [
    (mangohud.override {
      nvidiaSupport = true;
    })
  ];
  programs.steam.package = pkgs.steam.override {
    extraEnv = {
      MANGOHUD = true;
    };
  };
  programs.steam.extest.enable = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;
  programs.steam.protontricks.enable = true;
  programs.steam.remotePlay.openFirewall = true;

  # Waydroid
  virtualisation.waydroid.enable = true;
  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };

  # Winbox for router management
  programs.winbox.enable = true;
  programs.winbox.package = self.packages.${system}.winbox4;
  programs.winbox.openFirewall = true;
}
