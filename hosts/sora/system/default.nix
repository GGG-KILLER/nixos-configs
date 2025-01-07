{ ... }:
{
  imports = [
    ./desktop
    ./services
    ./boot.nix
    ./ccache.nix
    ./fonts.nix
    ./kernel.nix
    ./yubikey.nix
  ];

  # Giving up on 100% pure nix, I want .NET AOT
  programs.nix-ld.enable = true;

  # Enable Firejail
  programs.firejail.enable = true;
}
