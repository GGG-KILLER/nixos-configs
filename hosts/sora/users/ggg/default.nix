{
  config,
  system,
  pkgs,
  inputs,
  ...
}: let
  dotnet-sdk = with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_7_0
      sdk_6_0
    ];
  dotnetRoot = "${dotnet-sdk}";
  dotnetSdk = "${dotnet-sdk}/sdk";
  dotnetBinary = "${dotnetRoot}/bin/dotnet";
  xca-stable = inputs.nixpkgs-stable.legacyPackages.${system}.xca;
in {
  imports = [
    ./commands
    ./theme.nix
    ./vscode.nix
  ];

  environment.systemPackages = [dotnet-sdk];

  home-manager.users.ggg = {
    home.packages = with pkgs; [
      # Audio
      easyeffects
      helvum

      # Android
      android-tools
      genymotion

      # Coding
      # jetbrains.rider
      mono
      rnix-lsp
      # wrangler
      yarn
      docker-compose
      nodejs_latest
      powershell
      tokei

      # Database
      pgformatter
      postgresql_14
      # pgmodeler # TODO: Uncomment this once the hash in nixpkgs gets updated.

      # Encryption
      age
      inputs.agenix.packages.${system}.default
      xca-stable
      # yubikey-manager # TODO: Uncomment once NixOS/nixpkgs#280995 hits unstable.
      # yubikey-manager-qt # TODO: Uncomment once NixOS/nixpkgs#280995 hits unstable.
      step-cli

      # Games
      # inputs.packwiz.packages.${system}.packwiz
      (prismlauncher.override {jdks = [openjdk8-bootstrap openjdk11-bootstrap openjdk16-bootstrap openjdk17-bootstrap jdk];})
      r2mod_cli

      # Hardware
      openrgb

      # Nix
      inputs.deploy-rs.packages.${system}.deploy-rs
      nix-top
      nixpkgs-review

      # Media
      ffmpeg-full
      handbrake

      # VMs
      virt-manager
      virt-viewer

      # Misc
      aria
      chromium
      discord-canary
      exiftool
      fd
      google-chrome
      imgbrd-grabber
      imhex
      inputs.git-crypt-agessh.packages.${system}.default
      jellyfin-mpv-shim
      libguestfs-with-appliance
      local.m3u8-dl
      local.mockoon
      mullvad-vpn
      ruffle
      rustdesk
      yt-dlp
      zenmonitor
      r2modman
    ];

    home.sessionVariables = {
      DOTNET_ROOT = dotnetRoot;
      MSBuildSdksPath = "${dotnetSdk}/$(${dotnetBinary} --version)/Sdks";
      MSBUILD_EXE_PATH = "${dotnetSdk}/$(${dotnetBinary} --version)/MSBuild.dll";

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

    home.shellAliases = {};

    programs = {
      gh = {
        enable = true;
        settings.editor = "${pkgs.vscode}/bin/code --wait";
      };
      git = {
        enable = true;
        delta.enable = true;
        lfs.enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
        extraConfig = {
          init.defaultBranch = "main";
          credential.helper = "${pkgs.local.git-credential-manager}/bin/git-credential-manager";
          credential.credentialStore = "secretservice";
          core.editor = "${pkgs.vscode}/bin/code --wait";
        };
      };
      tealdeer.enable = true;
      zsh.oh-my-zsh.plugins = [
        "adb"
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
          # General
          scale = "ewa_lanczossharp";
          cscale = "ewa_lanczossharp";
          dscale = "mitchell";
          correct-downscaling = "yes";
          linear-downscaling = "yes";
          sigmoid-upscaling = "yes";

          vd-lavc-dr = "yes";

          gpu-api = "vulkan";
          vulkan-async-compute = "yes";
          vulkan-async-transfer = "yes";
          vulkan-queue-count = 1;

          hwdec = "auto";
          vo = "gpu-next";
          ao = "pipewire";

          # Misc
          deinterlace = "no";

          # Colorspace
          #icc-contrast = 1000;
          target-prim = "auto";
          target-trc = "auto";
          vf = "format=colorlevels=full:colormatrix=auto";
          video-output-levels = "full";

          # Dither
          dither-depth = "auto";
          temporal-dither = "yes";

          # Debanding
          deband = "yes";
          deband-iterations = 4;
          deband-threshold = 20;
          deband-range = 16;
          deband-grain = 0;

          # Subtitles
          blend-subtitles = "yes";

          # Motion Interpolation
          video-sync = "display-resample";
          interpolation = "yes";
          tscale = "oversample";

          # Anti-Ringing
          scale-antiring = 0.7;
          dscale-antiring = 0.7;
          cscale-antiring = 0.7;

          # Cache
          cache = "auto";
          cache-secs = 600;
          demuxer-max-back-bytes = "250MiB";
          demuxer-max-bytes = "250MiB";
          demuxer-readahead-secs = 600;

          # profile = "gpu-hq";
          # cache-default = 4000000;
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
      rsibreak.enable = true;
    };

    xdg.configFile."nix/nix.conf".text = ''
      access-tokens = github.com=${config.my.secrets.users.ggg.nixGithubToken}
    '';

    # TODO: add [xdg.desktopEntries](https://nix-community.github.io/home-manager/options.html#opt-xdg.desktopEntries) for seamlessrdp
    xdg.desktopEntries = {
      mockoon = {
        name = "Mockoon";
        exec = "${pkgs.local.mockoon}";
        categories = ["Application" "Network"];
      };
    };

    systemd.user.services.jellyfin-mpv-shim = {
      Unit = {
        Description = "Jellyfin MPV Shim";
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };

      Service.ExecStart = "${pkgs.jellyfin-mpv-shim}/bin/jellyfin-mpv-shim";

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
