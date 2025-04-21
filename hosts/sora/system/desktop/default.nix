{ ... }:
{
  imports = [
    ./audio
    ./opensnitch
    ./kde.nix
    # ./rustdesk.nix # TODO: Uncomment once NixOS/nixpkgs#390171 hits stable.
  ];

  # Android
  programs.adb.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  # Chrome SUID
  security.chromiumSuidSandbox.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  programs.goldwarden.enable = true;

  programs.gpu-screen-recorder.enable = true;

  programs.partition-manager.enable = true;
}
