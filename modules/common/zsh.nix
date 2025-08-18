{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.programs.zsh;
in
{
  options.my.programs.zsh.enable = mkEnableOption "pre-configured zsh" // {
    default = true;
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.tmux ];

    programs.zsh.enable = true;
    programs.zsh.autosuggestions.enable = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.syntaxHighlighting.enable = true;
    programs.zsh.syntaxHighlighting.highlighters = [
      "main"
      "brackets"
    ];
    programs.zsh.enableLsColors = true;
    programs.zsh.vteIntegration = true;
    programs.zsh.setOptions = [
      # Changing Directories
      "AUTO_PUSHD" # Make cd do pushd instead.

      # Completion
      "LIST_ROWS_FIRST" # On autocomplete do row-based listing instead of column-based
      "LIST_PACKED" # Pack tables tighter together in autocomplete listing

      # Expansion and Globbing
      "NULL_GLOB" # Don't leave globs as themselves if not found
      "NUMERIC_GLOB_SORT" # Sort files numerically instead of alphabetically when their names are numerical

      # History
      "APPEND_HISTORY" # Append to history file instead of replacing it
      "EXTENDED_HISTORY" # Save command timestamp and durations
      "HIST_FCNTL_LOCK" # Lock history file while writing
      "HIST_EXPIRE_DUPS_FIRST" # Expire duplicates first instead of unique entries
      "HIST_FIND_NO_DUPS" # Don't show duplicates when going through history
      "HIST_IGNORE_SPACE" # Don't add commands with leading space to history file
      "HIST_NO_STORE" # Don't story history calls
      "SHARE_HISTORY" # Share histories among all running shells

      # Input/Output
      "RC_QUOTES" # Allow using '' instead of '"'"' for escaping single quotes in single quoted strings.
      "SHORT_LOOPS" # Allow the short form of loops
    ];

    programs.zsh.ohMyZsh.enable = true;
    programs.zsh.ohMyZsh.theme = "dpoggi";
    programs.zsh.ohMyZsh.plugins = [
      "encode64"
      "sudo"
      "timer"
      "tmux"
    ];
    programs.zsh.ohMyZsh.preLoaded = ''
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
  };
}
