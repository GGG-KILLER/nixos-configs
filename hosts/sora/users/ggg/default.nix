{ system, pkgs, deploy-rs, ... }:

let
  dotnet-sdk = pkgs: (with pkgs.dotnetCorePackages; combinePackages [
    aspnetcore_6_0
    sdk_6_0
    runtime_6_0
    aspnetcore_5_0
    sdk_5_0
    runtime_5_0
    aspnetcore_3_1
    sdk_3_1
    runtime_3_1
  ]);
  devtools = pkgs: with pkgs; [
    (dotnet-sdk pkgs)
    mono
    powershell
    rnix-lsp
    wrangler
    nodejs_latest
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
  };

  home-manager.users.ggg = {
    home.packages = (with pkgs; [
      helvum
      virt-manager
      virt-viewer
      openrgb
      libguestfs-with-appliance
      xca
      deploy-rs.packages.${system}.deploy-rs
      # pgadmin # Broken
      pgmodeler
      pgformatter
      postgresql_14
      tokei
      ffmpeg_5
      croc
      p7zip
      neofetch
      jellyfin-mpv-shim
      steam-run
    ]) ++ (devtools pkgs);

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
        };
      };
    };

    services = {
      flameshot.enable = true;
      plex-mpv-shim = {
        enable = true;
        package = pkgs.jellyfin-mpv-shim;
      };
      rsibreak.enable = true;
    };

    # TODO: add [xdg.desktopEntries](https://nix-community.github.io/home-manager/options.html#opt-xdg.desktopEntries) for seamlessrdp
  };

  modules.home.mainUsers = [ "ggg" ];
  environment.pathsToLink = [ "/share/zsh" ];
}
