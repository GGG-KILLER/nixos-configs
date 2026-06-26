{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.ggg.common-programs;

  defaultOn = desc: (mkEnableOption desc) // { default = true; };
in
{
  options.ggg.common-programs = {
    enable = mkEnableOption "the pre-configured common package set and shell aliases";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Compression
      (ouch.override {
        enableUnfree = true;
      })
      p7zip
      unzip
      zip

      # Nix
      # nix-du # TODO: Consider re-adding when it builds again
      nix-ld

      # Web
      croc
      q
      wget
      whois

      # Misc
      btop
      dua
      dust
      dysk
      fastfetch
      fd
      file
      jq
      killall
      ripgrep
    ];

    security.wrappers = {
      iotop-c = {
        owner = "root";
        group = "root";
        capabilities = "cap_net_admin+p";
        source = lib.getExe pkgs.iotop-c;
      };

      reptyr = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_ptrace+eip";
        source = lib.getExe pkgs.reptyr;
      };
    };

    programs.bat.enable = true;

    programs.nano = {
      enable = true;
      nanorc = ''
        set afterends
        set atblanks
        set colonparsing
        set indicator
        set linenumbers
        set minibar
        set mouse
        set smarthome
        set softwrap
        set tabsize 4
        set trimblanks
      '';
      syntaxHighlight = true;
    };

    programs.nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    programs.command-not-found.enable = false;

    environment.shellAliases = {
      df = "dysk";
      du = "dust";
    };

    # ZSH enabled in zsh.nix
  };
}
