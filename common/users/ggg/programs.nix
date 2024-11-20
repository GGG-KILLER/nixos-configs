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
        history = {
          append = true;
          expireDuplicatesFirst = true;
          ignoreAllDups = true;
        };
        oh-my-zsh = {
          enable = true;
          theme = "dpoggi";
          plugins = [
            "encode64"
            "sudo"
            "timer"
            "tmux"
          ];
          extraConfig = ''
            ZSH_TMUX_FIXTERM=true
            ZSH_TMUX_UNICODE=true
            if [[ -z "$TMUX" && -z "$EMACS" && -z "$VIM" && -z "$INSIDE_EMACS" && "$TERM_PROGRAM" != "vscode" && "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]] && \
              [[ -n "$SSH_TTY" ]]; then
              ZSH_TMUX_DEFAULT_SESSION_NAME="''${USER}@$(awk '{print $1}'<<<"$SSH_CLIENT")"
              ZSH_TMUX_AUTOSTART=true
            fi
          '';
        };
      };
    };

    home.file = {
      ".cache/nix-index/files".source = inputs.nix-index-database.packages.${system}.nix-index-database;
    };
  };
}
