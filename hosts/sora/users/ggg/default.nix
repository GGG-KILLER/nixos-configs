{
  config,
  system,
  pkgs,
  inputs,
  ...
}: let
  dotnet-sdk = with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_7_0
      sdk_6_0
      sdk_5_0
      sdk_3_1
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
      ffmpeg_5-full
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
      pgmodeler

      # Encryption
      age
      inputs.agenix.defaultPackage.${system}
      xca-stable
      yubikey-manager
      yubikey-manager-qt

      # Games
      inputs.packwiz.packages.${system}.packwiz

      # Hardware
      openrgb

      # Nix
      inputs.deploy-rs.packages.${system}.deploy-rs
      nix-top

      # VMs
      virt-manager
      virt-viewer

      # Misc
      chromium
      inputs.git-crypt-agessh.packages.${system}.default
      jellyfin-mpv-shim
      libguestfs-with-appliance
      mullvad-vpn
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
          credential.helper = "${pkgs.local.git-credential-manager}/bin/git-credential-manager-core";
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
        };
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
  };
}
