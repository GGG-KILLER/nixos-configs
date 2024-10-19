{
  self,
  lib,
  config,
  system,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) getExe head;
  dotnet-sdk =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_9_0
      sdk_8_0
      sdk_7_0
      sdk_6_0
    ];
  dotnetRoot = dotnet-sdk;
  dotnetSdk = "${dotnet-sdk}/sdk";
  xca-stable = inputs.nixpkgs-stable.legacyPackages.${system}.xca;
  avalonia-ilspy = self.packages.${system}.avalonia-ilspy;
  m3u8-dl = self.packages.${system}.m3u8-dl;
  mockoon = self.packages.${system}.mockoon;
  kemono-dl = self.packages.${system}.kemono-dl;
  r2modman = pkgs.r2modman.overrideDerivation (oldAttrs: rec {
    version = "3.1.50";

    src = pkgs.fetchFromGitHub {
      owner = "PedroVH";
      repo = "r2modmanPlus";
      rev = version;
      hash = "sha256-4IO7HLsvKjNns7GPIUgthQCGat+N+oriWyZoMvIQOGc=";
    };

    offlineCache = pkgs.fetchYarnDeps {
      yarnLock = "${src}/yarn.lock";
      hash = "sha256-ntXZ4gRXRqiPQxdwXDsLxGdBqUV5eboy9ntTlJsz9FA=";
    };

    patches = [ ];
  });
in
{
  imports = [
    ./commands
    ./vscode.nix
  ];

  environment.systemPackages = [ dotnet-sdk ];

  home-manager.users.ggg = {
    home.packages =
      (with pkgs; [
        # Audio
        easyeffects
        helvum

        # Android
        android-tools
        android-studio

        # Coding
        avalonia-ilspy
        corepack_latest
        docker-compose
        mockoon
        nixd
        nodejs_latest
        powershell
        tokei

        # Database
        pgformatter
        postgresql_14
        # pgmodeler # TODO: Uncomment this once the hash in nixpkgs gets updated.
        mongodb-compass

        # Encryption
        age
        inputs.agenix.packages.${system}.default
        xca-stable
        yubikey-manager
        yubikey-manager-qt
        #step-cli # TODO: Uncomment if it's still used and NixOS/nixpkgs#301623 has hit unstable.

        # Games
        #inputs.packwiz.packages.${system}.packwiz # TODO: Uncomment when packwiz/packwiz#297 gets fixed.
        (prismlauncher.override {
          jdks = [
            jdk8
            jdk11
            jdk17
            jdk21
          ];
        })
        r2mod_cli

        # Hardware
        openrgb

        # Nix
        inputs.deploy-rs.packages.${system}.deploy-rs
        nh
        nix-output-monitor
        nixpkgs-review

        # Media
        #self.packages.${system}.ffmpeg-full
        ffmpeg
        #handbrake # Uncomment when NixOS/nixpkgs#297984 hits unstable.
        kdePackages.elisa

        # VMs
        virt-manager
        virt-viewer

        # Misc
        aria
        chromium
        discord-canary
        fd
        google-chrome
        imhex
        inputs.ipgen-cli.packages.${system}.default
        inputs.git-crypt-agessh.packages.${system}.default
        m3u8-dl
        mockoon
        mullvad-vpn
        # rustdesk
        yt-dlp
        zenmonitor
        kemono-dl
      ])
      ++ [ r2modman ];

    home.sessionVariables = {
      DOTNET_ROOT = dotnetRoot;
      MSBuildSdksPath = "${dotnetSdk}/${head dotnet-sdk.versions}/Sdks";
      MSBUILD_EXE_PATH = "${dotnetSdk}/${head dotnet-sdk.versions}/MSBuild.dll";

      # PYTORCH_PYTHON = "${pkgs.python3.withPackages (ps:
      #   with ps; [
      #     matplotlib

      #     torch
      #     torchvision
      #     torchtnt
      #     torcheval
      #     botorch
      #     torchinfo
      #     lion-pytorch
      #     torch-tb-profiler
      #   ])}";
    };

    home.shellAliases = { };

    programs = {
      gh = {
        enable = true;
        settings.editor = "${getExe pkgs.vscode} --wait";
      };
      git = {
        enable = true;
        delta.enable = true;
        lfs.enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
        extraConfig = {
          init.defaultBranch = "main";
          credential.helper = "${lib.getExe pkgs.git-credential-manager}";
          credential.credentialStore = "secretservice";
          core.editor = "${getExe pkgs.vscode} --wait";
        };
      };
      tealdeer.enable = true;
      zsh.oh-my-zsh.plugins = [
        "copybuffer"
        "copyfile"
        "docker"
        "docker-compose"
        "dotnet"
        "git"
        "git-auto-fetch"
      ];
      mangohud = {
        enable = true;
        settingsPerApplication = {
          mpv = {
            no_display = true;
          };
        };
      };
      mpv = {
        enable = true;
        config = {
          # Base
          profile = "high-quality";

          # General
          hwdec = "auto";
          vo = "gpu-next";
          gpu-api = "vulkan";
          gpu-context = "waylandvk";
          ao = "pipewire";

          # Disable OSC for mpv thumbnail script
          osc = "no";
        };
      };
      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-nvfbc
          input-overlay
          obs-pipewire-audio-capture
        ];
      };
    };

    services = {
      flameshot.enable = false;
    };

    xdg.configFile."nix/nix.conf".text = ''
      access-tokens = github.com=${config.my.secrets.users.ggg.nixGithubToken}
    '';

    # TODO: add [xdg.desktopEntries](https://nix-community.github.io/home-manager/options.html#opt-xdg.desktopEntries) for seamlessrdp
    xdg.desktopEntries = {
      ilspy = {
        name = "ILSpy";
        exec = getExe avalonia-ilspy;
        categories = [
          "Development"
          "Debugger"
          "Viewer"
        ];
      };
    };

    systemd.user.services.jellyfin-mpv-shim = {
      Unit = {
        Description = "Jellyfin MPV Shim";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service.ExecStart = getExe pkgs.jellyfin-mpv-shim;

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
