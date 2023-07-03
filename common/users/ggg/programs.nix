{
  pkgs,
  lib,
  inputs,
  system,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam-run"
      "steam-original"
    ];

  home-manager.users.ggg = {
    home.packages = with pkgs; [
      # Coding
      docker-compose
      nodejs_latest
      powershell
      tokei

      # Database
      postgresql_14

      # Encryption
      step-cli

      # Nix
      nix-du
      nix-ld

      # Web
      croc
      wget

      # Misc
      btop
      dig.dnsutils
      file
      iotop-c
      killall
      neofetch
      p7zip
      rclone
      steam-run
      unzip
      zip
    ];

    programs = {
      command-not-found.enable = false;
      nix-index.enable = true;
      home-manager.enable = true;
      bat.enable = true;
      dircolors.enable = true;
      exa = {
        enable = true;
        enableAliases = true;
      };
      git = {
        enable = true;
        delta.enable = true;
        lfs.enable = true;
        userName = "GGG";
        userEmail = "gggkiller2@gmail.com";
        extraConfig.init.defaultBranch = "main";
      };
      jq.enable = true;
      tealdeer.enable = true;
      zsh = {
        enable = true;
        enableAutosuggestions = true;
        syntaxHighlighting.enable = true;
        enableVteIntegration = true;
        oh-my-zsh = {
          enable = true;
          plugins = ["git" "sudo"];
          theme = "candy";
        };
      };
    };

    home.file = {
      ".cache/nix-index/files".source = inputs.nix-index-database.legacyPackages.${system}.database;
    };
  };
}
