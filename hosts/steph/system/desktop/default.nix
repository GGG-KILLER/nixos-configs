{
  self,
  inputs,
  system,
  pkgs,
  ...
}:
let
  audiorelay = pkgs.callPackage "${inputs.stackpkgs}/packages/audiorelay.nix" { };
  inherit (self.packages.${system}) vivaldi-wayland;
in
{
  imports = [
    ./audio
    ./kde.nix
  ];

  environment.systemPackages = with pkgs; [
    # Audio
    audiorelay
    crosspipe

    # Android
    android-tools

    # Coding
    (
      # HACK: early NixOS/nixpkgs#506159 but with a newer version
      assert jetbrains.rider.version == "2025.3.3";
      jetbrains.rider.overrideAttrs (old: {
        src = fetchurl {
          url = "https://download.jetbrains.com/rider/JetBrains.Rider-2026.1.0.1.tar.gz";
          hash = "sha256-moIysTTsq7abpQfNh1Bc5Pk6VQgJIT6erbyHsUXf15Y=";
        };

        version = "2026.1.0.1";
        buildNumber = "261.22158.394";

        postInstall = ''
          ls -d \
            $out/*/bin/*/linux/*/lib/liblldb.so \
            $out/*/bin/*/linux/*/lib/python3.*/lib-dynload/* \
            $out/*/plugins/*/bin/*/linux/*/lib/liblldb.so \
            $out/*/plugins/*/bin/*/linux/*/lib/python3.*/lib-dynload/* |
          xargs patchelf \
            --replace-needed libssl.so.10 libssl.so \
            --replace-needed libssl.so.1.1 libssl.so \
            --replace-needed libcrypto.so.10 libcrypto.so \
            --replace-needed libcrypto.so.1.1 libcrypto.so \
            --replace-needed libcrypt.so.1 libcrypt.so \

          for dir in $out/rider/lib/ReSharperHost/linux-*; do
            rm -rf $dir/dotnet
            ln -s ${self.packages.${system}.combined-dotnet-sdk} $dir/dotnet
          done
        '';
      })
    )
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
    mullvad-vpn
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

  # Input Remapper to re-add dedicated / key
  services.input-remapper.enable = true;
}
