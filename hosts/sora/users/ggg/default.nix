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
      (easyeffects.override {speexdsp = speexdsp.overrideAttrs (old: {configureFlags = [];});})
      helvum

      # Android
      android-tools
      genymotion

      # Coding
      jetbrains.rider
      mono
      rnix-lsp
      wrangler
      yarn

      # Database
      pgformatter
      # pgmodeler # TODO: Uncomment this once the hash in nixpkgs gets updated.

      # Encryption
      age
      inputs.agenix.packages.${system}.default
      xca-stable
      yubikey-manager
      yubikey-manager-qt

      # Games
      inputs.packwiz.packages.${system}.packwiz
      (prismlauncher.override {jdks = [openjdk8-bootstrap openjdk11-bootstrap openjdk16-bootstrap openjdk17-bootstrap jdk];})
      r2mod_cli

      # Hardware
      openrgb

      # Nix
      inputs.deploy-rs.packages.${system}.deploy-rs
      nix-top
      nixpkgs-review

      # Media
      ffmpeg_5-full
      handbrake

      # VMs
      virt-manager
      virt-viewer

      # Misc
      chromium
      discord-canary
      fd
      google-chrome
      imhex
      inputs.git-crypt-agessh.packages.${system}.default
      # inputs.ipgen-cli.packages.${system}.ipgen-cli
      jellyfin-mpv-shim
      libguestfs-with-appliance
      local.mockoon
      mullvad-vpn
      ruffle
      rustdesk
      zenmonitor
    ];

    home.sessionVariables = {
      DOTNET_ROOT = dotnetRoot;
      MSBuildSdksPath = "${dotnetSdk}/$(${dotnetBinary} --version)/Sdks";
      MSBUILD_EXE_PATH = "${dotnetSdk}/$(${dotnetBinary} --version)/MSBuild.dll";
    };

    home.shellAliases = {};

    programs = {
      gh = {
        enable = true;
        settings.editor = "${pkgs.vscode}/bin/code --wait";
      };
      git = {
        extraConfig = {
          credential.helper = "${pkgs.local.git-credential-manager}/bin/git-credential-manager";
          credential.credentialStore = "secretservice";
          core.editor = "${pkgs.vscode}/bin/code --wait";
        };
      };
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
          profile = "gpu-hq";
          cache-default = 4000000;
          hwdec = "auto";
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
