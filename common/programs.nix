{ lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam-run"
      "steam-original"
      "steam-unwrapped"
    ];

  environment.systemPackages = with pkgs; [
    # Compression
    ouch
    p7zip
    unzip
    zip

    # Nix
    # nix-du # TODO: Consider re-adding when it builds again
    nix-ld

    # Web
    croc
    dig.dnsutils
    q
    wget
    whois

    # Misc
    btop
    file
    jq
    killall
    neofetch
    steam-run
  ];

  security.wrappers.iotop-c = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin+p";
    source = lib.getExe pkgs.iotop-c;
  };

  programs.bat.enable = true;

  programs.nano.enable = true;
  programs.nano.nanorc = ''
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
    set tabtospaces
    set trimblanks
  '';
  programs.nano.syntaxHighlight = true;

  programs.nix-index.enable = true;
  programs.nix-index.enableBashIntegration = true;
  programs.nix-index.enableZshIntegration = true;
  programs.command-not-found.enable = false;

  # ZSH enabled in modules/programs/zsh.nix
}
