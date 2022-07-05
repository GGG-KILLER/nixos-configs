{ system, pkgs, deploy-rs, agenix, git-crypt-agessh, ... }:

let
  dotnet-sdk = with pkgs.dotnetCorePackages; combinePackages [
    #sdk_7_0
    sdk_6_0
    sdk_5_0
    sdk_3_1
  ];
  devtools = with pkgs; [
    dotnet-sdk
    mono
    powershell
    rnix-lsp
    wrangler
    nodejs_latest
    jetbrains.rider
    docker-compose
    yarn
  ];
in
{
  imports = [
    ./jellyfin-mpv-shim.nix
    ./theme.nix
    ./vscode.nix
  ];

  users.users.ggg = {
    shell = pkgs.zsh;
    extraGroups = [ "docker" "lxd" "adbusers" ];
  };

  home-manager.users.ggg = {
    home.packages = (with pkgs; [
      # Audio
      ffmpeg_5-full
      helvum

      # Android
      android-tools
      genymotion

      # Database
      pgformatter
      pgmodeler
      postgresql_14

      # Coding
      tokei

      # Encryption
      age
      agenix.defaultPackage.${system}
      step-cli
      xca

      # Hardware
      openrgb

      # VMs
      virt-manager
      virt-viewer

      # Misc
      chromium
      croc
      deploy-rs.packages.${system}.deploy-rs
      git-crypt-agessh.packages.${system}.default
      jellyfin-mpv-shim
      libguestfs-with-appliance
      neofetch
      p7zip
      rclone
      steam-run
      virt-v2v
    ]) ++ devtools;

    home.shellAliases = { };

    programs = {
      home-manager.enable = true;
      bat.enable = true;
      dircolors.enable = true;
      exa = {
        enable = true;
        enableAliases = true;
      };
      gh = {
        enable = true;
        settings = {
          editor = "code --wait";
        };
      };
      git = {
        enable = true;
        delta.enable = true;
        lfs.enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
        extraConfig = {
          credential.helper = "${pkgs.local.git-credential-manager}/bin/git-credential-manager-core";
          credential.credentialStore = "secretservice";
          init.defaultBranch = "main";
        };
      };
      jq.enable = true;
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
      tealdeer.enable = true;
      zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
        enableVteIntegration = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "sudo" ];
          theme = "candy";
        };
      };
    };

    services = {
      flameshot.enable = true;
      rsibreak.enable = true;
    };

    # TODO: add [xdg.desktopEntries](https://nix-community.github.io/home-manager/options.html#opt-xdg.desktopEntries) for seamlessrdp
  };

  modules.home.mainUsers = [ "ggg" ];
  environment.pathsToLink = [ "/share/zsh" ];
}
