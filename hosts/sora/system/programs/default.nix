{
  system,
  self,
  inputs,
  pkgs,
  config,
  ...
}:
let
  dotnet-sdk = (
    with pkgs.dotnetCorePackages;
    combinePackages [
      # sdk_10_0 # TODO: Re-enable when it actually has useful things and doesn't break C# DevKit and Rider
      sdk_9_0
      sdk_8_0
    ]
  );
  dotnetRoot = "${dotnet-sdk}/share/dotnet";

  agenix = inputs.agenix.packages.${system}.default;
  audiorelay = pkgs.callPackage "${inputs.stackpkgs}/packages/audiorelay.nix" { };
  deploy-rs = inputs.deploy-rs.packages.${system}.deploy-rs;
  git-crypt-agessh = inputs.git-crypt-agessh.packages.${system}.default;
  ipgen-cli = inputs.ipgen-cli.packages.${system}.default;

  inherit (self.packages.${system})
    kemono-dl
    m3u8-dl
    vivaldi-wayland
    ;
  inherit (config.boot.kernelPackages) turbostat;
in
{
  environment.systemPackages = (
    with pkgs;
    [
      # Audio
      audiorelay
      easyeffects
      helvum

      # Android
      android-tools

      # Coding
      # avalonia-ilspy # TODO: re-add when it no longer depends on .NET 6
      corepack_latest
      delta
      docker-compose
      dotnet-ef
      dotnet-outdated
      dotnet-repl
      dotnet-sdk
      jetbrains.rider
      mockoon
      nix-prefetch-scripts
      nixd
      nixf
      nixfmt-rfc-style
      nodejs_latest
      powershell
      tokei

      # Downloads
      aria
      kemono-dl
      m3u8-dl
      yt-dlp

      # Encryption
      age
      agenix
      git-crypt-agessh
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

      # Nix
      deploy-rs
      nh
      nix-output-monitor
      nixpkgs-review

      # Media
      ffmpeg
      kdePackages.elisa

      # Terminal tools
      du-dust
      dua
      dysk
      fd
      mprocs
      parted
      ripgrep
      turbostat
      wl-clipboard
      xh
      uutils-coreutils-noprefix

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
      ipgen-cli
      mockoon
      zenmonitor
    ]
  );

  environment.shellAliases = {
    df = "dysk";
    du = "dust";
  };

  environment.variables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";

    DEFAULT_BROWSER = "/run/current-system/sw/bin/vivaldi"; # Use /run/current-system (avoids the need of refreshing env by restarting)
  };

  environment.etc = {
    "dotnet/install_location".text = dotnetRoot;
  };
}
