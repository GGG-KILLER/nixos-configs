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
    iotop-c
    killall
    neofetch
    steam-run
  ];

  programs.bat.enable = true;
  # programs.bandwhich.enable = true;
  # programs.zsh.enable = true;
}
