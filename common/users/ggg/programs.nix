{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam-run"
      "steam-original"
      "steam-unwrapped"
    ];

  home-manager.users.ggg = {
    home.packages = with pkgs; [
      # Nix
      # nix-du # TODO: Consider re-adding when it builds again
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
      eza = {
        enable = true;
        extraOptions = [
          "-a"
          "-g"
        ];
      };
      jq.enable = true;
      zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableVteIntegration = true;
        oh-my-zsh = {
          enable = true;
          plugins = [
            "encode64"
            "sudo"
            "timer"
          ];
          theme = "candy";
        };
      };
    };

    home.file = {
      ".cache/nix-index/files".source = inputs.nix-index-database.packages.${system}.nix-index-database;
    };
  };
}
