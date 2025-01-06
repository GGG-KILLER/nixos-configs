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

  # Android
  programs.adb.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  # Chrome SUID
  security.chromiumSuidSandbox.enable = true;

  # Giving up on 100% pure nix, I want .NET AOT
  programs.nix-ld.enable = true;

  # Enable Firejail
  programs.firejail.enable = true;
}
