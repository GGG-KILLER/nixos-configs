{ ... }:
{
  imports = [
    ./audio
    ./opensnitch
    ./kde.nix
    ./rustdesk.nix
  ];

  # Android
  programs.adb.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  # Chrome SUID
  security.chromiumSuidSandbox.enable = true;

  # Flatpak
  services.flatpak.enable = true;
}
