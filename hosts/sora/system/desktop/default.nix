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
    ./opensnitch
    ./kde.nix
    # ./rustdesk.nix
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
    yubikey-manager
    yubioath-flutter
    bitwarden-desktop

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
    ytmd

    # VMs
    virt-manager
    virt-viewer

    # Web
    chromium
    discord-canary
    mullvad-vpn

    # Misc
    # imhex # TODO: Uncomment once NixOS/nixpkgs#461461 hits unstable
    mockoon
    zenmonitor
    # rustdesk-flutter
    waydroid-helper
  ];

  # Android
  programs.adb.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  security.chromiumSuidSandbox.enable = true;

  services.flatpak.enable = true;

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

  virtualisation.waydroid.enable = true;
  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };

  programs.winbox.enable = true;
  programs.winbox.package = self.packages.${system}.winbox4;
  programs.winbox.openFirewall = true;
}
