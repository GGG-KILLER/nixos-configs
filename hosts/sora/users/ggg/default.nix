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
      # sdk_10_0 # TODO: Re-enable when it actually has useful things and doesn't break C# DevKit and Rider
      sdk_9_0
      sdk_8_0
    ];
  dotnetRoot = "${dotnet-sdk}/share/dotnet";
  dotnetSdk = "${dotnetRoot}/sdk";

  agenix = inputs.agenix.packages.${system}.default;
  audiorelay = pkgs.callPackage "${inputs.stackpkgs}/packages/audiorelay.nix" { };
  deploy-rs = inputs.deploy-rs.packages.${system}.deploy-rs;
  dotnet-ef = self.packages.${system}.dotnet-ef;
  git-crypt-agessh = inputs.git-crypt-agessh.packages.${system}.default;
  ipgen-cli = inputs.ipgen-cli.packages.${system}.default;
  kemono-dl = self.packages.${system}.kemono-dl;
  m3u8-dl = self.packages.${system}.m3u8-dl;
  mockoon = self.packages.${system}.mockoon;
  vivaldi-wayland = self.packages.${system}.vivaldi-wayland;
in
{
  imports = [
    ./commands
    ./vscode.nix
  ];

  environment.systemPackages = [
    config.boot.kernelPackages.turbostat
    dotnet-sdk
  ];

  environment.etc = {
    "dotnet/install_location".text = dotnetRoot;
  };

  home-manager.users.ggg = {
    home.packages = (
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
        docker-compose
        dotnet-ef
        dotnet-outdated
        dotnet-repl
        mockoon
        nixd
        nixf
        nixfmt-rfc-style
        nodejs_latest
        powershell
        jetbrains.rider
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
        yubikey-manager-qt

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

        # VMs
        virt-manager
        virt-viewer

        # Web
        chromium
        discord-canary
        mullvad-vpn
        vivaldi-wayland

        # Misc
        duc
        fd
        imhex
        ipgen-cli
        mockoon
        wl-clipboard
        zenmonitor
      ]
    );

    home.sessionPath = [
      "$HOME/.dotnet/tools"
    ];

    home.sessionVariables = {
      DOTNET_ROOT = dotnetRoot;
      MSBuildSdksPath = "${dotnetSdk}/${head dotnet-sdk.versions}/Sdks";
      MSBUILD_EXE_PATH = "${dotnetSdk}/${head dotnet-sdk.versions}/MSBuild.dll";
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

          # Ensure integrity of things we fetch.
          transfer.fsckObjects = true;
          fetch.fsckObjects = true;
          receive.fsckObjects = true;
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
        bindings = {
          f = "cycle fullscreen";
          r = "playlist-shuffle";
          R = "playlist-unshuffle";
        };
      };
      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          # obs-nvfbc # TODO: Restore whenever it gets fixed.
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
      # opensnitch-ui.enable = true;
    };

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
