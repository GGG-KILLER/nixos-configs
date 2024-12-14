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
    ];
  dotnetRoot = dotnet-sdk;
  dotnetSdk = "${dotnet-sdk}/sdk";

  agenix = inputs.agenix.packages.${system}.default;
  audiorelay = pkgs.callPackage "${inputs.stackpkgs}/packages/audiorelay.nix" { };
  avalonia-ilspy = self.packages.${system}.avalonia-ilspy;
  deploy-rs = inputs.deploy-rs.packages.${system}.deploy-rs;
  dotnet-ef = self.packages.${system}.dotnet-ef;
  git-crypt-agessh = inputs.git-crypt-agessh.packages.${system}.default;
  ipgen-cli = inputs.ipgen-cli.packages.${system}.default;
  kemono-dl = self.packages.${system}.kemono-dl;
  m3u8-dl = self.packages.${system}.m3u8-dl;
  mockoon = self.packages.${system}.mockoon;
  xca-stable = inputs.nixpkgs-stable.legacyPackages.${system}.xca;

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
      (
        with pkgs;
        let
          # Source #1: https://github.com/NixOS/nixpkgs/pull/292148#issuecomment-2343586641
          # Source #2: https://github.com/matklad/config/blob/8062c8b8a15eabc7e623d2dab9e98cc8b26bdc48/hosts/packages.nix#L6-L18
          vivaldi = (
            (pkgs.vivaldi.overrideAttrs (oldAttrs: {
              buildPhase = builtins.replaceStrings [ "for f in libGLESv2.so libqt5_shim.so ; do" ] [
                "for f in libGLESv2.so libqt6_shim.so ; do"
              ] oldAttrs.buildPhase;
            })).override
              {
                qt5 = pkgs.qt6;
                commandLineArgs = [ "--ozone-platform=wayland" ];
                # The following two are just my preference, feel free to leave them out
                proprietaryCodecs = true;
                enableWidevine = true;
              }
          );
        in
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
          docker-compose
          dotnet-ef
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

          # Downloads
          aria
          kemono-dl
          m3u8-dl
          yt-dlp

          # Encryption
          age
          agenix
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
          deploy-rs
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

          # Web
          chromium
          discord-canary
          google-chrome
          mullvad-vpn
          vivaldi

          # Misc
          fd
          git-crypt-agessh
          imhex
          ipgen-cli
          mockoon
          wl-clipboard
          zenmonitor
        ]
      )
      ++ [ r2modman ];

    home.sessionPath = [
      "$HOME/.dotnet/tools"
    ];

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
        gitCredentialHelper.enable = true;
        settings.editor = "${getExe pkgs.vscode} --wait";
        extensions = with pkgs; [ gh-poi ];
      };
      git = {
        enable = true;
        delta.enable = true;
        lfs.enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
        extraConfig = {
          init.defaultBranch = "main";
          core.editor = "${getExe pkgs.vscode} --wait";
        };
      };
      tealdeer = {
        enable = true;
        settings.updates = {
          auto_update = true;
          auto_update_interval_hours = 72;
        };
      };
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
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        config = {
          global = {
            bash_path = lib.getExe pkgs.bash;
            strict_env = true;
          };
        };
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
      # ilspy = {
      #   name = "ILSpy";
      #   exec = getExe avalonia-ilspy;
      #   categories = [
      #     "Development"
      #     "Debugger"
      #     "Viewer"
      #   ];
      # };
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
