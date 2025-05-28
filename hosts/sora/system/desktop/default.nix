{
  system,
  self,
  pkgs,
  inputs,
  ...
}:
let
  audiorelay = pkgs.callPackage "${inputs.stackpkgs}/packages/audiorelay.nix" { };

  inherit (self.packages.${system})
    vivaldi-wayland
    ;
in
{
  imports = [
    ./audio
    ./opensnitch
    ./kde.nix
    # ./rustdesk.nix # TODO: Uncomment once NixOS/nixpkgs#390171 hits stable.
  ];

  environment.systemPackages = with pkgs; [
    # Audio
    audiorelay
    easyeffects
    helvum

    # Android
    android-tools

    # Coding
    jetbrains.rider
    mockoon

    # Encryption
    xca
    yubikey-manager
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
    (r2modman.overrideDerivation (oldAttrs: {
      patches = [ patches/r2modman-flatpak-launch.patch ];
    }))

    # Hardware
    openrgb

    # Media
    kdePackages.elisa

    # VMs
    virt-manager
    virt-viewer

    # Web
    chromium
    discord-canary
    mullvad-vpn
    vivaldi-wayland

    # Misc
    imhex
    mockoon
    zenmonitor

  ];

  # Android
  programs.adb.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  security.chromiumSuidSandbox.enable = true;

  services.flatpak.enable = true;

  programs.goldwarden.enable = true;
  programs.goldwarden.useSshAgent = false;

  programs.gpu-screen-recorder.enable = true;

  programs.partition-manager.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.enableVirtualCamera = true;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    input-overlay
    obs-pipewire-audio-capture
  ];

  programs.gamemode.enable = true;

  programs.steam.enable = true;
  programs.steam.extraPackages = with pkgs; [
    mangohud
    gamescope
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
}
