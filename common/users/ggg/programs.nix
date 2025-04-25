{
  lib,
  options,
  inputs,
  system,
  ...
}:
{
  # only set configs if home-manager option exists
  config = lib.optionalAttrs (options ? home-manager) {
    home-manager.users.ggg = {
      programs = {
        dircolors.enable = true;
        eza = {
          enable = true;
          extraOptions = [
            "-a"
            "-g"
          ];
        };
        zsh = {
          autosuggestion.enable = true;
          autosuggestion.strategy = [
            "history"
            "completion"
          ];
          enable = true;
          enableCompletion = true;
          enableVteIntegration = true;
          history.append = true;
          history.extended = true;
          history.findNoDups = true;
          history.ignorePatterns = [
            "rm *"
            "pkill *"
          ];
          history.ignoreSpace = true;
          history.save = 1000000;
          history.share = true;
          history.size = 1000000;
          oh-my-zsh.enable = true;
          oh-my-zsh.plugins = [
            "encode64"
            "sudo"
            "timer"
            "tmux"
          ];
          oh-my-zsh.theme = "dpoggi";
          oh-my-zsh.extraConfig = ''
            ZSH_TMUX_AUTOSTART_ONCE=true
            ZSH_TMUX_AUTOCONNECT=true
            ZSH_TMUX_DETACHED=true
            ZSH_TMUX_FIXTERM=true
            ZSH_TMUX_UNICODE=true
            if [[ -z "$TMUX" && -z "$EMACS" && -z "$VIM" && -z "$INSIDE_EMACS" && "$TERM_PROGRAM" != "vscode" && "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]] && \
              [[ -n "$SSH_TTY" ]]; then
              ZSH_TMUX_DEFAULT_SESSION_NAME="''${USER}@$(awk '{print $1}'<<<"$SSH_CLIENT" | sed 's/\./_/g')"
              ZSH_TMUX_AUTOSTART=true
              ZSH_TMUX_AUTOQUIT=true
            fi
          '';
          syntaxHighlighting.enable = true;
          syntaxHighlighting.highlighters = [
            "main"
            "brackets"
          ];
        };
      };

      home.file = {
        ".cache/nix-index/files".source = inputs.nix-index-database.packages.${system}.nix-index-database;
      };
    };
  };
}
